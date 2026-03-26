pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

/**
 * Wallpaper management service for Quickshell.
 * Monitors screen changes and applies the current wallpaper to all screens.
 */
Singleton {
    id: root

    property string currentWallpaper: ""

    // Connections to Hyprland events for monitor changes
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "monitoradded" || event.name === "monitorremoved") {
                console.log(`Monitor event: ${event.name} - ${event.data}`);
                applyWallpaper();
            }
        }
    }

    // Process to get current wallpaper
    Process {
        id: getWallpaperProc
        command: ["/home/gersigno/.config/hypr/hypr-g/scripts/get_wallpaper.sh"]
        onExited: (code, status) => {
            if (code === 0) {
                root.currentWallpaper = stdout.trim();
                console.log("Current wallpaper:", root.currentWallpaper);
            } else {
                console.error("Failed to get wallpaper:", stderr);
            }
        }
    }

    // Process to set wallpaper
    Process {
        id: setWallpaperProc
        onExited: (code, status) => {
            if (code === 0) {
                console.log("Wallpaper applied successfully");
            } else {
                console.error("Failed to set wallpaper:", stderr);
            }
        }
    }

    function applyWallpaper() {
        if (root.currentWallpaper) {
            setWallpaperProc.exec(["/home/gersigno/.config/hypr/hypr-g/scripts/set_wallpaper.sh", root.currentWallpaper]);
        } else {
            // Get current wallpaper first
            getWallpaperProc.exec();
            // Note: In a real implementation, you might want to chain these properly
        }
    }

    // Initialize
    Component.onCompleted: {
        getWallpaperProc.exec();
    }
}