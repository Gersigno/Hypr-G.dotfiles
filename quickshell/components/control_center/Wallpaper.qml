import QtQuick
import QtQuick.Controls
import Quickshell.Widgets
import QtCore as Core
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io

import "../../utils"
import qs.services

Item {
    id: root

    implicitWidth: 500
    implicitHeight: 155

    // Path returned by get_wallpaper.sh, stored while the model may still be loading
    property string pendingWallpaperPath: ""

    function trySetWallpaperIndex(path) {
        if (path === "" || wallpaperModel.count === 0) return
        for (let i = 0; i < wallpaperModel.count; i++) {
            const fileUrl = wallpaperModel.get(i, "fileUrl")
            if (fileUrl.toString().replace(/^file:\/\//, "") === path) {
                carousel.currentIndex = i
                pendingWallpaperPath = ""
                return
            }
        }
    }

    // Reads the current wallpaper path and sets the carousel index accordingly
    Process {
        id: getWallpaperProcess
        running: true
        command: ["/bin/bash", Core.StandardPaths.standardLocations(Core.StandardPaths.HomeLocation)[0].toString().replace(/^file:\/\//, "") + "/.config/quickshell/scripts/get_wallpaper.sh"]

        property string accumulatedOutput: ""

        stdout: SplitParser {
            onRead: data => {
                getWallpaperProcess.accumulatedOutput += data
            }
        }

        onRunningChanged: {
            if (!running) {
                root.pendingWallpaperPath = accumulatedOutput.trim()
                accumulatedOutput = ""
                root.trySetWallpaperIndex(root.pendingWallpaperPath)
            }
        }
    }

    Process {
        id: wallpaperProcess
        running: false
    }

    // Image files model from wallpapersPath
    FolderListModel {
        id: wallpaperModel
        folder: Settings.wallpapersPath
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.bmp", "*.gif", "*.tiff", "*.tif"]
        showDirs: false
        sortField: FolderListModel.Name
        // If the model finishes loading after the process, set the index now
        onCountChanged: root.trySetWallpaperIndex(root.pendingWallpaperPath)
    }

    //Fallback text if no file found
    Text {
        anchors.centerIn: parent
        text: "No wallpapers found in " + Settings.wallpapersPath
        color: "white"
        font.family: Settings.fontFamily
        font.pixelSize: 12
        visible: wallpaperModel.count === 0
    }

    Item {
        anchors.fill: parent
        anchors.centerIn: parent
        anchors.margins: 16
        //spacing: 8

        height: parent.height
        width: parent.width

        // Carousel
        ListView {
            id: carousel
            width: parent.width
            height: parent.height
            orientation: ListView.Horizontal
            clip: true
            model: wallpaperModel
            spacing: 10
            //leftMargin: 16
            //rightMargin: 16
            snapMode: ListView.SnapToItem
            //color: "red"

            //vertical align to center
            anchors.verticalCenter: parent.verticalCenter

            delegate: Item {
                required property string fileUrl
                required property string fileName
                required property int index

                width: 160
                height: 120//carousel.height

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: (carousel.currentIndex === index) ? Colors.primary : Qt.rgba(1,1,1,0.08)
                    clip: true

                    ClippingRectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: parent.radius - 2

                        color: "transparent"

                        Image {
                            anchors.fill: parent
                            source: fileUrl
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                            asynchronous: true
                            layer.enabled: true
                            layer.effect: null
                        }
                    }
                    /*Image {
                        anchors.fill: parent
                        anchors.margins: 2
                        source: fileUrl
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        asynchronous: true
                        layer.enabled: true
                        layer.effect: null
                    }*/

                    // Filename label at the bottom
                    /*Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 28
                        radius: 0
                        color: "#88000000"

                        Text {
                            anchors.centerIn: parent
                            width: parent.width - 8
                            text: fileName
                            color: "white"
                            font.pixelSize: 10
                            font.family: Settings.fontFamily
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }*/

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            carousel.currentIndex = index
                            console.log("carousel index: " +carousel.currentIndex + " defined index: " + index)
                            const path = fileUrl.toString().replace(/^file:\/\//, "")
                            const command = ["/bin/bash", Core.StandardPaths.standardLocations(Core.StandardPaths.HomeLocation)[0].toString().replace(/^file:\/\//, "") + "/.config/quickshell/scripts/set_wallpaper.sh", path]
                            wallpaperProcess.command = command
                            wallpaperProcess.running = true
                            ToastService.show("Wallpaper applied", 4000, "../../../assets/icons/wallpaper.png")
                        }
                    }
                }
            }
        }
    }
}