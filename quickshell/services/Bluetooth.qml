pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property bool available: Bluetooth.adapters.values.length > 0
    readonly property bool enabled: Bluetooth.defaultAdapter?.enabled ?? false
    readonly property BluetoothDevice firstActiveDevice: Bluetooth.defaultAdapter?.devices.values.find(device => device.connected) ?? null
    readonly property int activeDeviceCount: Bluetooth.defaultAdapter?.devices.values.filter(device => device.connected).length ?? 0
    readonly property bool connected: Bluetooth.devices.values.some(d => d.connected)

    readonly property bool discovering: Bluetooth.defaultAdapter?.discovering ?? false

    function toggleBluetooth(): void {
        if (Bluetooth.defaultAdapter)
            Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
    }

    function trustDevice(address: string): void {
        Quickshell.execDetached(["bluetoothctl", "trust", address])
    }

    function untrustDevice(address: string): void {
        Quickshell.execDetached(["bluetoothctl", "untrust", address])
    }

    function startDiscovery(): void {
        if (Bluetooth.defaultAdapter) {
            Bluetooth.defaultAdapter.discovering = true
            discoveryTimer.restart()
        }
    }

    function stopDiscovery(): void {
        if (Bluetooth.defaultAdapter) {
            Bluetooth.defaultAdapter.discovering = false
            discoveryTimer.stop()
        }
    }

    Timer {
        id: discoveryTimer
        interval: 10000
        onTriggered: {
            if (Bluetooth.defaultAdapter)
                Bluetooth.defaultAdapter.discovering = false
        }
    }

    function sortFunction(a, b) {
        // Ones with meaningful names before MAC addresses
        const macRegex = /^([0-9A-Fa-f]{2}-){5}[0-9A-Fa-f]{2}$/;
        const aIsMac = macRegex.test(a.name);
        const bIsMac = macRegex.test(b.name);
        if (aIsMac !== bIsMac)
            return aIsMac ? 1 : -1;

        // Alphabetical by name
        return a.name.localeCompare(b.name);
    }
    property var connectedDevices: Bluetooth.devices.values.filter(d => d.connected).sort(sortFunction)
    property var pairedButNotConnectedDevices: Bluetooth.devices.values.filter(d => d.paired && !d.connected).sort(sortFunction)
    property var unpairedDevices: Bluetooth.devices.values.filter(d => !d.paired && !d.connected).sort(sortFunction)
    property var friendlyDeviceList: [
        ...connectedDevices,
        ...pairedButNotConnectedDevices,
        ...unpairedDevices
    ]
}