pragma Singleton

import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

Singleton {
    id: colors

    FileView {
        id: colorFile
        path: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0].toString().replace(/^file:\/\//, "") + "/.config/quickshell/colors.json"
        watchChanges: true
        onFileChanged: reload()
        onTextChanged: {
            const t = colorFile.text()
            if (!t || t.trim() === "") return
            colors._data = colors.parseColors(t)
        }
    }

    function parseColors(text) {
        try {
            const parsed = JSON.parse(text)
            //console.log("[Colors] JSON parsed successfully, keys:", Object.keys(parsed).length)
            return parsed
        } catch(e) {
            console.warn("[Colors] Failed to parse colors.json:", e)
            return {}
        }
    }

    // Populated on load and on every file change
    property var _data: ({})

    readonly property color background: _data.background ?? "#111318"
    readonly property color error: _data.error ?? "#ffb4ab"
    readonly property color error_container: _data.error_container ?? "#93000a"
    readonly property color inverse_on_surface: _data.inverse_on_surface ?? "#2e3035"
    readonly property color inverse_primary: _data.inverse_primary ?? "#3c6090"
    readonly property color inverse_surface: _data.inverse_surface ?? "#e1e2e9"
    readonly property color on_background: _data.on_background ?? "#e1e2e9"
    readonly property color on_error: _data.on_error ?? "#690005"
    readonly property color on_error_container: _data.on_error_container ?? "#ffdad6"
    readonly property color on_primary: _data.on_primary ?? "#01315e"
    readonly property color on_primary_container: _data.on_primary_container ?? "#d4e3ff"
    readonly property color on_primary_fixed: _data.on_primary_fixed ?? "#001c3a"
    readonly property color on_primary_fixed_variant: _data.on_primary_fixed_variant ?? "#224876"
    readonly property color on_secondary: _data.on_secondary ?? "#273141"
    readonly property color on_secondary_container: _data.on_secondary_container ?? "#d8e3f8"
    readonly property color on_secondary_fixed: _data.on_secondary_fixed ?? "#111c2b"
    readonly property color on_secondary_fixed_variant: _data.on_secondary_fixed_variant ?? "#3d4758"
    readonly property color on_surface: _data.on_surface ?? "#e1e2e9"
    readonly property color on_surface_variant: _data.on_surface_variant ?? "#c3c6cf"
    readonly property color on_tertiary: _data.on_tertiary ?? "#3d2846"
    readonly property color on_tertiary_container: _data.on_tertiary_container ?? "#f7d8ff"
    readonly property color on_tertiary_fixed: _data.on_tertiary_fixed ?? "#271430"
    readonly property color on_tertiary_fixed_variant: _data.on_tertiary_fixed_variant ?? "#553f5d"
    readonly property color outline: _data.outline ?? "#8d9199"
    readonly property color outline_variant: _data.outline_variant ?? "#43474e"
    readonly property color primary: _data.primary ?? "#a6c8ff"
    readonly property color primary_container: _data.primary_container ?? "#224876"
    readonly property color primary_fixed: _data.primary_fixed ?? "#d4e3ff"
    readonly property color primary_fixed_dim: _data.primary_fixed_dim ?? "#a6c8ff"
    readonly property color scrim: _data.scrim ?? "#000000"
    readonly property color secondary: _data.secondary ?? "#bcc7dc"
    readonly property color secondary_container: _data.secondary_container ?? "#3d4758"
    readonly property color secondary_fixed: _data.secondary_fixed ?? "#d8e3f8"
    readonly property color secondary_fixed_dim: _data.secondary_fixed_dim ?? "#bcc7dc"
    readonly property color shadow: _data.shadow ?? "#000000"
    readonly property color source_color: _data.source_color ?? "#357fd5"
    readonly property color surface: _data.surface ?? "#111318"
    readonly property color surface_bright: _data.surface_bright ?? "#37393e"
    readonly property color surface_container: _data.surface_container ?? "#1d2024"
    readonly property color surface_container_high: _data.surface_container_high ?? "#282a2f"
    readonly property color surface_container_highest: _data.surface_container_highest ?? "#32353a"
    readonly property color surface_container_low: _data.surface_container_low ?? "#191c20"
    readonly property color surface_container_lowest: _data.surface_container_lowest ?? "#0c0e13"
    readonly property color surface_dim: _data.surface_dim ?? "#111318"
    readonly property color surface_tint: _data.surface_tint ?? "#a6c8ff"
    readonly property color surface_variant: _data.surface_variant ?? "#43474e"
    readonly property color tertiary: _data.tertiary ?? "#dabde2"
    readonly property color tertiary_container: _data.tertiary_container ?? "#553f5d"
    readonly property color tertiary_fixed: _data.tertiary_fixed ?? "#f7d8ff"
    readonly property color tertiary_fixed_dim: _data.tertiary_fixed_dim ?? "#dabde2"
}