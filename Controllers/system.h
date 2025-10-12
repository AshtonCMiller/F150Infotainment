#include <QObject>
#include <QTimer>

class System : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int outdoorTemp READ outdoorTemp WRITE setOutdoorTemp NOTIFY outdoorTempChanged)
    Q_PROPERTY(QString currentTime READ currentTime WRITE setCurrentTime NOTIFY currentTimeChanged)

public:
    explicit System(QObject *parent = nullptr);

    int outdoorTemp() const;

    QString currentTime() const;

public slots:
    void setOutdoorTemp(int outdoorTemp);

    void setCurrentTime(const QString &newCurrentTime);

    void currentTimeTimerTimeout();

signals:
    void outdoorTempChanged(int outdoorTemp);

    void currentTimeChanged();

private:
    int m_outdoorTemp;
    QString m_currentTime;

    QTimer * m_currentTimeTimer;
};
