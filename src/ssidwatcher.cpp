#include "ssidwatcher.h"

#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusObjectPath>
#include <QDBusReply>
#include <QMetaObject>
#include <QTimer>

namespace
{
constexpr auto kNmService = "org.freedesktop.NetworkManager";
constexpr auto kNmPath = "/org/freedesktop/NetworkManager";
constexpr auto kNmIface = "org.freedesktop.NetworkManager";
constexpr auto kDevIface = "org.freedesktop.NetworkManager.Device";
constexpr auto kWirelessIface = "org.freedesktop.NetworkManager.Device.Wireless";
constexpr auto kApIface = "org.freedesktop.NetworkManager.AccessPoint";

constexpr uint kNmDeviceStateActivated = 100U;
}

SsidWatcher::SsidWatcher(QObject *parent)
    : QObject(parent)
{
    auto *timer = new QTimer(this);
    timer->setInterval(2000);
    connect(timer, &QTimer::timeout, this, &SsidWatcher::refresh);
    QMetaObject::invokeMethod(this, "refresh", Qt::QueuedConnection);
    timer->start();
}

void SsidWatcher::refresh()
{
    const QString next = readSsidFromNetworkManager();
    if (next == m_ssid) {
        return;
    }
    m_ssid = next;
    Q_EMIT ssidChanged();
}

QString SsidWatcher::readSsidFromNetworkManager() const
{
    QDBusInterface nm(kNmService, kNmPath, kNmIface, QDBusConnection::systemBus());
    if (!nm.isValid()) {
        return {};
    }

    const QDBusReply<QList<QDBusObjectPath>> reply = nm.call("GetDevices");
    if (!reply.isValid()) {
        return {};
    }

    for (const QDBusObjectPath &path : reply.value()) {
        if (path.path().isEmpty() || path.path() == QLatin1String("/")) {
            continue;
        }

        QDBusInterface device(kNmService, path.path(), kDevIface, QDBusConnection::systemBus());
        if (!device.isValid()) {
            continue;
        }

        const uint devType = device.property("DeviceType").toUInt();
        // NM_DEVICE_TYPE_WIFI == 2
        if (devType != 2U) {
            continue;
        }

        const uint state = device.property("State").toUInt();
        if (state != kNmDeviceStateActivated) {
            continue;
        }

        QDBusInterface wireless(kNmService, path.path(), kWirelessIface, QDBusConnection::systemBus());
        if (!wireless.isValid()) {
            continue;
        }

        const QVariant apVar = wireless.property("ActiveAccessPoint");
        const QDBusObjectPath apPath = qvariant_cast<QDBusObjectPath>(apVar);
        if (apPath.path().isEmpty() || apPath.path() == QLatin1String("/")) {
            continue;
        }

        QDBusInterface ap(kNmService, apPath.path(), kApIface, QDBusConnection::systemBus());
        if (!ap.isValid()) {
            continue;
        }

        const QByteArray raw = ap.property("Ssid").toByteArray();
        return QString::fromUtf8(raw);
    }

    return {};
}
