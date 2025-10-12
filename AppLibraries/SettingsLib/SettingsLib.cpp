#include "SettingsLib.h"
#include "ControllerFactory.h"
#include <QDebug>
// #include "ControllerFactory.h"

SettingsLib::SettingsLib(QObject *parent)
    : QObject{parent}
{
    qDebug() << "Spotify Controller Loaded";
    // Example: register this controller with the global factory
    ControllerFactory::instance().registerClass("SettingsController", [](QObject* parent) {
        return new SettingsLib(parent);
    });
}

// ControllerFactory::instance().registerClass("SpotifyController", [](QObject* parent){
//     return new SpotifyController(parent);
// });


extern "C" void registerPlugin() {
    ControllerFactory::instance().registerClass("SettingsController",
                                                [](QObject* parent){ return new SettingsLib(parent); });
}
