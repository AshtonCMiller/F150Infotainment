#include "UpdateManager.h"
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QProcess>
#include <QNetworkAccessManager>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QNetworkReply>

UpdateManager::UpdateManager(QObject *parent)
    : QObject(parent)
    , m_UpdateStatus( "Not checked for updates" )
    , m_UpdateInProgress( false )
{
    m_networkAccessManager = new QNetworkAccessManager(this);
}

void UpdateManager::downloadAndInstallUpdate(const QString &url)
{
    setUpdateProgress( "Downloading Update" );
    QNetworkReply *download = m_networkAccessManager->get(QNetworkRequest(QUrl(url)));

    connect(download, &QNetworkReply::finished, this, [=]() {
        if (download->error() != QNetworkReply::NoError) {
            setUpdateProgress( "Failed downloading update - Try again later." );
            setUpdateStatus( "Update failed. ");
            setUpdateInProgress( false );
            qWarning() << "Download failed:" << download->errorString();
            download->deleteLater();
            return;
        }

        setUpdateProgress( "Saving update file" );
        QString filePath = "/tmp/update.tar.gz";
        QFile file(filePath);
        if (!file.open(QIODevice::WriteOnly)) {
            qWarning() << "Failed to save update to" << filePath;
            download->deleteLater();
            return;
        }

        file.write(download->readAll());
        file.close();
        download->deleteLater();

        if (installUpdate(filePath)) {
            setUpdateStatus( "Update installed. It will activate on next reboot." );
            setUpdateProgress( "" );
            qDebug() << "Update installed. It will activate on next reboot.";
        }
    });
}

bool UpdateManager::installUpdate(const QString &archivePath) {
    setUpdateProgress( "Installing update..." );
    QString activeSlot = getActiveSlot();
    QString inactiveSlot = (activeSlot.contains("infotainment-A"))
                               ? "/opt/infotainment-B"
                               : "/opt/infotainment-A";

    QDir(inactiveSlot).removeRecursively();
    QDir().mkpath(inactiveSlot);

    QProcess tar;
    tar.start("tar", {"xzf", archivePath, "-C", inactiveSlot});
    tar.waitForFinished(-1);
    if (tar.exitCode() != 0) {
        setUpdateProgress( "Failed to extract update contents. Try again later." );
        setUpdateStatus( "Update failed. ");
        qWarning() << "Extraction failed:" << tar.readAllStandardError();
        return false;
    }

    QFile marker("/var/lib/infotainment/pending-update");
    if (!marker.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        setUpdateProgress( "Failed to establish pending update. Try again later." );
        setUpdateStatus( "Update failed. ");
        qWarning() << "Failed to write marker file";
        return false;
    }
    marker.write(inactiveSlot.toUtf8());
    marker.close();
    setUpdateProgress( "Installed update." );
    setUpdateStatus( "Update will apply on next startup." );

    return true;
}

void UpdateManager::checkForUpdate()
{
    setUpdateInProgress( true );
    setUpdateStatus( "Checking for updates.." );
    setUpdateProgress( "Checking update server" );
    QUrl url("https://api.github.com/repos/AshtonCMiller/F150Infotainment/releases/latest");
    QNetworkRequest request(url);
    request.setRawHeader("User-Agent", "Infotainment-Updater");

    QNetworkReply *reply = m_networkAccessManager->get(request);
    connect(reply, &QNetworkReply::finished, this, [=]() {
        if (reply->error() != QNetworkReply::NoError) {
            setUpdateProgress( "Network error - Unable to check for updates." );
            setUpdateStatus( "Update failed. ");
            setUpdateInProgress( false );
            qWarning() << "Failed to check for updates:" << reply->errorString();
            reply->deleteLater();
            return;
        }

        QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        QJsonObject root = doc.object();
        QString latestVersion = root["tag_name"].toString();  // GitHub release tag

        qDebug() << "Current version:" << m_Version;
        qDebug() << "Latest version:" << latestVersion;

        if (latestVersion == m_Version) {
            setUpdateStatus( "Already up to date." );
            setUpdateProgress( "" );
            setUpdateInProgress( false );
            qDebug() << "Already up to date.";
            reply->deleteLater();
            return;
        }
        // Find a tar.gz asset in the release
        QJsonArray assets = root["assets"].toArray();
        QString downloadUrl;
        for (const QJsonValue &val : assets) {
            QJsonObject asset = val.toObject();
            QString name = asset["name"].toString();
            if (name.endsWith(".tar.gz")) {
                downloadUrl = asset["browser_download_url"].toString();
                break;
            }
        }

        if (downloadUrl.isEmpty()) {
            qWarning() << "No .tar.gz asset found in the release.";
            reply->deleteLater();
            return;
        }

        setUpdateStatus( "New version available. Downloading version " + latestVersion );

        qDebug() << "New update available:" << latestVersion;
        qDebug() << "Downloading from:" << downloadUrl;

        if (m_updatesEnabled == false) {
            setUpdateStatus( "Can not update from  development environment!" );
            setUpdateProgress( "" );
            setUpdateInProgress( false );
        }

        downloadAndInstallUpdate(downloadUrl);
        reply->deleteLater();
    });
}

QString UpdateManager::UpdateStatus() const
{
    return m_UpdateStatus;
}

void UpdateManager::setUpdateStatus(const QString &newUpdateStatus)
{
    if (m_UpdateStatus == newUpdateStatus)
        return;
    m_UpdateStatus = newUpdateStatus;
    emit UpdateStatusChanged();
}

QString UpdateManager::getActiveSlot()
{
    QProcess p;
    p.start("readlink", {"/opt/infotainment"});
    p.waitForFinished();
    return QString::fromUtf8(p.readAllStandardOutput()).trimmed();
}

bool UpdateManager::UpdateInProgress() const
{
    return m_UpdateInProgress;
}

void UpdateManager::setUpdateInProgress(bool newUpdateInProgress)
{
    if (m_UpdateInProgress == newUpdateInProgress)
        return;
    m_UpdateInProgress = newUpdateInProgress;
    emit UpdateInProgressChanged();
}

QString UpdateManager::UpdateProgress() const
{
    return m_UpdateProgress;
}

void UpdateManager::setUpdateProgress(const QString &newUpdateProgress)
{
    if (m_UpdateProgress == newUpdateProgress)
        return;
    m_UpdateProgress = newUpdateProgress;
    emit UpdateProgressChanged();
}

QString UpdateManager::Version() const
{
    return m_Version;
}

void UpdateManager::setVersion(const QString &newVersion)
{
    if (m_Version == newVersion)
        return;
    m_Version = newVersion;
    emit VersionChanged();
}

void UpdateManager::setUpdatesEnabled(bool updatesEnabled)
{
    m_updatesEnabled = updatesEnabled;
    if (updatesEnabled) {
        markBootSuccessful();
    }
}

void UpdateManager::markBootSuccessful()
{
    QFile file("/var/lib/myapp/boot-ok");
    if (file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        file.write("ok");
        file.close();
    }
}
