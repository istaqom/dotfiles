/*
    Like Breeze UserList, but uses CozyUserDelegate (octagon / logo-shaped avatar).
*/
pragma ComponentBehavior: Bound

import QtQuick
import org.kde.kirigami as Kirigami

ListView {
    id: view
    readonly property string selectedUser: currentItem ? currentItem.userName : ""
    readonly property int userItemWidth: Kirigami.Units.gridUnit * 9
    readonly property int userItemHeight: Kirigami.Units.gridUnit * 10
    readonly property bool constrainText: count > 1
    property real fontSize: Kirigami.Theme.defaultFont.pointSize + 2

    implicitHeight: userItemHeight
    activeFocusOnTab: true
    signal userSelected()

    orientation: ListView.Horizontal
    highlightRangeMode: ListView.StrictlyEnforceRange
    preferredHighlightBegin: width / 2 - userItemWidth / 2
    preferredHighlightEnd: preferredHighlightBegin
    interactive: count > 1

    delegate: CozyUserDelegate {
        id: userDelegate
        required property int index
        required property string icon
        required property string realName
        required property var model
        avatarPath: icon || ""
        iconSource: model.iconName || "user-identity"
        fontSize: view.fontSize
        needsPassword: model.needsPassword !== undefined ? model.needsPassword : true

        name: {
            const displayName = realName || model.name
            if (model.vtNumber === undefined || model.vtNumber < 0) {
                return displayName
            }
            if (!model.session) {
                return i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Nobody logged in on that session", "Unused")
            }
            let location = undefined
            if (model.isTty) {
                location = i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "User logged in on console number", "TTY %1", model.vtNumber)
            } else if (model.displayNumber) {
                location = i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "User logged in on console (X display number)", "on TTY %1 (Display %2)", model.vtNumber, model.displayNumber)
            }
            if (location !== undefined) {
                return i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Username (location)", "%1 (%2)", displayName, location)
            }
            return displayName
        }

        userName: model.name
        width: view.userItemWidth
        height: view.userItemHeight
        constrainText: view.constrainText
        isCurrent: ListView.isCurrentItem

        onClicked: {
            view.currentIndex = index
            view.userSelected()
        }
    }

    Keys.onEscapePressed: view.userSelected()
    Keys.onEnterPressed: view.userSelected()
    Keys.onReturnPressed: view.userSelected()
}
