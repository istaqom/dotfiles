import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mpris as Mpris

PlasmoidItem {
    id: root

    preferredRepresentation: compactRepresentation
    switchWidth: Kirigami.Units.gridUnit * 10
    switchHeight: Kirigami.Units.gridUnit * 10
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    toolTipMainText: root.hasTrack ? root.track : i18n("No media playing")
    toolTipSubText: root.hasTrack ? root.artist : i18n("Click for controls · middle-click play/pause")

    readonly property color brownSoft: "#8B5A33"
    readonly property color cream: "#FFF8EC"
    readonly property color gold: "#F4C15A"

    Mpris.Mpris2Model {
        id: mpris2Model
    }

    readonly property var player: mpris2Model.currentPlayer
    readonly property bool hasPlayer: !!player
    readonly property bool hasTrack: hasPlayer && !!(player.track && String(player.track).length)
    readonly property bool isPlaying: hasPlayer && player.playbackStatus === Mpris.PlaybackStatus.Playing
    readonly property string track: hasPlayer ? (player.track || "") : ""
    readonly property string artist: hasPlayer ? (player.artist || "") : ""
    readonly property string artUrl: hasPlayer ? (player.artUrl || "") : ""

    function playPause() {
        if (player)
            player.PlayPause()
    }

    compactRepresentation: Item {
        id: compact
        // Match ~dock icon size on 52px panel
        readonly property int iconSize: 44

        Layout.fillHeight: true
        Layout.fillWidth: false
        Layout.alignment: Qt.AlignVCenter
        Layout.minimumWidth: root.hasTrack ? (compact.iconSize + 12 + Kirigami.Units.gridUnit * 8) : (compact.iconSize + 8)
        Layout.preferredWidth: row.width + 8
        Layout.maximumWidth: Kirigami.Units.gridUnit * 18
        Layout.minimumHeight: compact.iconSize + 8
        Layout.preferredHeight: compact.iconSize + 8

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            onClicked: mouse => {
                if (mouse.button === Qt.MiddleButton && root.hasPlayer) {
                    root.playPause()
                    return
                }
                root.expanded = !root.expanded
            }
            onWheel: wheel => {
                if (!root.player)
                    return
                if (wheel.angleDelta.y > 0 && root.player.canGoNext)
                    root.player.Next()
                else if (wheel.angleDelta.y < 0 && root.player.canGoPrevious)
                    root.player.Previous()
            }
        }

        // Plain Row — Layout was squashing the art into a tall oval
        Row {
            id: row
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 2
            spacing: 6
            height: compact.iconSize

            // Rounded art with antialiased corners (no jagged edges)
            Rectangle {
                id: badge
                width: compact.iconSize
                height: compact.iconSize
                radius: 8
                color: root.brownSoft
                border.width: root.isPlaying ? 2 : 1.5
                border.color: root.gold
                readonly property bool showArt: root.hasTrack && root.artUrl.length > 0
                    && artImg.status === Image.Ready

                Image {
                    id: artImg
                    anchors.fill: parent
                    source: root.artUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    mipmap: true
                    smooth: true
                    visible: false
                    sourceSize: Qt.size(compact.iconSize * 2, compact.iconSize * 2)
                }

                OpacityMask {
                    anchors.fill: parent
                    visible: badge.showArt
                    source: artImg
                    maskSource: Rectangle {
                        width: compact.iconSize
                        height: compact.iconSize
                        radius: 8
                        color: "#ffffff"
                        antialiasing: true
                    }
                    cached: true
                }

                Text {
                    anchors.centerIn: parent
                    visible: !badge.showArt
                    text: "♪"
                    color: root.cream
                    font.pixelSize: Math.round(compact.iconSize * 0.5)
                    font.bold: true
                }
            }

            Column {
                visible: root.hasTrack
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0
                width: Math.min(Kirigami.Units.gridUnit * 10, 160)

                PlasmaComponents3.Label {
                    width: parent.width
                    text: root.track
                    color: root.cream
                    elide: Text.ElideRight
                    font.pixelSize: Math.max(10, Math.round(compact.iconSize * 0.30))
                    font.bold: true
                    maximumLineCount: 1
                }
                PlasmaComponents3.Label {
                    width: parent.width
                    text: root.artist
                    color: Qt.rgba(1, 0.973, 0.925, 0.7)
                    elide: Text.ElideRight
                    font.pixelSize: Math.max(9, Math.round(compact.iconSize * 0.24))
                    maximumLineCount: 1
                    visible: root.artist.length > 0
                }
            }
        }
    }

    fullRepresentation: Item {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 16
        Layout.preferredHeight: Kirigami.Units.gridUnit * 7

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                spacing: Kirigami.Units.smallSpacing
                Layout.fillWidth: true

                Rectangle {
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 3
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                    Layout.maximumWidth: Kirigami.Units.gridUnit * 3
                    Layout.maximumHeight: Kirigami.Units.gridUnit * 3
                    radius: 10
                    color: root.brownSoft
                    border.color: root.gold
                    border.width: 1

                    Image {
                        anchors.fill: parent
                        source: root.artUrl
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        mipmap: true
                        visible: status === Image.Ready
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: !(root.artUrl && parent.children[0].status === Image.Ready)
                        text: "♪"
                        color: root.cream
                        font.pixelSize: Kirigami.Units.gridUnit * 1.3
                        font.bold: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    PlasmaComponents3.Label {
                        Layout.fillWidth: true
                        text: root.hasTrack ? root.track : i18n("Nothing playing")
                        elide: Text.ElideRight
                        font.bold: true
                    }
                    PlasmaComponents3.Label {
                        Layout.fillWidth: true
                        text: root.hasTrack ? root.artist : i18n("Middle-click dock icon to play/pause")
                        elide: Text.ElideRight
                        opacity: 0.75
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Kirigami.Units.largeSpacing

                PlasmaComponents3.ToolButton {
                    icon.name: "media-skip-backward"
                    enabled: root.player && root.player.canGoPrevious
                    onClicked: root.player.Previous()
                }
                PlasmaComponents3.ToolButton {
                    icon.name: root.isPlaying ? "media-playback-pause" : "media-playback-start"
                    enabled: root.hasPlayer
                    onClicked: root.playPause()
                }
                PlasmaComponents3.ToolButton {
                    icon.name: "media-skip-forward"
                    enabled: root.player && root.player.canGoNext
                    onClicked: root.player.Next()
                }
            }
        }
    }
}
