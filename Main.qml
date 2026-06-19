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
        opacity: 0.3
    }

    Item {
        anchors.fill: parent

        // Time and Date
        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 100
            spacing: 10

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatTime(new Date(), "hh:mm")
                color: config.clockColor
                font.family: config.clockFont
                font.pixelSize: parseInt(config.clockFontSize)
                font.bold: true
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDate(new Date(), Qt.DefaultLocaleLongDate)
                color: config.dateColor
                font.family: config.dateFont
                font.pixelSize: parseInt(config.dateFontSize)
            }
        }

        // Login Panel
        Rectangle {
            anchors.centerIn: parent
            width: 400
            height: 300
            color: "#d9282828" // Gruvbox dark with alpha
            radius: 8
            border.color: config.loginBorder
            border.width: 2

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width * 0.8
                spacing: 20

                ComboBox {
                    id: userCombo
                    Layout.fillWidth: true
                    model: userModel
                    textRole: "name"
                    currentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
                    font.family: config.font
                    font.pixelSize: parseInt(config.fontSize)
                    background: Rectangle {
                        color: config.passwordBackground
                        border.color: config.passwordBorder
                        radius: 4
                    }
                    contentItem: Text {
                        text: userCombo.displayText
                        color: config.passwordColor
                        font: userCombo.font
                        verticalAlignment: Text.AlignVCenter
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
                        implicitHeight: contentItem.implicitHeight
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
                            radius: 4
                        }
                    }
                }

                TextField {
                    id: passwordField
                    Layout.fillWidth: true
                    echoMode: TextInput.Password
                    placeholderText: "Password..."
                    font.family: config.font
                    font.pixelSize: parseInt(config.fontSize)
                    color: config.passwordColor
                    background: Rectangle {
                        color: config.passwordBackground
                        border.color: passwordField.activeFocus ? "#d79921" : config.passwordBorder
                        radius: 4
                    }
                    onAccepted: sddm.login(userCombo.currentText, passwordField.text, sessionCombo.currentIndex)
                }

                Button {
                    Layout.fillWidth: true
                    text: "Login"
                    font.family: config.font
                    font.pixelSize: parseInt(config.fontSize)
                    onClicked: sddm.login(userCombo.currentText, passwordField.text, sessionCombo.currentIndex)
                    background: Rectangle {
                        color: parent.down ? "#98971a" : "#b8bb26"
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#282828"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
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
                    implicitHeight: contentItem.implicitHeight
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
                text: "Reboot"
                onClicked: sddm.reboot()
                background: Rectangle {
                    color: "transparent"
                    border.color: "#83a598"
                    radius: 4
                }
                contentItem: Text {
                    text: parent.text
                    color: "#83a598"
                }
            }
            Button {
                text: "Shutdown"
                onClicked: sddm.powerOff()
                background: Rectangle {
                    color: "transparent"
                    border.color: "#cc241d"
                    radius: 4
                }
                contentItem: Text {
                    text: parent.text
                    color: "#cc241d"
                }
            }
        }
    }
}
