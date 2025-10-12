#include <QObject>
#include <QNetworkAccessManager>

class UpdateManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString UpdateStatus READ UpdateStatus WRITE setUpdateStatus NOTIFY UpdateStatusChanged FINAL)
    Q_PROPERTY(bool UpdateInProgress READ UpdateInProgress WRITE setUpdateInProgress NOTIFY UpdateInProgressChanged FINAL)
    Q_PROPERTY(QString UpdateProgress READ UpdateProgress WRITE setUpdateProgress NOTIFY UpdateProgressChanged FINAL)

public:
    explicit UpdateManager(QObject *parent = nullptr);
    //float latitude() const;

    void downloadAndInstallUpdate(const QString &url);
    void checkForUpdate(const QString &currentVersion);

    QString UpdateStatus() const;
    void setUpdateStatus(const QString &newUpdateStatus);

    bool UpdateInProgress() const;
    void setUpdateInProgress(bool newUpdateInProgress);

    QString UpdateProgress() const;
    void setUpdateProgress(const QString &newUpdateProgress);

public slots:
    // void setLongitude(float newLongitude);
    // void setLatitude(float newLatitude);

signals:
    // void currentTimeChanged();
    // void longitudeChanged();
    // void latitudeChanged();

    void UpdateStatusChanged();

    void UpdateInProgressChanged();

    void UpdateProgressChanged();

private:
    bool installUpdate(const QString &archivePath);
    QString getActiveSlot();
    QString m_UpdateStatus;
    QNetworkAccessManager * m_networkAccessManager;
    bool m_UpdateInProgress;
    QString m_UpdateProgress;
};

