pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

/**
 * Media service for MPRIS playback status.
 */
Singleton {
    id: root

    property MprisPlayer activePlayer: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    property bool isPlaying: activePlayer?.isPlaying ?? false
    property bool isPaused: activePlayer?.playbackState === MprisPlaybackState.Paused ?? false

    // Update active player when players change
    Connections {
        target: Mpris.players
        function onValuesChanged() {
            root.activePlayer = Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
        }
    }
}