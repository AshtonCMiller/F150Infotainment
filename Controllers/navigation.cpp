#include "navigation.h"
#include <QDateTime>
#include <QDebug>
#include <QGeoPositionInfo>
#include <QGeoPositionInfoSource>

Navigation::Navigation(QObject *parent)
    : QObject(parent)
    , m_latitude( 37.115814 )
    , m_longitude( -93.3622856 )
    //, m_outdoorTemp( 72 )
{

    QGeoPositionInfoSource *source = QGeoPositionInfoSource::createDefaultSource(this);

    if (!source) {
        qWarning() << "No position source available on this system";

    } else {
        qWarning() << "Running position updates";
        QObject::connect(source, &QGeoPositionInfoSource::positionUpdated,
                         [](const QGeoPositionInfo &info) {
                             auto coord = info.coordinate();
                             qDebug() << "Latitude:" << coord.latitude()
                                      << "Longitude:" << coord.longitude()
                                      << "Accuracy (m):" << info.attribute(QGeoPositionInfo::HorizontalAccuracy);
                         });

        source->setUpdateInterval(1000); // 1 second
        source->startUpdates();
    }
}
float Navigation::longitude() const
{
    return m_longitude;
}

void Navigation::setLongitude(float newLongitude)
{
    if (m_longitude == newLongitude)
        return;
    m_longitude = newLongitude;
    emit longitudeChanged();
}

float Navigation::latitude() const
{
    return m_latitude;
}

void Navigation::setLatitude(float newLatitude)
{
    if (m_latitude == newLatitude)
        return;
    m_latitude = newLatitude;
    emit latitudeChanged();
}
