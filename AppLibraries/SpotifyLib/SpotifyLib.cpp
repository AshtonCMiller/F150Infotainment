#include "SpotifyLib.h"
#include "ControllerFactory.h"
#include <QDebug>
// #include "ControllerFactory.h"

SpotifyLib::SpotifyLib(QObject *parent)
    : QObject{parent}
{
    qDebug() << "Spotify Controller Loaded";
    // Example: register this controller with the global factory
    ControllerFactory::instance().registerClass("SpotifyController", [](QObject* parent) {
        return new SpotifyLib(parent);
    });
}

// ControllerFactory::instance().registerClass("SpotifyController", [](QObject* parent){
//     return new SpotifyController(parent);
// });


extern "C" void registerPlugin() {
    ControllerFactory::instance().registerClass("SpotifyController",
        [](QObject* parent){ return new SpotifyLib(parent); });
}
