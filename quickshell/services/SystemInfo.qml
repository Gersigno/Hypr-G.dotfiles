pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string osRelease: osReleaseFile.text()

    readonly property string distroId: {
        const match = root.osRelease.match(/^ID="?([^"\n]+)"?/m);
        return match ? match[1].trim().toLowerCase() : "";
    }

    readonly property string distroName: {
        const match = root.osRelease.match(/^PRETTY_NAME="?([^"\n]+)"?/m);
        return match ? match[1].trim() : root.distroId;
    }

    readonly property var distroIcons: ({
        "almalinux": "\uf31d",
        "alpine": "\uf300",
        "aosc": "\uf301",
        "arch": "\uf303",
        "archarm": "\uf303",
        "archcraft": "\uf345",
        "arcolinux": "\uf346",
        "artix": "\uf31f",
        "biglinux": "\uf347",
        "cachyos": "\uf385",
        "centos": "\uf304",
        "debian": "\uf306",
        "deepin": "\uf321",
        "devuan": "\uf307",
        "elementary": "\uf309",
        "endeavouros": "\uf322",
        "fedora": "\uf30a",
        "freebsd": "\uf30c",
        "garuda": "\uf337",
        "gentoo": "\uf30d",
        "guix": "\uf325",
        "hyperbola": "\uf33a",
        "kali": "\uf327",
        "kde-neon": "\uf331",
        "kubuntu": "\uf333",
        "linuxmint": "\uf30e",
        "mageia": "\uf310",
        "manjaro": "\uf312",
        "mx": "\uf33f",
        "neon": "\uf331",
        "nixos": "\uf313",
        "nobara": "\uf380",
        "openbsd": "\uf328",
        "opensuse": "\uf314",
        "opensuse-leap": "\uf314",
        "opensuse-tumbleweed": "\uf314",
        "openwrt": "\uf382",
        "parabola": "\uf340",
        "parrot": "\uf329",
        "pop": "\uf32a",
        "postmarketos": "\uf374",
        "qubes": "\uf342",
        "raspbian": "\uf315",
        "redhat": "\uf316",
        "rhel": "\uf316",
        "rocky": "\uf32b",
        "slackware": "\uf318",
        "solus": "\uf32d",
        "suse": "\uf314",
        "tails": "\uf343",
        "trisquel": "\uf344",
        "ubuntu": "\uf31b",
        "vanilla": "\uf366",
        "void": "\uf32e",
        "zorin": "\uf32f"
    })

    readonly property string distroIcon: {
        if (root.distroIcons[root.distroId])
            return root.distroIcons[root.distroId];

        const likes = root.osRelease.match(/^ID_LIKE="?([^"\n]+)"?/m);
        if (likes) {
            for (const id of likes[1].trim().toLowerCase().split(/\s+/)) {
                if (root.distroIcons[id])
                    return root.distroIcons[id];
            }
        }

        return "\uf31a"; // Tux
    }

    FileView {
        id: osReleaseFile
        path: "/etc/os-release"
        blockLoading: true
        printErrors: false
    }
}
