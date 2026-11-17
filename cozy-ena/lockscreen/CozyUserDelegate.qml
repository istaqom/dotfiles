/*
    Cozy Ena user tile — no circular crop.
    Shows avatar PNG as-is so logo octagon / transparency keeps exact shape.
*/

import QtQuick
import QtQuick.Window

import org.kde.plasma.components as PlasmaComponents3
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
    property alias nameFontSize: usernameDelegate.font.pointSize
    property real fontSize: Kirigami.Theme.defaultFont.pointSize + 2
    signal clicked()

    property real faceSize: Kirigami.Units.gridUnit * 8

    opacity: isCurrent ? 1.0 : 0.75

    Behavior on opacity {
        OpacityAnimator {
            duration: Kirigami.Units.longDuration
        }
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
            // Keep logo octagon — no circle crop, no square plate behind
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

    PlasmaComponents3.Label {
        id: usernameDelegate

        anchors.top: imageSource.bottom
        anchors.topMargin: Kirigami.Units.gridUnit
        anchors.horizontalCenter: parent.horizontalCenter

        font.pointSize: wrapper.fontSize + 4
        font.family: "Comfortaa"

        width: wrapper.constrainText ? parent.width : undefined
        text: wrapper.name
        textFormat: Text.PlainText
        style: wrapper.softwareRendering ? Text.Outline : Text.Normal
        styleColor: wrapper.softwareRendering ? Kirigami.Theme.backgroundColor : "transparent"
        wrapMode: Text.WordWrap
        maximumLineCount: wrapper.constrainText ? 3 : 1
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        font.underline: wrapper.activeFocus
        color: "#FFF6E8"
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
