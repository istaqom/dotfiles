/*
    Cozy Ena lock clock — synced with desktop org.cozyena.bigclock outline recipe.
    Date above time, same gold / cream rim / brown stroke (scaled).
*/

import QtQuick
import org.kde.plasma.clock as PlasmaClock

Item {
    id: root

    property Item shadow
    property bool unlockMode: false

    // Match desktop widget idle size (~108px gold digits)
    readonly property int idleW: 560
    readonly property int idleH: 200
    readonly property int unlockW: 360
    readonly property int unlockH: 120
    readonly property int idleFont: 108
    readonly property int unlockFont: 52
    readonly property int idleDateFont: 26
    readonly property int unlockDateFont: 15

    width: unlockMode ? unlockW : idleW
    height: unlockMode ? unlockH : idleH

    property int fontSize: idleFont
    property int dateFontSize: idleDateFont
    property bool sizeAnimReady: false

    // Optical outline: √ scale + floors so small date keeps brown>cream sandwich
    function outlineForSize(px) {
        var stroke = Math.max(2, Math.round(5 * Math.sqrt(px / 108)))
        var rim = Math.max(1, Math.min(stroke - 1, Math.round(2 * Math.sqrt(px / 108))))
        return { stroke: stroke, rim: rim }
    }
    readonly property var clockOutline: outlineForSize(fontSize)
    readonly property var dateOutline: outlineForSize(dateFontSize)
    readonly property int strokeReach: clockOutline.stroke
    readonly property int rimReach: clockOutline.rim
    readonly property int dateStrokeReach: dateOutline.stroke
    readonly property int dateRimReach: dateOutline.rim

    onUnlockModeChanged: {
        fontSize = unlockMode ? unlockFont : idleFont
        dateFontSize = unlockMode ? unlockDateFont : idleDateFont
    }
    Component.onCompleted: {
        fontSize = unlockMode ? unlockFont : idleFont
        dateFontSize = unlockMode ? unlockDateFont : idleDateFont
        Qt.callLater(function () { root.sizeAnimReady = true })
    }

    Behavior on width {
        enabled: root.sizeAnimReady
        NumberAnimation { duration: 650; easing.type: Easing.InOutCubic }
    }
    Behavior on height {
        enabled: root.sizeAnimReady
        NumberAnimation { duration: 650; easing.type: Easing.InOutCubic }
    }
    Behavior on fontSize {
        enabled: root.sizeAnimReady
        NumberAnimation { duration: 650; easing.type: Easing.InOutCubic }
    }
    Behavior on dateFontSize {
        enabled: root.sizeAnimReady
        NumberAnimation { duration: 650; easing.type: Easing.InOutCubic }
    }

    FontLoader {
        id: clockFont
        source: Qt.resolvedUrl("fonts/Comfortaa-Bold.ttf")
    }

    PlasmaClock.Clock {
        id: timeSource
        trackSeconds: false
    }

    readonly property string timeText: {
        var d = timeSource.dateTime
        var hh = d.getHours()
        var mm = d.getMinutes()
        var hs = (hh < 10 ? "0" : "") + hh
        var ms = (mm < 10 ? "0" : "") + mm
        return hs + ":" + ms
    }

    readonly property string dateText: {
        var d = timeSource.dateTime
        var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        var dd = d.getDate()
        var ds = (dd < 10 ? "0" : "") + dd
        return days[d.getDay()] + " - " + ds + " " + months[d.getMonth()] + " - " + d.getFullYear()
    }

    readonly property string fontFamily: clockFont.status === FontLoader.Ready
        ? clockFont.name
        : "Noto Sans"
    readonly property color fillColor: "#FFC94A"
    readonly property color rimColor: "#FFF8EC"
    readonly property color strokeColor: "#3D2415"

    // Filled annular ring — smooth curves (same as desktop bigclock)
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

    component OutlinedText: Item {
        id: ot
        property string text
        property int pixelSize
        property int strokeR: 5
        property int rimR: 2
        property bool heavyShadow: true
        property real letterSp: 1
        property color fill: root.fillColor
        width: label.implicitWidth + strokeR * 2 + 8
        height: label.implicitHeight + strokeR * 2 + 8

        // Soft drop — desktop recipe scaled
        Repeater {
            model: ot.heavyShadow
                ? [
                    { x: Math.max(2, Math.round(ot.strokeR)), y: Math.max(3, Math.round(ot.strokeR * 1.4)), c: "#803D2415" },
                    { x: Math.max(1, Math.round(ot.strokeR * 0.6)), y: Math.max(2, Math.round(ot.strokeR * 0.8)), c: "#553D2415" }
                  ]
                : []
            delegate: Text {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: modelData.x
                anchors.verticalCenterOffset: modelData.y
                text: ot.text
                color: modelData.c
                font.family: root.fontFamily
                font.pixelSize: ot.pixelSize
                font.weight: Font.Black
                font.letterSpacing: ot.letterSp
                renderType: Text.QtRendering
            }
        }

        Repeater {
            model: root.ringOffsets(ot.strokeR)
            delegate: Text {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: modelData.x
                anchors.verticalCenterOffset: modelData.y
                text: ot.text
                color: root.strokeColor
                font.family: root.fontFamily
                font.pixelSize: ot.pixelSize
                font.weight: Font.Black
                font.letterSpacing: ot.letterSp
                renderType: Text.QtRendering
            }
        }

        Repeater {
            model: root.ringOffsets(ot.rimR)
            delegate: Text {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: modelData.x
                anchors.verticalCenterOffset: modelData.y
                text: ot.text
                color: root.rimColor
                font.family: root.fontFamily
                font.pixelSize: ot.pixelSize
                font.weight: Font.Black
                font.letterSpacing: ot.letterSp
                renderType: Text.QtRendering
            }
        }

        Text {
            id: label
            anchors.centerIn: parent
            text: ot.text
            color: ot.fill
            font.family: root.fontFamily
            font.pixelSize: ot.pixelSize
            font.weight: Font.Black
            font.letterSpacing: ot.letterSp
            renderType: Text.QtRendering
        }
    }

    Column {
        id: stack
        anchors.centerIn: parent
        spacing: root.unlockMode ? 2 : 6

        OutlinedText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.dateText
            pixelSize: root.dateFontSize
            strokeR: root.dateStrokeReach
            rimR: 0
            heavyShadow: true
            letterSp: 0.8
            fill: root.rimColor
        }

        OutlinedText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.timeText
            pixelSize: root.fontSize
            strokeR: root.strokeReach
            rimR: root.rimReach
            heavyShadow: true
            letterSp: 1
        }
    }
}
