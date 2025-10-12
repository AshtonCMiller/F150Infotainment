#include "AppManager.h"
#include "ControllerFactory.h"
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QDebug>
#include <QCoreApplication>
#include <qqmlcontext.h>
#include <QLibrary>

AppManager::AppManager(QQmlApplicationEngine* engine, QObject *parent)
    : QObject(parent),
      m_engine(engine)
{
    loadApps();
}

void AppManager::loadApps() {
    m_apps.clear();

    QDir appsDir(QCoreApplication::applicationDirPath() + "/Apps");
    if (!appsDir.exists()) {
        qWarning() << "Apps directory not found:" << appsDir.path();
        return;
    }

    for (const QString &folderName : appsDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot)) {
        QString infoPath = appsDir.filePath(folderName + "/" + folderName + "/appinfo.json");
        QFile file(infoPath);
        if (!file.open(QIODevice::ReadOnly))
            continue;

        auto doc = QJsonDocument::fromJson(file.readAll());
        if (!doc.isObject())
            continue;

        auto obj = doc.object();
        QVariantMap app;
        app["id"] = obj.value("id").toString();
        app["name"] = obj.value("name").toString();
        QString absiconfile = appsDir.filePath(folderName + "/" + obj.value("icon").toString());
        app["icon"] = QUrl::fromLocalFile(absiconfile).toString();
        QString absfilepath = appsDir.filePath(folderName + "/" + obj.value("qml").toString());
        app["qml"] = QUrl::fromLocalFile(absfilepath).toString();
        m_apps.append(app);
        qWarning() << "Loaded app: " << app["name"].toString();
    }

    emit appsChanged();
}

void AppManager::initializeControllers() {

    // So we need to look through AppLibraries dir
    // And in every folder, look for any .so files
    // which will be our library, then load the library.
    // Library will handle registering itself with
    // Controller Factory

    QDir baseDir(QCoreApplication::applicationDirPath() + "/AppLibraries");
    for (const QFileInfo &subdir : baseDir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot)) {
        QDir pluginDir(subdir.absoluteFilePath());
        for (const QFileInfo &fileInfo : pluginDir.entryInfoList(QDir::Files)) {
            QString filePath = fileInfo.absoluteFilePath();
            if (!filePath.endsWith(".so")) continue;
            QLibrary lib(filePath);
            if (!lib.load()) {
                qWarning() << "Failed to load controller lib" << fileInfo.fileName() << lib.errorString();
            } else {
                //qDebug() << "Successfully loaded controller lib" << fileInfo.fileName();
                typedef void (*RegisterFunc)();
                RegisterFunc reg = (RegisterFunc)  lib.resolve("registerPlugin");;
                if (reg) {
                    reg(); // now the library registers itself properly
                    qDebug() << fileInfo.fileName() << "registered!";
                } else {
                    qWarning() << "registerPlugin symbol not found!";
                }
            }
        }
    }
}

void AppManager::loadControllers() {
    QDir appsDir(QCoreApplication::applicationDirPath() + "/Apps");
    QStringList appList = appsDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);

    for (const QString& appName : appList) {
        QString infoPath = appsDir.absoluteFilePath(appName + "/" + appName + "/appinfo.json");
        QFile infoFile(infoPath);
        if (!infoFile.open(QIODevice::ReadOnly)) continue;

        QJsonDocument doc = QJsonDocument::fromJson(infoFile.readAll());
        QJsonObject obj = doc.object();
        QString controllerName = obj.value("controller").toString(); // e.g. "SpotifyController"

        QObject* controllerInstance = ControllerFactory::instance().create(controllerName);
        if (controllerInstance) {
            m_controllers.insert(controllerName, controllerInstance);
            m_engine->rootContext()->setContextProperty(controllerName, controllerInstance);
            qDebug() << "Loaded controller:" << controllerName;
        } else {
            qWarning() << "Failed to load controller:" << controllerName;
        }
    }
}

QObject* AppManager::controller(const QString& name) const
{
    return m_controllers.value(name, nullptr);
}

QVariantMap AppManager::getApp(int index) const {
    if (index < 0 || index >= m_apps.size())
        return {};
    return m_apps[index].toMap();
}

void AppManager::reloadApps() {
    loadApps();
}
