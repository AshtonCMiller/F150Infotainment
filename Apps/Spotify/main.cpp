#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>

//#include "Controllers/SpotifyController.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qDebug() << "Spotify main.cpp called!";

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("Spotify", "Main");

    return app.exec();
}
