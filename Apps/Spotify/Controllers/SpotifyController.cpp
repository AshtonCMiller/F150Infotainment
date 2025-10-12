#include "SpotifyController.h"
#include "ControllerFactory.h"
#include <QDebug>
// #include "ControllerFactory.h"

SpotifyController::SpotifyController(QObject *parent)
    : QObject{parent}
{
    qDebug() << "Spotify Controller Loaded";
    // Example: register this controller with the global factory
    ControllerFactory::instance().registerClass("SpotifyController", [](QObject* parent) {
        return new SpotifyController(parent);
    });
}

// ControllerFactory::instance().registerClass("SpotifyController", [](QObject* parent){
//     return new SpotifyController(parent);
// });
