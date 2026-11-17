/*
    Cozy Ena user tile — no circular crop.
    Shows avatar PNG as-is so logo octagon / transparency keeps exact shape.
    Username: cream fill + brown stroke (same recipe as lock date).
*/

import QtQuick
import QtQuick.Window

import org.kde.kirigami as Kirigami

Item {
    id: wrapper

    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software

    property bool isCurrent: true
    property string name
    property string userName
    property string avatarPath
    property string iconSource
    property bool needsPassword
    property var vtNumber
    property bool constrainText: true
    property real fontSize: Kirigami.Theme.defaultFont.pointSize + 2
    property alias nameFontSize: nameLabel.font.pixelSize
    signal clicked()

    property real faceSize: Kirigami.Units.gridUnit * 8

    readonly property color nameFill: "#FFF8EC"
    readonly property color nameStroke: "#3D2415"
    readonly property int nameStrokeR: 2

    opacity: isCurrent ? 1.0 : 0.75

    Behavior on opacity {
        OpacityAnimator {
            duration: Kirigami.Units.longDuration
        }
    }

    function ringOffsets(maxR) {
        if (maxR <= 0)
            return []
        var pts = []
        var seen = {}
        for (var rad = 1; rad <= maxR; rad++) {
            var n = Math.max(12, rad * 10)
            for (var i = 0; i < n; i++) {
                var a = (Math.PI * 2 * i) / n
                var x = Math.round(Math.cos(a) * rad)
                var y = Math.round(Math.sin(a) * rad)
                var key = x + "," + y
                if (seen[key])
                    continue
                seen[key] = true
                pts.push({ x: x, y: y })
            }
        }
        return pts
    }

    Item {
        id: imageSource
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        Behavior on width {
            PropertyAnimation {
                from: wrapper.faceSize
                duration: Kirigami.Units.longDuration
            }
        }
        width: wrapper.isCurrent ? wrapper.faceSize : wrapper.faceSize - Kirigami.Units.gridUnit
        height: width

        Image {
            id: face
            anchors.fill: parent
            source: wrapper.avatarPath
            sourceSize: Qt.size(wrapper.faceSize * Screen.devicePixelRatio,
                                wrapper.faceSize * Screen.devicePixelRatio)
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            smooth: true
            mipmap: true
        }

        Kirigami.Icon {
            id: faceIcon
            source: wrapper.iconSource
            visible: face.status === Image.Error || face.status === Image.Null
            anchors.fill: parent
        }
    }

    Item {
        id: usernameDelegate
        anchors.top: imageSource.bottom
        anchors.topMargin: Kirigami.Units.gridUnit
        anchors.horizontalCenter: parent.horizontalCenter
        width: wrapper.constrainText
            ? Math.min(parent.width, nameLabel.implicitWidth + wrapper.nameStrokeR * 2 + 8)
            : nameLabel.implicitWidth + wrapper.nameStrokeR * 2 + 8
        height: nameLabel.implicitHeight + wrapper.nameStrokeR * 2 + 8

        Repeater {
            model: wrapper.ringOffsets(wrapper.nameStrokeR)
            delegate: Text {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: modelData.x
                anchors.verticalCenterOffset: modelData.y
                text: wrapper.name
                color: wrapper.nameStroke
                font.family: "Comfortaa"
                font.pixelSize: Math.round((wrapper.fontSize + 4) * 1.35)
                font.weight: Font.Bold
                horizontalAlignment: Text.AlignHCenter
                wrapMode: wrapper.constrainText ? Text.WordWrap : Text.NoWrap
                maximumLineCount: wrapper.constrainText ? 3 : 1
                elide: Text.ElideRight
                width: wrapper.constrainText ? usernameDelegate.width - wrapper.nameStrokeR * 2 : undefined
                renderType: Text.QtRendering
            }
        }

        Text {
            id: nameLabel
            anchors.centerIn: parent
            text: wrapper.name
            color: wrapper.nameFill
            font.family: "Comfortaa"
            font.pixelSize: Math.round((wrapper.fontSize + 4) * 1.35)
            font.weight: Font.Bold
            font.underline: wrapper.activeFocus
            horizontalAlignment: Text.AlignHCenter
            wrapMode: wrapper.constrainText ? Text.WordWrap : Text.NoWrap
            maximumLineCount: wrapper.constrainText ? 3 : 1
            elide: Text.ElideRight
            width: wrapper.constrainText ? usernameDelegate.width - wrapper.nameStrokeR * 2 : undefined
            renderType: Text.QtRendering
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: wrapper.clicked()
    }

    Keys.onSpacePressed: wrapper.clicked()

    Accessible.name: name
    Accessible.role: Accessible.Button
    function accessiblePressAction() { wrapper.clicked() }
}
