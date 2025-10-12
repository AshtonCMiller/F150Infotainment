#include <QObject>
#include <QNetworkAccessManager>

class UpdateManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString UpdateStatus READ UpdateStatus WRITE setUpdateStatus NOTIFY UpdateStatusChanged FINAL)
    Q_PROPERTY(bool UpdateInProgress READ UpdateInProgress WRITE setUpdateInProgress NOTIFY UpdateInProgressChanged FINAL)
    Q_PROPERTY(QString UpdateProgress READ UpdateProgress WRITE setUpdateProgress NOTIFY UpdateProgressChanged FINAL)
    Q_PROPERTY(QString Version READ Version WRITE setVersion NOTIFY VersionChanged FINAL)

public:
    explicit UpdateManager(QObject *parent = nullptr);
    //float latitude() const;

    void downloadAndInstallUpdate(const QString &url);

    QString UpdateStatus() const;
    void setUpdateStatus(const QString &newUpdateStatus);

    bool UpdateInProgress() const;
    void setUpdateInProgress(bool newUpdateInProgress);

    QString UpdateProgress() const;
    void setUpdateProgress(const QString &newUpdateProgress);

    QString Version() const;
    void setVersion(const QString &newVersion);

    void setUpdatesEnabled(bool updatesEnabled);
    void markBootSuccessful();

public slots:
    void checkForUpdate();
    // void setLongitude(float newLongitude);
    // void setLatitude(float newLatitude);

signals:
    // void currentTimeChanged();
    // void longitudeChanged();
    // void latitudeChanged();

    void UpdateStatusChanged();

    void UpdateInProgressChanged();

    void UpdateProgressChanged();

    void VersionChanged();

private:
    bool installUpdate(const QString &archivePath);
    QString getActiveSlot();
    QString m_UpdateStatus;
    QNetworkAccessManager * m_networkAccessManager;
    bool m_UpdateInProgress;
    bool m_updatesEnabled;
    QString m_UpdateProgress;
    QString m_Version;
};

