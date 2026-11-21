#include "vitportalcontroller.h"

#include <QDesktopServices>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QRegularExpression>
#include <QUrl>
#include <QUrlQuery>

namespace
{
const QUrl kLoginUrl(QStringLiteral("http://phc.prontonetworks.com/cgi-bin/authlogin"));
const QUrl kLogoutUrl(QStringLiteral("http://phc.prontonetworks.com/cgi-bin/authlogout"));
const QUrl kAccountUrl(QStringLiteral("http://136.233.9.110/registration/Main.jsp"));
}

VitPortalController::VitPortalController(QObject *parent)
    : QObject(parent)
    , m_watcher(this)
{
    m_nam = new QNetworkAccessManager(this);

    connect(&m_watcher, &SsidWatcher::ssidChanged, this, [this]() {
        Q_EMIT ssidChanged();
        Q_EMIT vitWifiChanged();
    });
}

QString VitPortalController::ssid() const
{
    return m_watcher.ssid();
}

bool VitPortalController::vitWifi() const
{
    return isVitCollegeSsid(m_watcher.ssid());
}

bool VitPortalController::busy() const
{
    return m_busy;
}

QString VitPortalController::lastMessage() const
{
    return m_lastMessage;
}

bool VitPortalController::isVitCollegeSsid(const QString &ssid)
{
    const QString s = ssid.trimmed();
    if (s.isEmpty()) {
        return false;
    }
    if (s.compare(QLatin1String("VIT 2.4G"), Qt::CaseSensitive) == 0
        || s.compare(QLatin1String("VIT 5G"), Qt::CaseSensitive) == 0) {
        return true;
    }

    static const QRegularExpression blockRe(QStringLiteral("^([A-Za-z])-VIT$"));
    const auto m = blockRe.match(s);
    if (!m.hasMatch()) {
        return false;
    }
    const QChar c = m.captured(1).at(0).toUpper();
    return c >= QLatin1Char('A') && c <= QLatin1Char('T');
}

void VitPortalController::setBusy(bool v)
{
    if (m_busy == v) {
        return;
    }
    m_busy = v;
    Q_EMIT busyChanged();
}

void VitPortalController::setLastMessage(const QString &m)
{
    if (m_lastMessage == m) {
        return;
    }
    m_lastMessage = m;
    Q_EMIT lastMessageChanged();
}

void VitPortalController::login(const QString &username, const QString &password)
{
    if (m_loginReply) {
        m_loginReply->abort();
        m_loginReply->deleteLater();
        m_loginReply = nullptr;
    }

    setBusy(true);
    setLastMessage({});

    QUrlQuery q;
    q.addQueryItem(QStringLiteral("userId"), username);
    q.addQueryItem(QStringLiteral("password"), password);
    q.addQueryItem(QStringLiteral("serviceName"), QStringLiteral("ProntoAuthentication"));
    q.addQueryItem(QStringLiteral("Submit22"), QStringLiteral("Login"));

    QNetworkRequest req(kLoginUrl);
    req.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/x-www-form-urlencoded"));

    const QByteArray body = q.query(QUrl::FullyEncoded).toUtf8();
    m_loginReply = m_nam->post(req, body);
    connect(m_loginReply, &QNetworkReply::finished, this, &VitPortalController::onLoginReplyFinished);
}

void VitPortalController::onLoginReplyFinished()
{
    if (!m_loginReply) {
        setBusy(false);
        return;
    }

    const auto err = m_loginReply->error();
    const QByteArray raw = m_loginReply->readAll();
    m_loginReply->deleteLater();
    m_loginReply = nullptr;
    setBusy(false);

    if (err != QNetworkReply::NoError) {
        setLastMessage(QStringLiteral("Network error while logging in."));
        Q_EMIT loginFinished(false, m_lastMessage);
        return;
    }

    const QString text = QString::fromUtf8(raw);
    const bool ok = text.contains(QLatin1String("congratulations"), Qt::CaseInsensitive);
    const bool already = text.contains(QLatin1String("already logged in"), Qt::CaseInsensitive);
    const bool quota = text.contains(QLatin1String("quota is over"), Qt::CaseInsensitive);
    const bool badCreds = text.contains(QLatin1String("sorry"), Qt::CaseInsensitive)
        && text.contains(QLatin1String("try again"), Qt::CaseInsensitive);

    if (ok) {
        setLastMessage(QStringLiteral("Logged in."));
        Q_EMIT loginFinished(true, m_lastMessage);
    } else if (already) {
        setLastMessage(QStringLiteral("Already logged in."));
        Q_EMIT loginFinished(true, m_lastMessage);
    } else if (quota) {
        setLastMessage(QStringLiteral("Quota is over."));
        Q_EMIT loginFinished(false, m_lastMessage);
    } else if (badCreds) {
        setLastMessage(QStringLiteral("Incorrect username or password."));
        Q_EMIT loginFinished(false, m_lastMessage);
    } else {
        setLastMessage(QStringLiteral("Unexpected response from portal."));
        Q_EMIT loginFinished(false, m_lastMessage);
    }
}

void VitPortalController::logout()
{
    if (m_logoutReply) {
        m_logoutReply->abort();
        m_logoutReply->deleteLater();
        m_logoutReply = nullptr;
    }

    setBusy(true);
    setLastMessage({});

    QNetworkRequest req(kLogoutUrl);
    m_logoutReply = m_nam->get(req);
    connect(m_logoutReply, &QNetworkReply::finished, this, &VitPortalController::onLogoutReplyFinished);
}

void VitPortalController::onLogoutReplyFinished()
{
    if (!m_logoutReply) {
        setBusy(false);
        return;
    }

    const auto err = m_logoutReply->error();
    const QByteArray raw = m_logoutReply->readAll();
    m_logoutReply->deleteLater();
    m_logoutReply = nullptr;
    setBusy(false);

    if (err != QNetworkReply::NoError) {
        setLastMessage(QStringLiteral("Network error while logging out."));
        Q_EMIT logoutFinished(false, m_lastMessage);
        return;
    }

    const QString text = QString::fromUtf8(raw);
    const bool ok = text.contains(QLatin1String("successfully logged out"), Qt::CaseInsensitive);
    const bool none = text.contains(QLatin1String("no active session"), Qt::CaseInsensitive);

    if (ok) {
        setLastMessage(QStringLiteral("Logged out."));
        Q_EMIT logoutFinished(true, m_lastMessage);
    } else if (none) {
        setLastMessage(QStringLiteral("No active session."));
        Q_EMIT logoutFinished(true, m_lastMessage);
    } else {
        setLastMessage(QStringLiteral("Logout response was not recognized."));
        Q_EMIT logoutFinished(false, m_lastMessage);
    }
}

void VitPortalController::openAccountSettings()
{
    QDesktopServices::openUrl(kAccountUrl);
}

void VitPortalController::clearLastMessage()
{
    setLastMessage({});
}
