import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.clock as PlasmaClock
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support
import org.kde.plasma.workspace.calendar as PlasmaCalendar
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    preferredRepresentation: compactRepresentation
    switchWidth: Kirigami.Units.gridUnit * 12
    switchHeight: Kirigami.Units.gridUnit * 12
    toolTipMainText: root.timeText
    toolTipSubText: root.dateText
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    PlasmaClock.Clock {
        id: clock
        trackSeconds: false
    }

    P5Support.DataSource {
        id: exec
        engine: "executable"
        connectedSources: []
        onNewData: sourceName => disconnectSource(sourceName)
        function run(cmd) {
            connectSource(cmd)
        }
    }

    function openClockApp() {
        exec.run("gtk-launch org.kde.kclock.desktop")
    }

    function toggleCalendar() {
        root.expanded = !root.expanded
    }

    readonly property string fontFamily: clockFont.status === FontLoader.Ready
        ? clockFont.name : "Noto Sans"

    FontLoader {
        id: clockFont
        source: Qt.resolvedUrl("../fonts/Comfortaa-Bold.ttf")
    }

    readonly property string timeText: {
        var d = clock.dateTime
        var h = d.getHours()
        var m = d.getMinutes()
        var am = h < 12
        var h12 = h % 12
        if (h12 === 0) h12 = 12
        var hs = (h12 < 10 ? "0" : "") + h12
        var ms = (m < 10 ? "0" : "") + m
        return hs + ":" + ms + (am ? " AM" : " PM")
    }

    readonly property string dateText: {
        var d = clock.dateTime
        var dd = d.getDate()
        var mm = d.getMonth() + 1
        var yyyy = d.getFullYear()
        var ds = (dd < 10 ? "0" : "") + dd
        var ms = (mm < 10 ? "0" : "") + mm
        return ds + "/" + ms + "/" + yyyy
    }

    compactRepresentation: Item {
        id: compact
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignVCenter
        Layout.minimumWidth: pills.width
        Layout.preferredWidth: pills.width
        Layout.minimumHeight: root.pillH
        implicitWidth: pills.width
        implicitHeight: root.pillH

        Item {
            id: pills
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 0
            anchors.left: parent.left
            height: root.pillH
            width: timePill.width + root.gap + datePill.width

            Rectangle {
                id: timePill
                x: 0
                y: 0
                width: Math.ceil(timeLabel.contentWidth) + root.pillPadX * 2
                height: root.pillH
                radius: root.pillH / 2
                color: root.pillFill
                border.width: 1
                border.color: root.cream

                Text {
                    id: timeLabel
                    anchors.centerIn: parent
                    text: root.timeText
                    color: root.cream
                    font.family: root.fontFamily
                    font.pixelSize: root.fontPx
                    font.weight: Font.Bold
                    renderType: Text.QtRendering
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.openClockApp()
                }
            }

            Rectangle {
                id: datePill
                x: timePill.width + root.gap
                y: 0
                width: Math.ceil(dateRow.implicitWidth) + root.pillPadX * 2
                height: root.pillH
                radius: root.pillH / 2
                color: root.pillFill
                border.width: 1
                border.color: root.cream

                // One row — icon + text share same verticalCenter (fixes low calendar)
                Row {
                    id: dateRow
                    anchors.centerIn: parent
                    spacing: root.iconTextGap
                    height: Math.max(calIcon.height, dateLabel.contentHeight)

                    Item {
                        id: calIcon
                        width: root.iconSz
                        height: root.iconSz
                        anchors.verticalCenter: parent.verticalCenter
                        // Comfortaa cap-height sits high vs boxy glyph — nudge icon up
                        anchors.verticalCenterOffset: -1

                        // page body — full height of icon box
                        Rectangle {
                            anchors.fill: parent
                            anchors.topMargin: 2
                            radius: 1
                            color: "transparent"
                            border.width: 1
                            border.color: root.cream
                        }
                        // header bar
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.topMargin: 2
                            height: 3
                            color: root.cream
                        }
                        // rings (sit on top edge, within box)
                        Rectangle {
                            x: 2; y: 0
                            width: 2; height: 3
                            radius: 1
                            color: root.cream
                        }
                        Rectangle {
                            x: parent.width - 4; y: 0
                            width: 2; height: 3
                            radius: 1
                            color: root.cream
                        }
                        // day dots
                        Rectangle {
                            x: 3; y: parent.height - 4
                            width: 2; height: 2
                            color: root.cream
                        }
                        Rectangle {
                            x: 6; y: parent.height - 4
                            width: 2; height: 2
                            color: root.cream
                            opacity: 0.65
                        }
                    }

                    Text {
                        id: dateLabel
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.dateText
                        color: root.cream
                        font.family: root.fontFamily
                        font.pixelSize: root.fontPx
                        font.weight: Font.Bold
                        renderType: Text.QtRendering
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggleCalendar()
                }
            }
        }
    }

    fullRepresentation: Item {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 18
        Layout.minimumHeight: Kirigami.Units.gridUnit * 18
        Layout.preferredWidth: Kirigami.Units.gridUnit * 20
        Layout.preferredHeight: Kirigami.Units.gridUnit * 20

        PlasmaCalendar.MonthView {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            today: clock.dateTime
            currentDate: clock.dateTime
        }
    }

    // Tight pills — ~2px pad inside around 12px type
    readonly property int pillH: 22
    readonly property int pillPadX: 10
    readonly property int fontPx: 12
    readonly property int iconSz: 11
    readonly property int iconTextGap: 6
    readonly property int gap: 6
    readonly property color cream: "#FFF6E8"
    readonly property color pillFill: "#4A2F1C"
}
