#pragma once

#include <QObject>
#include <QString>

#include "ssidwatcher.h"

class QNetworkAccessManager;
class QNetworkReply;

class VitPortalController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString ssid READ ssid NOTIFY ssidChanged)
    Q_PROPERTY(bool vitWifi READ vitWifi NOTIFY vitWifiChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(QString lastMessage READ lastMessage NOTIFY lastMessageChanged)

public:
    explicit VitPortalController(QObject *parent = nullptr);

    QString ssid() const;
    bool vitWifi() const;
    bool busy() const;
    QString lastMessage() const;

    Q_INVOKABLE void login(const QString &username, const QString &password);
    Q_INVOKABLE void logout();
    Q_INVOKABLE void openAccountSettings();
    Q_INVOKABLE void clearLastMessage();

Q_SIGNALS:
    void ssidChanged();
    void vitWifiChanged();
    void busyChanged();
    void lastMessageChanged();
    void loginFinished(bool ok, const QString &detail);
    void logoutFinished(bool ok, const QString &detail);

private Q_SLOTS:
    void onLoginReplyFinished();
    void onLogoutReplyFinished();

private:
    static bool isVitCollegeSsid(const QString &ssid);
    void setBusy(bool v);
    void setLastMessage(const QString &m);

    SsidWatcher m_watcher;
    QNetworkAccessManager *m_nam = nullptr;
    QNetworkReply *m_loginReply = nullptr;
    QNetworkReply *m_logoutReply = nullptr;
    bool m_busy = false;
    QString m_lastMessage;
};
