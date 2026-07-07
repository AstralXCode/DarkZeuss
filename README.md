# DarkZeuss Hub

A feature-rich Roblox script hub built on [WindUI](https://github.com/Footagesus/WindUI) with modern UI, device detection, and player controls.

## Features

- **Modern UI** — Powered by WindUI with animated gradient title, sidebar profile, and dark theme
- **Device Detection** — Automatically detects your device type (Android/iOS, PC, Console), screen resolution, and public IP
- **Player Controls** — WalkSpeed slider with real-time adjustments
- **Auto-Tab Select** — Opens to the Information tab on launch
- **Hotkey Toggle** — Toggle UI visibility with `Right Control`
- **Persistent Config** — Settings saved via WindUI's config system

## Usage

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/AstralXCode/DarkZeuss/main/main.lua"))()
```

## Tabs

| Tab | Description |
|-----|-------------|
| **Informasi** | Device info, IP address, screen resolution |
| **Main** | Player settings (WalkSpeed slider) |

## Requirements

- Roblox executor that supports `game:HttpGet` (Delta, Codex, Arceus X, etc.)
- Internet connection for initial library load

## Credits

- **UI Library** — [WindUI](https://github.com/Footagesus/WindUI) by Footagesus
- **Icons** — Lucide, Geist, Craft Icons
- **Developer** — [AstralXCode](https://github.com/AstralXCode)

## License

MIT
