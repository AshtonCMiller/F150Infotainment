#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QProcessEnvironment>
#include <QNetworkDiskCache>
#include <QNetworkAccessManager>
#include <QStandardPaths>
#include <QQmlNetworkAccessManagerFactory>

// vehicle controllers
#include <Controllers/system.h>
#include <Controllers/navigation.h>
#include <Controllers/AppManager.h>

class CachedNetworkAccessManagerFactory : public QQmlNetworkAccessManagerFactory {
public:
    QNetworkAccessManager *create(QObject *parent) override {
        auto *nam = new QNetworkAccessManager(parent);

        auto *diskCache = new QNetworkDiskCache(nam);
        QString cachePath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
        diskCache->setCacheDirectory(cachePath);
        diskCache->setMaximumCacheSize(200 * 1024 * 1024); // 200 MB, adjust as needed
        nam->setCache(diskCache);

        return nam;
    }
};


/*

Setup instructions:

setup geoclue:
sudo pacman -S geoclue
sudo systemctl enable --now geoclue.service

 */

/*

Update infrastructure:

file layout:
/opt/infotainment-A/
/opt/infotainment-B/
/opt/infotainment -> /opt/infotainment-A (symlink)
/var/lib/infotainment/pending-update (marker file)

*/

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));

    QCoreApplication::setApplicationVersion(QString(APP_VERSION));

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    System m_systemHandler;
    Navigation m_navigationHandler;
    AppManager m_appManager(&engine);
    m_appManager.initializeControllers();
    m_appManager.loadControllers();

    bool isProduction = QProcessEnvironment::systemEnvironment().contains("REAL_HARDWARE");
    engine.rootContext()->setContextProperty("isProduction", false); // isProduction);

    engine.addImportPath("/usr/lib/qt6/qml");

    // Setup caching for maps
    engine.setNetworkAccessManagerFactory(new CachedNetworkAccessManagerFactory);

    QQmlContext * context( engine.rootContext() );
    context->setContextProperty( "systemHandler", &m_systemHandler );
    context->setContextProperty( "navigationHandler", &m_navigationHandler );
    context->setContextProperty( "appmanager", &m_appManager);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("InfotainmentSystem", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    QString currentVersion = QCoreApplication::applicationVersion();
    qWarning() << "Current Version:" << currentVersion;

    QObject *rootObject = engine.rootObjects().first();
    if (auto window = qobject_cast<QQuickWindow *>(rootObject)) {
        if (isProduction) {
            window->setFlags(Qt::Window | Qt::FramelessWindowHint);
            window->showFullScreen();
        }
    } else {
        qWarning("Root object is not a QQUickWindow! Fullscreen may break!");
    }

    return app.exec();
}
