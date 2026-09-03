pragma Singleton

import QtQuick
import QtCore
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import qs.services
import qs.services.finder

/**
 * Finder service: state + search results + execution.
 * The UI (FinderUI) and windows (FinderOverlay) are dumb; everything
 * stateful lives here, following the ToastService pattern.
 *
 * Query grammar (rofi-like):
 *   (nothing)          -> apps (usage-sorted) + open windows
 *   arbitrary text     -> fuzzy search across apps and windows
 *   > <command>        -> run shell command
 *   = <expression>     -> calculate with qalc (if installed)
 *   ? <phrase>         -> web search
 *   : <action>         -> finder/search actions (dark, light, oled, wallpaper...)
 */
Singleton {
    id: root

    // ------------------------- public state -------------------------
    property bool opened: false
    property string query: ""

    signal openRequested()
    signal closeRequested()
    signal toggleRequested()

    function open() {
        root.query = ""
        root.opened = true
        root.openRequested()
    }

    function close() {
        root.opened = false
        root.closeRequested()
    }

    function toggle() {
        root.opened ? root.close() : root.open()
    }

    // ------------------------- execution -------------------------
    function execute(result) {
        if (result == null || result.execute == null)
            return
        root.close()
        result.execute()
    }

    // ------------------------- history (app usage) -------------------------
    readonly property string homePath: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0].toString().replace(/^file:\/\//, "")
    readonly property string historyPath: homePath + "/.config/quickshell/finder.json"

    FileView {
        id: historyFile
        path: root.historyPath
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: setText("{}")

        JsonAdapter {
            id: adapter
            property string historyJson: "{}"
        }
    }

    function historyMap() {
        try {
            return JSON.parse(adapter.historyJson) ?? {}
        } catch (e) {
            return {}
        }
    }

    function historyCount(appId) {
        if (!appId) return 0
        const h = historyMap()
        return h[appId] ? Math.min(h[appId], 9999) : 0
    }

    function bumpApp(appId) {
        if (!appId) return
        const h = historyMap()
        h[appId] = (h[appId] ?? 0) + 1
        const entries = Object.entries(h).sort((a, b) => b[1] - a[1]).slice(0, 200).reduce((acc, e) => {
            acc[e[0]] = e[1]
            return acc
        }, {})
        adapter.historyJson = JSON.stringify(entries)
    }

    // ------------------------- data sources -------------------------
    function toArray(model) {
        if (!model) return []
        if (typeof model.values === "function") return Array.from(model.values())
        if (Array.isArray(model.values)) return model.values
        if (model.values?.length != null) {
            const out = []
            for (let i = 0; i < model.values.length; i++) {
                if (model.values[i] != null)
                    out.push(model.values[i])
            }
            return out
        }
        const out = []
        const len = model.length != null ? model.length : (model.count != null ? model.count : 0)
        for (let i = 0; i < len; i++) out.push(model[i])
        return out
    }

    property var appsCache: []

    function rebuildApps() {
        const arr = toArray(DesktopEntries.applications)
        root.appsCache = arr.filter(a => a && !a.noDisplay).map(a => {
            const searchable = [a.name, a.genericName, (a.comment ?? ""), (a.keywords ?? []).join(" ")].filter(s => s).join(" ")
            return {
                entry: a,
                name: a.name,
                fuzzy: Fuzzy.prepare(searchable),
                fuzzyIcon: Fuzzy.prepare((a.icon ?? "") + " "),
            }
        })
    }

    Connections {
        target: DesktopEntries

        function onApplicationsChanged() {
            root.rebuildApps()
        }
    }

    property var windowsCache: []

    function refreshWindows() {
        let arr = []
        try {
            arr = toArray(Hyprland.toplevels)
        } catch (e) { /* Hyprland not available */ }
        root.windowsCache = arr.filter(t => t && t.address).map(t => {
            const cls = t.lastIpcObject?.class ?? ""
            return {
                title: t.title,
                className: cls,
                address: t.address,
                activated: t.activated,
                icon: t.iconGuess ?? root.windowIcon(cls),
                fuzzyTitle: Fuzzy.prepare((t.title + " " + cls).trim()),
            }
        })
    }

    function windowIcon(cls) {
        if (!cls) return ""
        const direct = DesktopEntries.byId(cls) ?? DesktopEntries.byId(cls.toLowerCase())
        if (direct && direct.icon) return direct.icon
        const heuristic = DesktopEntries.heuristicLookup(cls)
        if (heuristic && heuristic.icon) return heuristic.icon
        return ""
    }

    // Keep window list fresh (title/class changes are frequent, so debounce).
    Connections {
        target: Hyprland

        function onRawEvent() {
            refreshTimer.restart()
        }
    }

    Timer {
        id: refreshTimer
        interval: 150
        repeat: false
        onTriggered: root.refreshWindows()
    }

    // ------------------------- math (qalc) -------------------------
    property string mathValue: ""
    property bool mathQuiet: false

    Timer {
        id: mathDebounce
        interval: 350
        repeat: false
        onTriggered: {
            if (!root.query.startsWith("=") || root.query.length < 2) {
                root.mathValue = ""
                return
            }
            const expr = root.query.slice(1).trim()
            if (!expr) {
                root.mathValue = ""
                return
            }
            mathQuiet = false
            mathProc.command = ["qalc", "-t", expr]
            mathProc.running = false
            mathProc.running = true
        }
    }

    Process {
        id: mathProc
        command: []
        running: false

        stdout: SplitParser {
            onRead: data => {
                if (!root.mathQuiet && data != null && String(data).trim() !== "")
                    root.mathValue = String(data).trim()
            }
        }
        onExited: exitCode => {
            if (exitCode != 0 && root.mathValue == "")
                root.mathQuiet = true
        }
    }

    // ------------------------- actions -------------------------
    readonly property var actions: [
        {
            name: "dark",
            verbose: "Switch to dark theme",
            execute: (args) => {
                if (!Theme.isDarkMode)
                    Theme.toggle()
                ToastService.show("Dark mode" + (Theme.isDarkMode ? " enabled" : ""), 1500)
            }
        },
        {
            name: "light",
            verbose: "Switch to light theme",
            execute: (args) => {
                if (Theme.isDarkMode)
                    Theme.toggle()
                ToastService.show("Light mode" + (!Theme.isDarkMode ? " enabled" : ""), 1500)
            }
        },
        {
            name: "oled",
            verbose: "Toggle OLED background",
            execute: (args) => {
                Settings.isOled = !Settings.isOled
                ToastService.show(Settings.isOled ? "OLED mode enabled" : "OLED mode disabled", 1500)
            }
        },
        {
            name: "wallpaper",
            verbose: "Pick a random wallpaper",
            execute: (args) => {
                const dir = Settings.wallpapersPath
                const script = homePath + "/.config/quickshell/scripts/set_wallpaper.sh"
                const cmd = 'f=$(find "$1" -maxdepth 1 \\( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \\) 2>/dev/null | shuf -n 1); [ -n "$f" ] && bash "$2" "$f"'
                Quickshell.execDetached(["bash", "-c", cmd, "finder", dir, script])
            }
        },
    ]

    // ------------------------- search -------------------------
    readonly property string webEngine: "https://www.google.com/search?q="

    readonly property var results: {
        const q = root.query.trim()
        const out = []

        // -------- prefixes --------
        if (q.startsWith(">")) {
            const cmd = q.slice(1).trim()
            if (cmd) {
                out.push({
                    key: "run", type: "run",
                    name: cmd,
                    hint: "Command",
                    verb: "Run",
                    iconGlyph: "$",
                    execute: () => Quickshell.execDetached(["bash", "-c", cmd]),
                })
            }
            return out
        }

        if (q.startsWith("=")) {
            if (root.mathValue) {
                out.push({
                    key: "math", type: "math",
                    name: "= " + root.mathValue,
                    hint: "Math result",
                    verb: "Copy",
                    iconGlyph: "=",
                    execute: () => {
                        Quickshell.clipboardText = root.mathValue
                        ToastService.show("Math result copied", 1500)
                    },
                })
            }
            return out
        }

        if (q.startsWith("?")) {
            const phrase = q.slice(1).trim()
            if (phrase) {
                out.push({
                    key: "web", type: "web",
                    name: phrase,
                    hint: "Web search",
                    verb: "Search",
                    iconGlyph: "?",
                    execute: () => Qt.openUrlExternally(root.webEngine + encodeURIComponent(phrase)),
                })
            }
            return out
        }

        if (q.startsWith(":")) {
            const needle = q.slice(1).trim().toLowerCase()
            for (const a of root.actions) {
                if (a.name.startsWith(needle) || needle.startsWith(a.name)) {
                    out.push({
                        key: "action:" + a.name, type: "action",
                        name: `:${a.name} ${needle.length > a.name.length ? needle : ""}`.trim(),
                        hint: a.verbose,
                        verb: "Run",
                        iconGlyph: ":",
                        execute: () => a.execute(needle.slice(a.name.length).trim()),
                    })
                }
            }
            return out
        }

        // -------- empty query: windows on top, then ALL apps (recent first) --------
        if (q === "") {
            const wins = root.windowsCache.slice().sort((a, b) => (a.activated ? 0 : 1) - (b.activated ? 0 : 1))
            for (const w of wins) {
                out.push(root.windowResult(w))
            }

            const apps = root.appsCache.slice()
                .map(a => ({ a, count: root.historyCount(a.entry.id) }))
                .sort((x, y) => y.count - x.count || x.a.name.localeCompare(y.a.name))
            for (const { a } of apps) {
                out.push(root.appResult(a))
            }
            return out
        }

        // -------- fuzzy search --------
        const appMatches = Fuzzy.go(q, root.appsCache, { all: true, key: "fuzzy" })
        const winMatches = Fuzzy.go(q, root.windowsCache, { all: true, key: "fuzzyTitle" })

        const appResults = appMatches.slice(0, 30).map(r => root.appResult(r.obj))
        const winResults = winMatches.slice(0, 12).map(r => root.windowResult(r.obj))
        out.push(...appResults)
        out.push(...winResults)

        // No app/window matches: stay useful, rofi run/web fallback
        if (appResults.length === 0 && winResults.length === 0) {
            out.push({
                key: "run", type: "run",
                name: q,
                hint: "Command",
                verb: "Run",
                iconGlyph: "$",
                execute: () => Quickshell.execDetached(["bash", "-c", q]),
            })
        }

        return out
    }

    function appResult(a) {
        return {
            key: "app:" + a.entry.id,
            type: "app",
            name: a.name,
            hint: a.entry.genericName ?? a.entry.comment ?? "Application",
            iconName: a.entry.icon,
            verb: "Open",
            execute: () => {
                root.bumpApp(a.entry.id)
                if (a.entry.runInTerminal && a.entry.command.length > 0)
                    Quickshell.execDetached(["kitty", "--", ...a.entry.command])
                else
                    a.entry.execute()
            },
        }
    }

    function windowResult(w) {
        return {
            key: "window:" + w.address,
            type: "window",
            name: w.title,
            hint: w.className || "Window",
            iconName: w.icon,
            verb: w.activated ? "Focus" : "Switch",
            execute: () => {
                if (Hyprland.usingLua)
                    Hyprland.dispatch(`hl.dsp.focus({ window = "address:${w.address}" })`)
                else
                    Hyprland.dispatch(`focuswindow address:${w.address}`)
            },
        }
    }

    Component.onCompleted: {
        root.refreshWindows()
        root.rebuildApps()
    }

    // Keep math results updating while typing.
    onQueryChanged: mathDebounce.restart()
}
