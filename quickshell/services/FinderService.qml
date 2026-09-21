pragma Singleton

import QtQuick
import QtCore as Core
import Quickshell
import Quickshell.Io

import qs.services
import qs.services.finder

/**
 * Finder service: state + search results + execution.
 * The UI (FinderUI) and windows (FinderOverlay) are dumb; everything
 * stateful lives here, following the ToastService pattern.
 *
 * Query grammar (rofi-like):
 *   (nothing)          -> apps (usage-sorted)
 *   arbitrary text     -> fuzzy search across apps
 *   > <command>        -> run shell command
 *   = <expression>     -> calculate locally (built-in evaluator, no external tool)
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
    readonly property string homePath: Core.StandardPaths.standardLocations(Core.StandardPaths.HomeLocation)[0].toString().replace(/^file:\/\//, "")
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

    // ------------------------- math -------------------------
    // Expressions are evaluated in-process by the MathEval singleton
    // (sandboxed parser, no qalc / shell / eval). Nothing to debounce.

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
            const expr = q.slice(1).trim()
            const value = expr ? MathEval.evaluate(expr) : null
            if (value !== null) {
                out.push({
                    key: "math", type: "math",
                    name: "= " + value,
                    hint: expr,
                    verb: "Copy",
                    iconGlyph: "=",
                    execute: () => {
                        Quickshell.clipboardText = value
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

        // -------- empty query: ALL apps (recent first) --------
        if (q === "") {
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

        const appResults = appMatches.slice(0, 30).map(r => root.appResult(r.obj))
        out.push(...appResults)

        // No app matches: stay useful, rofi run/web fallback
        if (appResults.length === 0) {
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

    Component.onCompleted: {
        root.rebuildApps()
    }
}
