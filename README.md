# Nix Config

This repository contains my personal NixOS configuration files. It manages the setups for my machines and provides a reproducible environment across my systems.

## Hosts

| Name      | Hardware                     | Description                                 |
| --------- | ---------------------------- | ------------------------------------------- |
| `laptop`  | Thinkpad X1 Carbon           | Daily light-use                             |
| `desktop` | Custom build with NVIDIA GPU | Main workstation for development and gaming |

## Features

- **Window Manager:** i3
- **Terminal:** kitty
- **Shell:** fish
- **Editors:** Neovim, Cursor, VSCode
- **Gaming:** Steam, OpenTTD 🚂
- **Various apps:** KiCad, FreeCAD, Blender, Inkscape

## How to deploy

> [!WARNING]
> You shouldn't deploy this. The hardware configuration is tied to my machines and my setup is probably not what you want. However, it may be useful as a reference.

### Using Makefile

```bash
make desktop  # Rebuild desktop
make laptop   # Rebuild laptop
make check    # Run flake check
make update   # Update flake inputs
make clean    # Garbage collect (>30 days)
```

### Manual

```bash
# NixOS
sudo nixos-rebuild switch --flake .#laptop
sudo nixos-rebuild switch --flake .#desktop

# Darwin
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/dev/nix-config/flake.nix
```

## Resources

- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world)
- [ryan4yn's Nix Config](https://github.com/ryan4yin/nix-config)
- [mitchellh's Nix Config](https://github.com/mitchellh/nixos-config)
