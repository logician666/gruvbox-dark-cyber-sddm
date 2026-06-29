import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: config.color

    // Scale factor — keeps type legible across resolutions (designed at 1080p).
    property real ui: height / 1080

    // Live clock — updated each second so the displayed minute is always exact.
    property var now: new Date()
    Timer { interval: 1000; running: true; repeat: true; onTriggered: root.now = new Date() }

    // ── Background: gruvbox wallpaper + faint graph-paper grid + scrim ───────
    Image {
        id: background
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
    }

    Canvas {
        id: grid
        anchors.fill: parent
        opacity: 0.35
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.fillStyle = config.gridColor || "#3c3836"
            var step = 48 * root.ui
            var r = 1.1 * root.ui
            for (var x = step; x < width; x += step) {
                for (var y = step; y < height; y += step) {
                    ctx.beginPath()
                    ctx.arc(x, y, r, 0, 2 * Math.PI)
                    ctx.fill()
                }
            }
        }
    }

    // Scrim for text legibility over the wallpaper.
    Rectangle {
        anchors.fill: parent
        color: "#282828"
        opacity: 0.45
    }

    Item {
        anchors.fill: parent

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 34 * root.ui

            // ── Time / date ─────────────────────────────────────────────────
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 8 * root.ui

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatTime(root.now, "HH:mm")
                    color: config.clockColor
                    font.family: config.clockFont
                    font.pixelSize: Math.round((parseInt(config.clockFontSize) || 96) * root.ui)
                    font.bold: true
                }

                // Thin accent rule — echoes the gruvbox aurorae titlebar accent.
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 120 * root.ui
                    height: 3 * root.ui
                    radius: height / 2
                    color: config.accentColor
                    opacity: 0.9
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    // ISO 8601 date + weekday — precision over locale prose.
                    text: Qt.formatDate(root.now, "yyyy-MM-dd") + "  ·  " +
                          Qt.formatDate(root.now, "dddd")
                    color: config.dateColor
                    font.family: config.dateFont
                    font.pixelSize: Math.round((parseInt(config.dateFontSize) || 26) * root.ui)
                }
            }

            // ── Login panel ─────────────────────────────────────────────────
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 440 * root.ui
                implicitHeight: loginContent.implicitHeight + 64 * root.ui
                color: "#e6282828"
                radius: 14 * root.ui
                border.color: config.loginBorder
                border.width: 1

                ColumnLayout {
                    id: loginContent
                    anchors.centerIn: parent
                    width: parent.width * 0.85
                    spacing: 22 * root.ui

                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 10 * root.ui

                        Image {
                            Layout.alignment: Qt.AlignHCenter
                            source: "icons/fedora.svg"
                            sourceSize.width: 52 * root.ui
                            sourceSize.height: 52 * root.ui
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Fedora KDE"
                            color: config.passwordColor
                            font.family: config.font
                            font.pixelSize: Math.round(22 * root.ui)
                            font.bold: true
                        }
                    }

                    Item { height: 6 * root.ui }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12 * root.ui
                        Image {
                            source: "icons/user.svg"
                            sourceSize.width: 28 * root.ui
                            sourceSize.height: 28 * root.ui
                        }
                        ComboBox {
                            id: userCombo
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40 * root.ui
                            model: userModel
                            textRole: "name"
                            currentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
                            font.family: config.font
                            font.pixelSize: Math.round(parseInt(config.fontSize) * root.ui)
                            background: Rectangle {
                                color: "transparent"
                                border.color: config.passwordBorder
                                radius: 6
                            }
                            contentItem: Text {
                                text: userCombo.displayText
                                color: config.passwordColor
                                font: userCombo.font
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 12
                                elide: Text.ElideRight
                            }
                            delegate: ItemDelegate {
                                width: userCombo.width
                                contentItem: Text {
                                    text: model.name
                                    color: config.passwordColor
                                    font: userCombo.font
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Rectangle {
                                    color: userCombo.highlightedIndex === index ? config.passwordBorder : config.passwordBackground
                                }
                            }
                            popup: Popup {
                                y: userCombo.height - 1
                                width: userCombo.width
                                padding: 1
                                contentItem: ListView {
                                    clip: true
                                    implicitHeight: contentHeight
                                    model: userCombo.popup.visible ? userCombo.delegateModel : null
                                    currentIndex: userCombo.highlightedIndex
                                }
                                background: Rectangle {
                                    color: config.passwordBackground
                                    border.color: config.passwordBorder
                                    radius: 6
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12 * root.ui
                        Image {
                            source: "icons/lock.svg"
                            sourceSize.width: 28 * root.ui
                            sourceSize.height: 28 * root.ui
                        }
                        TextField {
                            id: passwordField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40 * root.ui
                            echoMode: TextInput.Password
                            placeholderText: "Password"
                            font.family: config.font
                            font.pixelSize: Math.round(parseInt(config.fontSize) * root.ui)
                            color: config.passwordColor
                            background: Rectangle {
                                color: "transparent"
                                border.color: passwordField.activeFocus ? config.accentColor : config.passwordBorder
                                radius: 6
                            }
                            onAccepted: sddm.login(userCombo.currentText, passwordField.text, sessionCombo.currentIndex)
                        }
                    }

                    Item { height: 6 * root.ui }

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44 * root.ui
                        text: "LOG IN"
                        font.family: config.font
                        onClicked: sddm.login(userCombo.currentText, passwordField.text, sessionCombo.currentIndex)
                        background: Rectangle {
                            color: parent.down ? "#b47109" : config.accentColor
                            radius: 6
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#282828"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                            font.pixelSize: Math.round(16 * root.ui)
                        }
                    }
                }
            }
        }

        // ── Bottom controls ─────────────────────────────────────────────────
        RowLayout {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 34 * root.ui
            spacing: 12 * root.ui

            ComboBox {
                id: sessionCombo
                Layout.preferredHeight: 36 * root.ui
                model: sessionModel
                textRole: "name"
                currentIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
                font.family: config.font
                font.pixelSize: Math.round(parseInt(config.fontSize) * root.ui)
                background: Rectangle {
                    color: config.passwordBackground
                    border.color: config.passwordBorder
                    radius: 4
                }
                contentItem: Text {
                    text: sessionCombo.displayText
                    color: config.passwordColor
                    font: sessionCombo.font
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 12
                    elide: Text.ElideRight
                }
                delegate: ItemDelegate {
                    width: sessionCombo.width
                    contentItem: Text {
                        text: model.name
                        color: config.passwordColor
                        font: sessionCombo.font
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: sessionCombo.highlightedIndex === index ? config.passwordBorder : config.passwordBackground
                    }
                }
                popup: Popup {
                    y: sessionCombo.height - 1
                    width: sessionCombo.width
                    padding: 1
                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: sessionCombo.popup.visible ? sessionCombo.delegateModel : null
                        currentIndex: sessionCombo.highlightedIndex
                    }
                    background: Rectangle {
                        color: config.passwordBackground
                        border.color: config.passwordBorder
                        radius: 4
                    }
                }
            }

            Item { Layout.fillWidth: true }

            Button {
                onClicked: sddm.reboot()
                background: Rectangle { color: "transparent" }
                contentItem: RowLayout {
                    spacing: 6 * root.ui
                    Image { source: "icons/reboot.svg"; sourceSize.width: 20 * root.ui; sourceSize.height: 20 * root.ui }
                    Text { text: "Reboot"; color: "#89b482"; font.pixelSize: Math.round(parseInt(config.fontSize) * root.ui) }
                }
            }

            Item { width: 12 * root.ui }

            Button {
                onClicked: sddm.powerOff()
                background: Rectangle { color: "transparent" }
                contentItem: RowLayout {
                    spacing: 6 * root.ui
                    Image { source: "icons/power.svg"; sourceSize.width: 20 * root.ui; sourceSize.height: 20 * root.ui }
                    Text { text: "Shutdown"; color: "#ea6962"; font.pixelSize: Math.round(parseInt(config.fontSize) * root.ui) }
                }
            }
        }
    }
}
