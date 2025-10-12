import QtQuick
import QtLocation 6.6
import QtPositioning 6.6

Item {
    anchors.fill: parent
    Plugin {
        id: mapPlugin
        name: "googlemaps"     // Base plugin

        PluginParameter {
            name: "googlemaps.useragent"
            value: "f-150"
        }

        PluginParameter {
            name: "googlemaps.cachefolder"
            value: "/gmaps_cache"
        }

        PluginParameter {
            name: "googlemaps.route.apikey"
            value: "AIzaSyADGHgCNxWWfkvqXiFDh9azepA6mv2KkYA"
        }

        PluginParameter {
            name: "googlemaps.maps.apikey"
            value: "AIzaSyADGHgCNxWWfkvqXiFDh9azepA6mv2KkYA"
        }

        PluginParameter {
            name: "googlemaps.geocode.apikey"
            value: "AIzaSyADGHgCNxWWfkvqXiFDh9azepA6mv2KkYA"
        }
    }

    Map {
        anchors.fill: parent
        plugin: mapPlugin
        center: QtPositioning.coordinate(37.1158104,-93.3622856,) // Example: San Francisco
        zoomLevel: 16
    }

    Rectangle {
        id: navigationButton
        anchors {
            left: parent.left
            leftMargin: 10 + parent.width * 0.1
            top: parent.top
            topMargin: 10
        }
        width: parent.width * 0.2
        height: parent.height * 0.06
        radius: 5
        color: "#4a4444"
        opacity: 0.8

        Text {
            id: navigationText
            anchors {
                left: parent.left;
                leftMargin: 10;
                verticalCenter: parent.verticalCenter
            }

            font.pixelSize: 11
            font.bold: true
            color: "white"

            text: "Navigate"
        }
    }

    Text {
        id: googleLogo
        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin: 10
            bottomMargin: 40
        }

        font.pixelSize: 15
        font.bold: true
        color: "white"

        text: "Google"
    }

    // Current street name
    Rectangle {
        id: streetAddressContainer
        anchors {
            horizontalCenter: parent.horizontalCenter;
            bottom: parent.bottom;
            bottomMargin: 10
        }

        width: 200
        height: 30
        radius: 5
        color: "#4a4444"
        opacity: 0.8

        Text {
            id: streetAddressName
            anchors {
                left: parent.left;
                leftMargin: 10;
                verticalCenter: parent.verticalCenter
            }

            font.pixelSize: 11
            font.bold: true
            color: "white"

            text: "Honeysuckle Ln"
        }
        Text {
            id: townName
            anchors {
                right: parent.right;
                rightMargin: 10;
                verticalCenter: parent.verticalCenter
            }

            font.pixelSize: 11
            font.bold: true
            color: "white"
            opacity: 0.7


            text: "Battlefield, MO"
        }
    }
}
