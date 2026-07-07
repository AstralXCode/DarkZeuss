# DarkZeuss Hub

![Version](https://img.shields.io/badge/version-1.0-blue)
[![WindUI](https://img.shields.io/badge/powered%20by-WindUI-8a2be2)](https://github.com/Footagesus/WindUI)

A feature-rich Roblox script hub built on [WindUI](https://github.com/Footagesus/WindUI) with modern UI, device detection, and player controls.

## Repository Structure

```
DarkZeuss/
├── main.lua        # Entry point — short loader
├── src/
│   └── core.lua    # Main hub code
└── README.md       # Documentation
```

## Usage

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/AstralXCode/DarkZeuss/main/main.lua"))()
```

`main.lua` will automatically load the core from `src/core.lua`.

## Features

- **Modern UI** — Powered by WindUI with animated gradient title, sidebar profile, and dark theme
- **Device Detection** — Automatically detects your device type (Android/iOS, PC, Console), screen resolution, and public IP
- **Player Controls** — WalkSpeed slider with real-time adjustments
- **Auto-Tab Select** — Opens to the Information tab on launch
- **Hotkey Toggle** — Toggle UI visibility with `Right Control`

## Tabs

| Tab | Icon | Description |
|-----|------|-------------|
| **Informasi** | `lucide:info` | Device info, IP address, screen resolution |
| **Main** | `lucide:zap` | Player settings (WalkSpeed slider) |

## Requirements

- Roblox executor with `game:HttpGet` support (Delta, Codex, Arceus X, etc.)
- Internet connection for initial load

## Development

The hub code is in `src/core.lua`. To test changes locally:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/AstralXCode/DarkZeuss/main/src/core.lua"))()
```

## Credit

- **UI Library** — [WindUI](https://github.com/Footagesus/WindUI) by Footagesus
- **Icons** — Lucide, Geist, Craft Icons
- **Developer** — [AstralXCode](https://github.com/AstralXCode)

## License

MIT
