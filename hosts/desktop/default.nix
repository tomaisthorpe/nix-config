# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      
      ../../modules/nvidia.nix
      ../../modules/system.nix
      ../../modules/bluetooth.nix
      ../../modules/fonts.nix
      ../../modules/1password.nix
      ../../modules/steam.nix
    ];

  # Bootloader.
  # boot.loader.systemd-boot.enable = true;

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    useOSProber = true;
    efiSupport = true;
  };

  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-18c3967d-eed4-4c4d-b08e-1f47ddfc6421".device = "/dev/disk/by-uuid/18c3967d-eed4-4c4d-b08e-1f47ddfc6421";
  networking.hostName = "tom-desktop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure vertical monitor
  services.xserver.xrandrHeads = [
    {
      output = "DP-2";
      primary = true;
    }
    {
      output = "DP-0";
      monitorConfig = "Option \"Rotate\" \"left\"";
    }
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
