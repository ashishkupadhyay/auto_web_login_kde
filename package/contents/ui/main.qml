import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.private.vitportal 1.0

PlasmoidItem {
    id: root

    readonly property int headerToolIconSize: Kirigami.Units.iconSizes.small
    // Minimum flyout size (user resize cannot go smaller). Default open size matches this.
    readonly property int flyoutEdge: Kirigami.Units.largeSpacing
    readonly property int flyoutMinWidth: Kirigami.Units.gridUnit * 14
    readonly property int flyoutMinHeight: Kirigami.Units.gridUnit * 14
    readonly property int gapAfterHeading: Kirigami.Units.largeSpacing
    readonly property int gapPasswordToSave: Kirigami.Units.largeSpacing

    toolTipMainText: qsTr("VIT Vellore captive portal")
    toolTipSubText: portal.vitWifi ? qsTr("Vellore campus Wi‑Fi detected") : qsTr("Not on Vellore campus Wi‑Fi")

    VitPortalController {
        id: portal
    }

    Timer {
        id: autoLoginTimer
        interval: 2200
        repeat: false
        onTriggered: {
            if (!Plasmoid.configuration.onboardingComplete) {
                return
            }
            const u = Plasmoid.configuration.username
            const p = Plasmoid.configuration.password
            if (u.length > 0 && p.length > 0 && portal.vitWifi && !portal.busy) {
                portal.login(u, p)
            }
        }
    }

    Connections {
        target: portal
        function onSsidChanged() {
            if (portal.vitWifi && Plasmoid.configuration.onboardingComplete) {
                autoLoginTimer.restart()
            }
        }
    }

    // Kirigami.Icon can swallow clicks in compactRepresentation (Plasma bug 518024);
    // a child MouseArea toggles the flyout like DefaultCompactRepresentation.qml.
    compactRepresentation: Kirigami.Icon {
        implicitWidth: Kirigami.Units.iconSizes.smallMedium
        implicitHeight: Kirigami.Units.iconSizes.smallMedium
        source: Qt.resolvedUrl("../images/wifi-portal.svg")
        isMask: true
        color: Kirigami.Theme.textColor
        active: compactMouse.containsMouse
        activeFocusOnTab: true

        Accessible.name: root.toolTipMainText
        Accessible.role: Accessible.Button
        Accessible.description: root.toolTipSubText

        Keys.onPressed: event => {
            switch (event.key) {
            case Qt.Key_Space:
            case Qt.Key_Enter:
            case Qt.Key_Return:
            case Qt.Key_Select:
                Plasmoid.activated()
                event.accepted = true
                break
            }
        }

        MouseArea {
            id: compactMouse
            anchors.fill: parent
            hoverEnabled: true
            property bool wasExpanded: false
            onPressed: wasExpanded = root.expanded
            onClicked: mouse => {
                if (mouse.button === Qt.MiddleButton) {
                    Plasmoid.secondaryActivated()
                } else {
                    root.expanded = !wasExpanded
                }
            }
        }
    }

    fullRepresentation: PlasmaExtras.Representation {
        id: flyoutRepresentation

        collapseMarginsHint: true

        Layout.minimumWidth: root.flyoutMinWidth
        Layout.minimumHeight: root.flyoutMinHeight
        implicitWidth: root.flyoutMinWidth
        implicitHeight: Math.max(root.flyoutMinHeight, contentColumn.implicitHeight + root.flyoutEdge + root.flyoutEdge)

        // Page content is otherwise vertically centered; anchor the column to the top.
        contentItem: Item {
            ColumnLayout {
                id: contentColumn
                spacing: Kirigami.Units.mediumSpacing
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: root.flyoutEdge
                anchors.rightMargin: root.flyoutEdge
                anchors.topMargin: root.flyoutEdge

                ColumnLayout {
                    visible: !Plasmoid.configuration.onboardingComplete
                    spacing: Kirigami.Units.mediumSpacing
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop

                    Kirigami.Heading {
                        level: 4
                        text: qsTr("VIT Vellore Wi‑Fi portal")
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                        Layout.bottomMargin: root.gapAfterHeading
                    }

                    QQC2.Label {
                        text: qsTr("Username")
                        Layout.fillWidth: true
                        font: Kirigami.Theme.smallFont
                        color: Kirigami.Theme.textColor
                    }

                QQC2.TextField {
                    id: onboardingUser
                    Layout.fillWidth: true
                }

                QQC2.Label {
                    text: qsTr("Password")
                    Layout.fillWidth: true
                    font: Kirigami.Theme.smallFont
                    color: Kirigami.Theme.textColor
                }

                QQC2.TextField {
                    id: onboardingPassword
                    echoMode: QQC2.TextField.Password
                    Layout.fillWidth: true
                }

                PlasmaComponents.Button {
                    Layout.fillWidth: true
                    Layout.topMargin: root.gapPasswordToSave
                    text: qsTr("Save and continue")
                    enabled: onboardingUser.text.length > 0 && onboardingPassword.text.length > 0
                    onClicked: {
                        Plasmoid.configuration.username = onboardingUser.text
                        Plasmoid.configuration.password = onboardingPassword.text
                        Plasmoid.configuration.onboardingComplete = true
                        if (portal.vitWifi) {
                            autoLoginTimer.restart()
                        }
                    }
                }
            }

            ColumnLayout {
                visible: Plasmoid.configuration.onboardingComplete
                spacing: Kirigami.Units.mediumSpacing
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop

                RowLayout {
                    id: headerRow
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    Layout.bottomMargin: root.gapAfterHeading
                    spacing: Kirigami.Units.smallSpacing

                    Kirigami.Heading {
                        level: 5
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        Layout.alignment: Qt.AlignTop
                        horizontalAlignment: Text.AlignLeft
                        elide: Text.ElideRight
                        wrapMode: Text.NoWrap
                        text: portal.ssid.length > 0 ? portal.ssid : qsTr("Not connected")
                    }

                    QQC2.ToolButton {
                        id: accountSettingsButton
                        Layout.alignment: Qt.AlignTop | Qt.AlignRight
                        flat: true
                        padding: Kirigami.Units.smallSpacing / 2
                        implicitWidth: root.headerToolIconSize + padding * 2
                        implicitHeight: root.headerToolIconSize + padding * 2
                        display: QQC2.AbstractButton.IconOnly
                        text: ""
                        Accessible.name: qsTr("Account settings")
                        onClicked: portal.openAccountSettings()
                        contentItem: Kirigami.Icon {
                            width: root.headerToolIconSize
                            height: root.headerToolIconSize
                            anchors.centerIn: parent
                            source: Qt.resolvedUrl("../images/person-settings.svg")
                            isMask: true
                            color: Kirigami.Theme.textColor
                        }
                    }

                    QQC2.ToolButton {
                        id: resetSetupButton
                        Layout.alignment: Qt.AlignTop | Qt.AlignRight
                        flat: true
                        padding: Kirigami.Units.smallSpacing / 2
                        implicitWidth: root.headerToolIconSize + padding * 2
                        implicitHeight: root.headerToolIconSize + padding * 2
                        display: QQC2.AbstractButton.IconOnly
                        text: ""
                        Accessible.name: qsTr("Reset setup")
                        onClicked: {
                            Plasmoid.configuration.username = ""
                            Plasmoid.configuration.password = ""
                            Plasmoid.configuration.onboardingComplete = false
                            onboardingUser.text = ""
                            onboardingPassword.text = ""
                            portal.clearLastMessage()
                        }
                        contentItem: Kirigami.Icon {
                            width: root.headerToolIconSize
                            height: root.headerToolIconSize
                            anchors.centerIn: parent
                            source: Qt.resolvedUrl("../images/wifi-reset.svg")
                            isMask: true
                            color: Kirigami.Theme.textColor
                        }
                    }
                }

                // Stacked vertically (never side by side)
                QQC2.Button {
                    id: loginButton
                    Layout.fillWidth: true
                    text: qsTr("Login")
                    enabled: !portal.busy
                        && Plasmoid.configuration.username.length > 0
                        && Plasmoid.configuration.password.length > 0
                    topPadding: Kirigami.Units.smallSpacing * 2
                    bottomPadding: Kirigami.Units.smallSpacing * 2
                    leftPadding: Kirigami.Units.largeSpacing
                    rightPadding: Kirigami.Units.largeSpacing
                    onClicked: portal.login(Plasmoid.configuration.username, Plasmoid.configuration.password)

                    background: Rectangle {
                        implicitHeight: Kirigami.Units.gridUnit * 2.5
                        radius: height * 0.5
                        color: Kirigami.Theme.positiveBackgroundColor
                        border.color: Qt.darker(Kirigami.Theme.positiveBackgroundColor, 1.15)
                        border.width: 1
                        opacity: loginButton.enabled ? 1 : 0.45
                    }

                    contentItem: QQC2.Label {
                        text: loginButton.text
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: Kirigami.Theme.positiveTextColor
                    }
                }

                QQC2.Button {
                    id: logoutButton
                    Layout.fillWidth: true
                    text: qsTr("Logout")
                    enabled: !portal.busy
                    topPadding: Kirigami.Units.smallSpacing * 2
                    bottomPadding: Kirigami.Units.smallSpacing * 2
                    leftPadding: Kirigami.Units.largeSpacing
                    rightPadding: Kirigami.Units.largeSpacing
                    onClicked: portal.logout()

                    background: Rectangle {
                        implicitHeight: Kirigami.Units.gridUnit * 2.5
                        radius: height * 0.5
                        color: Kirigami.Theme.negativeBackgroundColor
                        border.color: Qt.darker(Kirigami.Theme.negativeBackgroundColor, 1.15)
                        border.width: 1
                        opacity: logoutButton.enabled ? 1 : 0.45
                    }

                    contentItem: QQC2.Label {
                        text: logoutButton.text
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: Kirigami.Theme.negativeTextColor
                    }
                }

                QQC2.Label {
                    Layout.fillWidth: true
                    visible: text.length > 0
                    wrapMode: Text.Wrap
                    font: Kirigami.Theme.smallFont
                    opacity: 0.85
                    color: Kirigami.Theme.textColor
                    text: portal.lastMessage
                }
            }
        }
        }

        Component.onCompleted: {
            onboardingUser.text = Plasmoid.configuration.username
            onboardingPassword.text = Plasmoid.configuration.password
        }
    }
}
