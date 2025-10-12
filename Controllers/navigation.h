#include <QObject>
#include <QTimer>

class Navigation : public QObject
{
    Q_OBJECT
    Q_PROPERTY(float latitude READ latitude WRITE setLatitude NOTIFY latitudeChanged)
    Q_PROPERTY(float longitude READ longitude WRITE setLongitude NOTIFY longitudeChanged)

public:
    explicit Navigation(QObject *parent = nullptr);

    float longitude() const;

    float latitude() const;

public slots:
    void setLongitude(float newLongitude);
    void setLatitude(float newLatitude);

signals:
    void currentTimeChanged();
    void longitudeChanged();
    void latitudeChanged();

private:
    float m_longitude;
    float m_latitude;
};
