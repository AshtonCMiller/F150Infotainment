#include "system.h"
#include <QDateTime>
#include <QDebug>

System::System(QObject *parent)
    : QObject(parent)
    , m_outdoorTemp( 72 )
{
    m_currentTimeTimer = new QTimer(this);
    m_currentTimeTimer->setInterval(500);
    m_currentTimeTimer->setSingleShot( true );
    connect( m_currentTimeTimer, &QTimer::timeout, this, &System::currentTimeTimerTimeout );

    currentTimeTimerTimeout();
}

int System::outdoorTemp() const
{
    return m_outdoorTemp;
}

void System::setOutdoorTemp(int outdoorTemp)
{
    if (m_outdoorTemp == outdoorTemp)
        return;
    m_outdoorTemp = outdoorTemp;
    emit outdoorTempChanged(m_outdoorTemp);
}

QString System::currentTime() const
{
    return m_currentTime;
}

void System::setCurrentTime(const QString &newCurrentTime)
{
    if (m_currentTime == newCurrentTime)
        return;
    m_currentTime = newCurrentTime;
    emit currentTimeChanged();
}

void System::currentTimeTimerTimeout()
{
    QDateTime dateTime;
    QString currentTime = dateTime.currentDateTime().toString( "hh:mm ap" );

    setCurrentTime( currentTime );

    m_currentTimeTimer->start();
}
