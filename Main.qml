import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: config.color

    Image {
        id: background
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.4
    }

    Item {
        anchors.fill: parent

        // Time and Date
        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 120
            spacing: 5

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatTime(new Date(), "hh:mm")
                color: config.clockColor
                font.family: config.clockFont
                font.pixelSize: parseInt(config.clockFontSize) || 64
                font.bold: true
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDate(new Date(), Qt.DefaultLocaleLongDate)
                color: config.dateColor
                font.family: config.dateFont
                font.pixelSize: parseInt(config.dateFontSize) || 24
            }
        }

        // Login Panel
        Rectangle {
            anchors.centerIn: parent
            width: 450
            height: 350
            color: "#d9282828" // Gruvbox dark with alpha
            radius: 12
            border.color: config.loginBorder
            border.width: 1

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width * 0.85
                spacing: 20

                // User Row
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

                // Password Row
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
                            border.color: passwordField.activeFocus ? "#d79921" : config.passwordBorder
                            radius: 6
                        }
                        onAccepted: sddm.login(userCombo.currentText, passwordField.text, sessionCombo.currentIndex)
                    }
                }

                Item { height: 10 } // Spacer

                // Login Button
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    text: "LOG IN"
                    font.family: config.font
                    font.pixelSize: parseInt(config.fontSize)
                    onClicked: sddm.login(userCombo.currentText, passwordField.text, sessionCombo.currentIndex)
                    background: Rectangle {
                        color: parent.down ? "#d79921" : "#fabd2f" // Bright yellow Gruvbox
                        radius: 6
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#282828"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                        font.pixelSize: 16
                    }
                }
            }
        }

        // Bottom Controls
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
            
            Item { Layout.fillWidth: true } // Spacer
            
            Button {
                onClicked: sddm.reboot()
                background: Rectangle { color: "transparent" }
                contentItem: RowLayout {
                    spacing: 5
                    Image { source: "icons/reboot.svg"; sourceSize.width: 18; sourceSize.height: 18 }
                    Text { text: "Reboot"; color: "#83a598"; font.pixelSize: parseInt(config.fontSize) }
                }
            }
            
            Item { width: 10 }
            
            Button {
                onClicked: sddm.powerOff()
                background: Rectangle { color: "transparent" }
                contentItem: RowLayout {
                    spacing: 5
                    Image { source: "icons/power.svg"; sourceSize.width: 18; sourceSize.height: 18 }
                    Text { text: "Shutdown"; color: "#cc241d"; font.pixelSize: parseInt(config.fontSize) }
                }
            }
        }
    }
}
