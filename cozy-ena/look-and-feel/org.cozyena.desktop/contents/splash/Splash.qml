/*
    Cozy Ena splash — wallpaper from images/background.jpg (installed by apply-splash.sh)
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.kirigami as Kirigami

Rectangle {
    id: root
    color: "#6B4423"

    property int stage

    onStageChanged: {
        if (stage == 2) {
            introAnimation.running = true
        } else if (stage == 5) {
            introAnimation.target = busyIndicator
            introAnimation.from = 1
            introAnimation.to = 0
            introAnimation.running = true
        }
    }

    // Wallpaper baked into theme by apply-splash.sh (ksplash can't rely on ~/ paths)
    Image {
        id: wallpaper
        anchors.fill: parent
        asynchronous: true
        fillMode: Image.PreserveAspectCrop
        source: "images/background.jpg"
        visible: status === Image.Ready
    }

    // Soft brown veil — top clear for Ena, bottom darker for chrome
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0.42, 0.27, 0.14, wallpaper.visible ? 0.12 : 1.0) }
            GradientStop { position: 0.55; color: Qt.rgba(0.42, 0.27, 0.14, wallpaper.visible ? 0.18 : 1.0) }
            GradientStop { position: 1.0; color: Qt.rgba(0.35, 0.22, 0.11, wallpaper.visible ? 0.55 : 1.0) }
        }
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: 0

        // Bottom chrome — leave center clear for Ena
        Column {
            id: bottomChrome
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.height * 0.10
            spacing: Kirigami.Units.smallSpacing
            width: parent.width

            Item {
                id: mark
                anchors.horizontalCenter: parent.horizontalCenter
                width: Kirigami.Units.gridUnit * 3.5
                height: width

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: Qt.rgba(1, 0.973, 0.925, 0.12)
                    border.width: 2
                    border.color: "#F4C15A"
                }
                Text {
                    anchors.centerIn: parent
                    text: "♪"
                    color: "#FFF8EC"
                    style: Text.Outline
                    styleColor: Qt.rgba(0.42, 0.27, 0.14, 0.55)
                    font.pixelSize: Math.round(mark.width * 0.45)
                    font.bold: true
                }
            }

            Text {
                id: title
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Cozy Ena"
                color: "#FFF8EC"
                style: Text.Outline
                styleColor: Qt.rgba(0.42, 0.27, 0.14, 0.65)
                font.pixelSize: Math.round(Kirigami.Units.gridUnit * 1.6)
                font.bold: true
                Accessible.name: text
                Accessible.role: Accessible.StaticText
                textFormat: Text.PlainText
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "welcome home"
                color: "#F4C15A"
                style: Text.Outline
                styleColor: Qt.rgba(0.42, 0.27, 0.14, 0.5)
                font.pixelSize: Math.round(Kirigami.Units.gridUnit * 0.75)
                textFormat: Text.PlainText
            }

            Image {
                id: busyIndicator
                anchors.horizontalCenter: parent.horizontalCenter
                asynchronous: true
                source: "images/busywidget.svgz"
                sourceSize.height: Kirigami.Units.gridUnit * 2
                sourceSize.width: Kirigami.Units.gridUnit * 2
                RotationAnimator on rotation {
                    from: 0
                    to: 360
                    duration: 2000
                    loops: Animation.Infinite
                    running: Kirigami.Units.longDuration > 1
                }
            }
        }
    }

    OpacityAnimator {
        id: introAnimation
        running: false
        target: content
        from: 0
        to: 1
        duration: Kirigami.Units.veryLongDuration * 2
        easing.type: Easing.InOutQuad
    }
}
