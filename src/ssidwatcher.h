#pragma once

#include <QObject>
#include <QString>

class SsidWatcher : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString ssid READ ssid NOTIFY ssidChanged)

public:
    explicit SsidWatcher(QObject *parent = nullptr);

    QString ssid() const { return m_ssid; }

public Q_SLOTS:
    void refresh();

Q_SIGNALS:
    void ssidChanged();

private:
    QString readSsidFromNetworkManager() const;

    QString m_ssid;
};
