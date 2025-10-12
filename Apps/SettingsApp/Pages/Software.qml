import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    anchors.fill: parent
    color: "transparent" // themeManager.colors.background.card
    radius: 12
    border.color: themeManager.colors.accent.primary
    border.width: 0 // 1
    anchors.margins: 20

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 24

        // Divider
        Rectangle {
            height: 2
            anchors.left: parent.left
            anchors.right: parent.right
            color: themeManager.colors.accent.primary
        }

        // Software Section
        Text {
            id: softwareText
            text: "Software"
            font.pixelSize: 16
            font.bold: true
            color: themeManager.colors.text.primary
        }

        Text {
            id: softwareVersion
            text: updateManager.Version
            font.pixelSize: 16
            font.bold: true
            color: themeManager.colors.text.primary
        }

        Text {
            id: softwareStatus
            text: updateManager.UpdateStatus
            font.pixelSize: 16
            font.bold: false
            color: themeManager.colors.text.primary
        }

        Text {
            id: updateProgress
            text: updateManager.UpdateProgress
            visible: updateManager.UpdateInProgress || updateManager.UpdateProgess.size() > 0
            font.pixelSize: 16
            font.bold: false
            color: themeManager.colors.text.primary
        }

        Button {
            id: updateButton
            enabled: !updateManager.UpdateInProgress
            text: "Check for updates"

            onClicked: {
                updateManager.checkForUpdate();
            }
        }

        // Check for updates button

        // // Current Version
        // Text {
        //     text: "Current Version: " + updateManager.version
        //     font.pixelSize: 24
        //     color: themeManager.colors.text.primary
        // }

        // // Update Button
        // Button {
        //     text: updateManager.progress > 0 && updateManager.progress < 100 ? "Updating..." : "Check for Updates"
        //     enabled: !(updateManager.progress > 0 && updateManager.progress < 100)
        //     font.pixelSize: 20
        //     background: Rectangle { color: themeManager.colors.accent.primary; radius: 8 }

        //     onClicked: {
        //         if (updateManager.progress === 0)
        //             updateManager.checkForUpdate()
        //     }
        // }

        // // Progress bar
        // Rectangle {
        //     width: parent.width
        //     height: 16
        //     radius: 8
        //     color: themeManager.colors.background.main
        //     border.width: 1
        //     border.color: themeManager.colors.accent.primary

        //     Rectangle {
        //         width: parent.width * (updateManager.progress / 100)
        //         height: parent.height
        //         radius: 8
        //         color: themeManager.colors.accent.primary
        //     }
        // }

        // // Status Text
        // Text {
        //     text: updateManager.status
        //     font.pixelSize: 18
        //     color: themeManager.colors.text.secondary
        // }
    }
}
