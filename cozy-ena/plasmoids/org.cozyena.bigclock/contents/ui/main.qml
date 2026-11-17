import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.clock as PlasmaClock
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root
    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    fullRepresentation: Item {
        id: body
        Layout.minimumWidth: 560
        Layout.minimumHeight: 200
        Layout.preferredWidth: 560
        Layout.preferredHeight: 200
        width: 560
        height: 200
        implicitWidth: 560
        implicitHeight: 200

        FontLoader {
            id: clockFont
            source: Qt.resolvedUrl("../fonts/Comfortaa-Bold.ttf")
        }

        PlasmaClock.Clock {
            id: clock
            trackSeconds: false
        }

        readonly property string timeText: {
            var d = clock.dateTime
            var hh = d.getHours()
            var mm = d.getMinutes()
            var hs = (hh < 10 ? "0" : "") + hh
            var ms = (mm < 10 ? "0" : "") + mm
            return hs + ":" + ms
        }

        readonly property string dateText: {
            var d = clock.dateTime
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
        readonly property int fontSize: 108
        readonly property int dateFontSize: 26
        readonly property color fillColor: "#FFC94A"
        readonly property color rimColor: "#FFF8EC"
        readonly property color strokeColor: "#3D2415"
        // Optical outline: shrink slower than font (√), floors keep sandwich readable when small
        // 108px → 5/2, 26px → 2/1, never stroke==rim (that made cream-only / white outline)
        function outlineForSize(px) {
            var stroke = Math.max(2, Math.round(5 * Math.sqrt(px / 108)))
            var rim = Math.max(1, Math.min(stroke - 1, Math.round(2 * Math.sqrt(px / 108))))
            return { stroke: stroke, rim: rim }
        }

        readonly property var clockOutline: outlineForSize(fontSize)
        readonly property var dateOutline: outlineForSize(dateFontSize)
        readonly property int strokeR: clockOutline.stroke
        readonly property int rimR: clockOutline.rim
        readonly property int dateStrokeR: dateOutline.stroke
        readonly property int dateRimR: dateOutline.rim

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
            property real letterSp: 1
            property color fill: body.fillColor
            width: label.implicitWidth + strokeR * 2 + 8
            height: label.implicitHeight + strokeR * 2 + 8

            Repeater {
                model: [
                    { x: Math.max(2, Math.round(ot.strokeR)), y: Math.max(3, Math.round(ot.strokeR * 1.4)), c: "#803D2415" },
                    { x: Math.max(1, Math.round(ot.strokeR * 0.6)), y: Math.max(2, Math.round(ot.strokeR * 0.8)), c: "#553D2415" }
                ]
                delegate: Text {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: modelData.x
                    anchors.verticalCenterOffset: modelData.y
                    text: ot.text
                    color: modelData.c
                    font.family: body.fontFamily
                    font.pixelSize: ot.pixelSize
                    font.weight: Font.Black
                    font.letterSpacing: ot.letterSp
                    renderType: Text.QtRendering
                }
            }

            Repeater {
                model: body.ringOffsets(ot.strokeR)
                delegate: Text {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: modelData.x
                    anchors.verticalCenterOffset: modelData.y
                    text: ot.text
                    color: body.strokeColor
                    font.family: body.fontFamily
                    font.pixelSize: ot.pixelSize
                    font.weight: Font.Black
                    font.letterSpacing: ot.letterSp
                    renderType: Text.QtRendering
                }
            }

            Repeater {
                model: body.ringOffsets(ot.rimR)
                delegate: Text {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: modelData.x
                    anchors.verticalCenterOffset: modelData.y
                    text: ot.text
                    color: body.rimColor
                    font.family: body.fontFamily
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
                font.family: body.fontFamily
                font.pixelSize: ot.pixelSize
                font.weight: Font.Black
                font.letterSpacing: ot.letterSp
                renderType: Text.QtRendering
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 6

            OutlinedText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: body.dateText
                pixelSize: body.dateFontSize
                strokeR: body.dateStrokeR
                rimR: 0
                letterSp: 0.8
                fill: body.rimColor
            }

            OutlinedText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: body.timeText
                pixelSize: body.fontSize
                strokeR: body.strokeR
                rimR: body.rimR
                letterSp: 1
            }
        }
    }
}
