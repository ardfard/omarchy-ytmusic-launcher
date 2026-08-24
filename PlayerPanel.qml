import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

// Control popup for the ytmusic bar widget.
// Shows transport controls for the separate chromium --app window and mirrors
// BarWidget.showing so the open-indicator dot stays in sync.
PopupCard {
  id: root

  property var hostWidget: null
  property var settings: ({})
  property bool appShowing: false
  property string appDataDir: ""
  property string appUrl: "https://music.youtube.com"
  property string appClass: "ytmusic-popup"

  signal requestHide()

  // Mirror the bar widget's showing state via the PopupCard open prop
  // so unfocus dismisses correctly and the dot tracks it.
  // BarWidget drives appShowing; we drive open from it.
  onAppShowingChanged: root.open = appShowing
  onOpenChanged: {
    if (!open && appShowing) requestHide()
  }

  owner: hostWidget || root
  contentWidth: root.fittedContentWidth(Style.space(360))
  contentHeight: root.fittedContentHeight(Style.space(220))
  triggerMode: "click"

  readonly property color foreground: bar ? bar.barForeground : Color.foreground

  Column {
    anchors.fill: parent
    anchors.margins: Style.space(16)
    spacing: Style.space(12)

    Row {
      width: parent.width
      spacing: Style.space(12)
      Text {
        text: "\uf167  YouTube Music"
        color: root.foreground
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.title
        font.bold: true
        verticalAlignment: Text.AlignVCenter
      }
      Item { width: Style.space(8); height: 1 }
      Rectangle {
        width: 10; height: 10; radius: 5
        color: root.appShowing ? "#22c55e" : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.35)
        anchors.verticalCenter: parent.verticalCenter
      }
      Text {
        text: root.appShowing ? "playing" : "hidden"
        color: Qt.darker(root.foreground, 1.5)
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.caption
        anchors.verticalCenter: parent.verticalCenter
      }
    }

    Text {
      width: parent.width
      text: root.appShowing
            ? "Popup closed → window hides but audio keeps playing. Click \uf167 again to show it."
            : "Click \uf167 to show the YouTube Music window."
      color: Qt.darker(root.foreground, 1.4)
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.bodySmall
      wrapMode: Text.WordWrap
    }

    Row {
      width: parent.width
      spacing: Style.space(8)
      anchors.horizontalCenter: parent.horizontalCenter

      Rectangle {
        width: showBtn.implicitWidth + 28
        height: showBtn.implicitHeight + 14
        radius: Style.space(8)
        color: showMouse.containsMouse ? Qt.darker(root.foreground, 1.8) : Qt.darker(root.foreground, 2.2)
        border.color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.25)
        Text {
          id: showBtn
          anchors.centerIn: parent
          text: root.appShowing ? "Hide window" : "Show window"
          color: root.foreground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.bodySmall
        }
        MouseArea {
          id: showMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (root.hostWidget && typeof root.hostWidget.toggle === "function") root.hostWidget.toggle()
            else if (root.bar) root.bar.run(root.appShowing ? ("hyprctl dispatch movetoworkspacesilent special:ytmusic,class:" + root.appClass) : ("chromium --user-data-dir='" + root.appDataDir + "' --app='" + root.appUrl + "' --class=" + root.appClass + " &"))
          }
        }
      }

      Rectangle {
        width: browserBtn.implicitWidth + 28
        height: browserBtn.implicitHeight + 14
        radius: Style.space(8)
        color: browserMouse.containsMouse ? Qt.darker(root.foreground, 1.8) : Qt.darker(root.foreground, 2.2)
        border.color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.25)
        Text {
          id: browserBtn
          anchors.centerIn: parent
          text: "↗ Browser"
          color: root.foreground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.bodySmall
        }
        MouseArea {
          id: browserMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: { if (root.bar) root.bar.run("xdg-open '" + root.appUrl + "'") }
        }
      }
    }

    Text {
      width: parent.width
      text: "Tip: right-click \uf167 in the bar also opens in your default browser."
      color: Qt.darker(root.foreground, 1.8)
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.captionSmall !== undefined ? Style.font.captionSmall : Style.font.caption
      wrapMode: Text.WordWrap
    }
  }
}
