import QtQuick
import QtLocation 6.6
import QtPositioning 6.6
import QtQuick.Controls
// import QtQuick.VirtualKeyboard

Window {
    //id: window
    id: root
    visible: true
    flags: Qt.FramelessWindowHint
    visibility: isProduction ? Window.FullScreen : Window.Windowed;
    width: isProduction ? Screen.width : 1280
    height: isProduction ? Screen.height : 720
    title: qsTr("Hello World")

    property string currentApp: ""
    property bool appVisible: false

    MapDisplay {
        width: parent.width
        height: parent.height - parent.height * 0.05
    }

    /*Plugin {
        id: osmPlugin
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

        // PluginParameter {
        //     name: "mapbox.map_id"
        //     value: "custom.satellite"
        // }
        // PluginParameter {
        //     name: "mapbox.access_token"
        //     value: ""  // not required for custom server
        // }
        // PluginParameter {
        //     name: "mapbox.custom_url"
        //     value: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
        // }

        // PluginParameter {
        //     name: "osm.mapping.custom.host"
        //     value: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/"
        // }
        // // optional: cache folder for offline use
        // PluginParameter {
        //     name: "osm.mapping.offline.directory"
        //     value: "/home/user/mapcache"
        // }
    }

    Map {
        anchors.fill: parent
        plugin: osmPlugin
        center: QtPositioning.coordinate(37.1158104,-93.3622856,) // Example: San Francisco
        zoomLevel: 16



        // MapUrlTile {
        //     z: 0
        //     minimumZoomLevel: 0
        //     maximumZoomLevel: 19
        //     source: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
        // }
    }*/


    SmallMediaPlayer {

    }

    Text {
        id: dateTimeDisplay
        anchors {
            right: parent.right
            top: parent.top
            rightMargin: 40
            topMargin: 10
        }

        font.pixelSize: 12
        font.bold: true
        color: "black"

        text: systemHandler.currentTime;
    }


    // BOTTOM DOCK (TESLA STYLE)
    Rectangle {
        id: bottomBar
        anchors {
            bottom: parent.bottom
        }

        width: parent.width
        height: parent.height * 0.1
        color: "#181818"
        radius: 0

        Row {
            id: iconRow
            spacing: 20
            anchors.centerIn: parent
            Repeater {
                model: appmanager.apps
                delegate: Item {
                    width: bottomBar.height * 0.5
                    height: bottomBar.height * 0.5

                    Rectangle {
                        id: iconButton
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        radius: 12
                        color: "#2A2A2A"
                        border.color: (root.currentApp === modelData.qml & root.appVisible === true) ? "#FFFFFF" : "transparent"
                        border.width: 2

                        Image {
                            anchors.centerIn: parent
                            source: modelData.icon
                            width: parent.width
                            height: parent.height
                            fillMode: Image.PreserveAspectFit
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (root.currentApp === modelData.qml) {
                                    // Tapping same icon minimizes the app
                                    //root.currentApp = ""
                                    root.appVisible = !root.appVisible
                                } else {
                                    root.currentApp = modelData.qml
                                    root.appVisible = true;
                                }
                            }
                        }
                    }

                    // App name below icon
                    Text {
                        text: modelData.name
                        anchors.top: iconButton.bottom
                        anchors.horizontalCenter: iconButton.horizontalCenter
                        color: "#CCC"
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        width: iconButton.width
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }


    Rectangle {
        id: appContainer
        anchors.top: parent.top
        width: parent.width * 0.6
        height: parent.height * 0.9
        x: -width // start off-screen left
        z: 1
        visible: currentApp !== ""
        color: "transparent"

        Loader {
            id: animatedLoader
            anchors.fill: parent
            source: currentApp
        }

        states: [
            State {
                name: "shown"
                when: appVisible === true
                PropertyChanges { target: appContainer; x: 0 }
            },
            State {
                name: "hidden"
                when: appVisible === false
                PropertyChanges { target: appContainer; x: -width }
            }
        ]

        transitions: [
            Transition {
                NumberAnimation { properties: "x"; duration: 400; easing.type: Easing.InOutQuad }
            }
        ]
    }


    // Column {
    //     anchors.fill: parent
    //     spacing: 0

    //     // MAIN APP DISPLAY AREA
    //     Rectangle {
    //         id: mainArea
    //         width: root.width
    //         height: root.height - bottomBar.height
    //         color: "#121212"
    //         opacity: 1

    //         Loader {
    //             id: appLoader
    //             anchors.fill: parent
    //             source: root.currentAppQml
    //             // onSourceChanged: console.log("Loader source changed to:", appLoader.source)
    //             // onStatusChanged: console.log("Loader status:", appLoader.status, "errorString:", appLoader.errorString)
    //         }
    //     }


    // }


    // Rectangle {
    //     id: bottomBar
    //     width: parent.width
    //     height: parent.height * 0.05
    //     anchors {
    //         bottom: parent.bottom
    //     }
    //     Rectangle {
    //         opacity: 1;
    //         anchors {
    //             horizontalCenter: parent.horizontalCenter
    //         }
    //         onRender {

    //         }

    //         ListView {
    //             id: appList
    //             anchors.fill: parent
    //             model: AppManager.apps
    //             delegate: Button {
    //                 text: model.name
    //                 width: parent.width
    //                 height: parent.height
    //                 onClicked: {
    //                     qDebug() << "hi"
    //                 }
    //             }
    //         }
    //     }
    // }

    // StackView {
    //     id: stack
    //     anchors.fill: parent
    //     initialItem: launcherView
    // }

    // Component {
    //     id: launcherView
    //     Rectangle {
    //         color: "#202020"
    //         anchors.fill: parent

    //         ListView {
    //             id: appList
    //             anchors.fill: parent
    //             model: AppManager.apps
    //             delegate: Button {
    //                 text: model.name
    //                 width: parent.width
    //                 height: 80
    //                 onClicked: {
    //                     qDebug() << "Load app view for app " << model.qml
    //                     //stack.push(appViewComponent, { source: model.qml })
    //                 }
    //             }
    //         }
    //     }
    // }

    /*Text {
        id: loadStatus
        text: "Test Application Loaded Successfully"
    }
    Text {
        id: envLabel
        anchors.top: loadStatus.bottom
        text: isProduction ? "Production Environment" : "Development Environment"
    }

    Rectangle {
        id: rect;
        color: "orange";
        anchors.top: envLabel.bottom
        x: 50
        width: 50
        height: 50
        // anchors: {
        //     left: parent.left
        // }
    }*/


    // InputPanel {
    //     id: inputPanel
    //     z: 99
    //     x: 0
    //     y: window.height
    //     width: window.width

    //     states: State {
    //         name: "visible"
    //         when: inputPanel.active
    //         PropertyChanges {
    //             target: inputPanel
    //             y: window.height - inputPanel.height
    //         }
    //     }
    //     transitions: Transition {
    //         from: ""
    //         to: "visible"
    //         reversible: true
    //         ParallelAnimation {
    //             NumberAnimation {
    //                 properties: "y"
    //                 duration: 250
    //                 easing.type: Easing.InOutQuad
    //             }
    //         }
    //     }
    // }
}
