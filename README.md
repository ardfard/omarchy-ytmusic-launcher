# omarchy YouTube Music

Bar widget for [omarchy-shell](https://quickshell.org/) — `` in the bar. **Left-click toggles a dedicated YouTube Music window; closing/hiding it keeps the music playing** (audio lives in a separate chromium process, not inside quickshell, so it never crashes the shell).

## How it works

- The music runs in `chromium --app=https://music.youtube.com --class=ytmusic-popup --user-data-dir=~/.local/share/ytmusic-launcher` — isolated profile, login/cookies survive restarts, audio survives popup close because it's a different process.
- The bar glyph (``) shows/hides that window via `hyprctl dispatch focuswindow / movetoworkspacesilent special:ytmusic,class:…`. The widget's `PopupCard` is the anchor/control surface (same shape as omarchy's audio/network popups, `HyprlandFocusGrab` click-outside, `owner`/`anchorItem`/`bar`).
- Right-click `` → `xdg-open music.youtube.com` in your default browser (firefox).

## Files

```
manifest.json   # schema-v1, id io.github.ardfard.ytmusic-launcher, version 3.0.0
BarWidget.qml   # glyph + open dot + chromium --app lifecycle (launch/show/hide)
PlayerPanel.qml # PopupCard anchored to glyph, controls for the external window
```

No `WebEngineView` inside quickshell — `qt6-webengine` is not required and cannot crash the shell.

## Install

```bash
~/Work/personal/omarchy-ytmusic-launcher/sync.sh
# or manually:
rm -rf ~/.config/omarchy/plugins/io.github.ardfard.ytmusic-launcher
cp -a ~/Work/personal/omarchy-ytmusic-launcher ~/.config/omarchy/plugins/io.github.ardfard.ytmusic-launcher
omarchy plugin validate ~/.config/omarchy/plugins/io.github.ardfard.ytmusic-launcher
omarchy restart shell   # needed once to pick up new plugin files reliably
```

The id `io.github.ardfard.ytmusic-launcher` is unchanged, so existing `shell.json` layout/enabled state carries over.

## Optional Hyprland window rules (recommended)

Add to `~/.config/hypr/hyprland.conf` or a sourced file so the YTMusic app window floats nicely on first show:

```
windowrulev2 = float, class:ytmusic-popup
windowrulev2 = size 920 640, class:ytmusic-popup
windowrulev2 = center, class:ytmusic-popup
```

Hiding uses `special:ytmusic` (special workspace) — audio continues; showing refocuses it.
