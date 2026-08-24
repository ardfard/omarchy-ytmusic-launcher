import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// YouTube Music bar widget — separate-process architecture.
// The music itself runs in a dedicated chromium --app window
// (class ytmusic-popup) outside quickshell, so WebEngine never lives inside
// the shell process and cannot crash it. The bar icon toggles that window's
// hidden/visible state; PopupCard closes on unfocus but the app keeps playing.
BarWidget {
  id: root
  moduleName: "io.github.ardfard.ytmusic-launcher"

  // Hyprland class for the chromium app window (used for dispatch focus/hide)
  readonly property string appClass: "ytmusic-popup"
  readonly property string appUrl: "https://music.youtube.com"
  // Isolated profile so YTMusic login/cookies survive shell restarts
  readonly property string appDataDir: Quickshell.env("HOME") + "/.local/share/ytmusic-launcher"

  // Track whether we've ever launched the app (so first toggle -> launch+show)
  property bool launched: false
  property bool showing: false

  readonly property bool opened: showing

  function launchCmd() {
    // --class sets WM_CLASS so hyprctl can match class:ytmusic-popup
    return "chromium --user-data-dir='" + appDataDir + "' --app='" + appUrl + "' --class=" + appClass + " --ozone-platform-hint=auto > /dev/null 2>&1 &"
  }

  function showApp() {
    if (!bar) return
    if (!launched) {
      bar.run(launchCmd())
      launched = true
      showing = true
      // Give chromium time to map, then focus it near the bar
      Qt.callLater(function() { if (bar) bar.run("hyprctl dispatch focuswindow class:" + appClass) })
      return
    }
    bar.run("hyprctl dispatch focuswindow class:" + appClass)
    showing = true
  }

  function hideApp() {
    if (!bar) return
    // Move to special workspace (hidden) — keeps audio alive, just not visible
    bar.run("hyprctl dispatch movetoworkspacesilent special:ytmusic,class:" + appClass)
    showing = false
  }

  function toggle() {
    if (showing) hideApp()
    else showApp()
  }
  function open() { showApp() }
  function close() { hideApp() }
  function closeForPopoutSwitch() { hideApp() }

  // Also hide when the panel's click-outside fires (wired via panel signal)
  Connections {
    target: panel
    function onRequestHide() { root.hideApp() }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  readonly property real openPanelIndicatorWidth: button.glyphPaintedWidth > 0 ? button.glyphPaintedWidth : Style.space(10)
  readonly property real openPanelIndicatorHeight: Math.max(Style.space(10), Math.round(Style.bar.iconSlot * 0.55))

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\uf167"
    tooltipText: showing ? "YouTube Music — click to hide (music keeps playing)" : "YouTube Music"
    active: root.showing
    textRotation: root.vertical ? 90 : 0
    onPressed: function(b) {
      if (b === Qt.LeftButton || b === Qt.MiddleButton) root.toggle()
      else if (b === Qt.RightButton && root.bar) {
        root.bar.run("xdg-open '" + root.appUrl + "'")
      }
    }
  }

  PlayerPanel {
    id: panel
    bar: root.bar
    anchorItem: button
    hostWidget: root
    settings: root.settings
    appShowing: root.showing
    appDataDir: root.appDataDir
    appUrl: root.appUrl
    appClass: root.appClass
  }

  IpcHandler {
    target: "io.github.ardfard.ytmusic-launcher"
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
  }
}
