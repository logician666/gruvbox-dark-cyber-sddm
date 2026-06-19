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
                    model: sddm.userModel
                    textRole: "name"
                    currentIndex: sddm.userModel.lastIndex
                    font.family: config.font
                    font.pixelSize: parseInt(config.fontSize)
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
                model: sddm.sessionModel
                textRole: "name"
                currentIndex: sddm.sessionModel.lastIndex
                font.family: config.font
                font.pixelSize: parseInt(config.fontSize)
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
