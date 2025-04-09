# Nix Config

This repository contains my personal NixOS configuration files. It manages the setups for my machines and provides a reproducible environment across my systems.

## Hosts
| Name | Hardware | Description |
| --- | --- | --- |
| `laptop` | Thinkpad X1 Carbon | Daily light-use |
| `desktop` | Custom build with NVIDIA GPU | Main workstation for development and gaming |
| `vm` | VirtualBox | Testing environment |

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

```bash
# Deploy to laptop
sudo nixos-rebuild switch --flake .#laptop

# Deploy to desktop
sudo nixos-rebuild switch --flake .#desktop

```

## Resources

- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world)
- [ryan4yn's Nix Config](https://github.com/ryan4yin/nix-config)
- [mitchellh's Nix Config](https://github.com/mitchellh/nixos-config)
