#include "vitportalcontroller.h"

#include <QQmlEngine>
#include <QQmlExtensionPlugin>

class VitPortalQmlPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)

public:
    void registerTypes(const char *uri) override
    {
        if (QLatin1String(uri) != QLatin1String("org.kde.plasma.private.vitportal")) {
            return;
        }
        qmlRegisterType<VitPortalController>(uri, 1, 0, "VitPortalController");
    }
};

#include "vitportal_plugin.moc"
