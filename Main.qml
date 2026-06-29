import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: config.color

    // Live clock source — updated each second so the displayed minute is
    // always exact (a frozen login clock is an imprecision).
    property var now: new Date()
    Timer { interval: 1000; running: true; repeat: true; onTriggered: root.now = new Date() }

    // ── Background: gruvbox graph-paper dot grid ────────────────────────────
    // Minimalist, reproducible, no raster asset. A quiet mathematician's grid.
    Canvas {
        id: grid
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.fillStyle = config.gridColor || "#32302f"
            var step = 48
            for (var x = step; x < width; x += step) {
                for (var y = step; y < height; y += step) {
                    ctx.beginPath()
                    ctx.arc(x, y, 1.1, 0, 2 * Math.PI)
                    ctx.fill()
                }
            }
        }
    }

    Item {
        anchors.fill: parent

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 30

            // ── Time / date ─────────────────────────────────────────────────
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 6

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatTime(root.now, "HH:mm")
                    color: config.clockColor
                    font.family: config.clockFont
                    font.pixelSize: parseInt(config.clockFontSize) || 72
                    font.bold: true
                }

                // Thin accent rule — echoes the gruvbox aurorae titlebar accent.
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 96
                    height: 2
                    radius: 1
                    color: config.accentColor
                    opacity: 0.85
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    // ISO 8601 date + weekday — precision over locale prose.
                    text: Qt.formatDate(root.now, "yyyy-MM-dd") + "  ·  " +
                          Qt.formatDate(root.now, "dddd")
                    color: config.dateColor
                    font.family: config.dateFont
                    font.pixelSize: parseInt(config.dateFontSize) || 20
                }
            }

            // ── Login panel ─────────────────────────────────────────────────
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 400
                implicitHeight: loginContent.implicitHeight + 60
                color: "#e6282828"
                radius: 12
                border.color: config.loginBorder
                border.width: 1

                ColumnLayout {
                    id: loginContent
                    anchors.centerIn: parent
                    width: parent.width * 0.85
                    spacing: 20

                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 8

                        Image {
                            Layout.alignment: Qt.AlignHCenter
                            source: "icons/fedora.svg"
                            sourceSize.width: 44
                            sourceSize.height: 44
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Fedora KDE"
                            color: config.passwordColor
                            font.family: config.font
                            font.pixelSize: 18
                            font.bold: true
                        }
                    }

                    Item { height: 5 }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        Image {
                            source: "icons/user.svg"
                            sourceSize.width: 24
                            sourceSize.height: 24
                        }
                        ComboBox {
                            id: userCombo
                            Layout.fillWidth: true
                            model: userModel
                            textRole: "name"
                            currentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
                            font.family: config.font
                            font.pixelSize: parseInt(config.fontSize)
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
                                leftPadding: 10
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
                        spacing: 10
                        Image {
                            source: "icons/lock.svg"
                            sourceSize.width: 24
                            sourceSize.height: 24
                        }
                        TextField {
                            id: passwordField
                            Layout.fillWidth: true
                            echoMode: TextInput.Password
                            placeholderText: "Password"
                            font.family: config.font
                            font.pixelSize: parseInt(config.fontSize)
                            color: config.passwordColor
                            background: Rectangle {
                                color: "transparent"
                                border.color: passwordField.activeFocus ? config.accentColor : config.passwordBorder
                                radius: 6
                            }
                            onAccepted: sddm.login(userCombo.currentText, passwordField.text, sessionCombo.currentIndex)
                        }
                    }

                    Item { height: 5 }

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 35
                        text: "LOG IN"
                        font.family: config.font
                        font.pixelSize: parseInt(config.fontSize)
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
                            font.pixelSize: 14
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
            anchors.margins: 30

            ComboBox {
                id: sessionCombo
                model: sessionModel
                textRole: "name"
                currentIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
                font.family: config.font
                font.pixelSize: parseInt(config.fontSize)
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
                    leftPadding: 10
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
                    spacing: 5
                    Image { source: "icons/reboot.svg"; sourceSize.width: 18; sourceSize.height: 18 }
                    Text { text: "Reboot"; color: "#89b482"; font.pixelSize: parseInt(config.fontSize) }
                }
            }

            Item { width: 10 }

            Button {
                onClicked: sddm.powerOff()
                background: Rectangle { color: "transparent" }
                contentItem: RowLayout {
                    spacing: 5
                    Image { source: "icons/power.svg"; sourceSize.width: 18; sourceSize.height: 18 }
                    Text { text: "Shutdown"; color: "#ea6962"; font.pixelSize: parseInt(config.fontSize) }
                }
            }
        }
    }
}
