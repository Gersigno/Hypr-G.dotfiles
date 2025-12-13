pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick

QtObject {
    property bool controlCenterOpen: false
    
    // Global theming
    property color backgroundColor: "#000000"
    property int cornerRadius: 10
    property int gapsOut: 8
}