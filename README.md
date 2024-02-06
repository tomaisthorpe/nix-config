# Nix Config

This repo contains the Nix code that sets up my NixOS systems. Currently only my laptop and a VM is here, but eventually my desktop will be based on NixOS too.

The setup uses i3 as it's window manager and my neovim config is also here! I don't include extensions for Firefox/VSCode/etc in my Nix config as I rely on the various accounts to sync settings. 

## How to deploy

**You shouldn't deploy this. The hardware configuration is tied to my machines and my setup is probably not what you want. However, it may be useful as a reference.**

```bash
sudo nixos-rebuild switch --flake .#laptop
```

## Resources

- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world)
- [ryan4yn's Nix Config](https://github.com/ryan4yin/nix-config)
- [mitchellh's Nix Config](https://github.com/mitchellh/nixos-config)
