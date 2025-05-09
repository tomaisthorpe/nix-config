{
    pkgs,
    lib,
    ...
}: let
    username = "tom";
in {
  # Enable networking
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  
  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # use a fake session to skip desktop manager
  # and let Home Manager take care of the X session
  services.displayManager.defaultSession = "hm-session";

  services.xserver = {
    enable = true;
    displayManager = {
      lightdm.enable = true;
    };
    desktopManager = {
      runXdgAutostartIfNone = true;
      session = [
        {
          name = "hm-session";
          manage = "window";
          start = ''
            ${pkgs.runtimeShell} $HOME/.xsession &
            waitPID=$!
          '';
        }
      ];
    };
  };

  # Configure keymap in X11
  services.xserver = {
    xkb = {
      layout = "gb";
      variant = "";
    };
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  programs.fish.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tom = {
    isNormalUser = true;
    description = "Tom";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.fish;
  };

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "tom" ];
  virtualisation.libvirtd.enable = true;

  virtualisation.docker.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Remove when obsidian is updated
  nixpkgs.config.permittedInsecurePackages = ["electron-25.9.0"];

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    git
    lm_sensors # for `sensors` command
    killall

    fontconfig
    zlib

    openocd
  ];

  boot.supportedFilesystems = [ "ntfs" ];
  boot.extraModprobeConfig = '' options bluetooth disable_ertm=1 '';

  environment.variables.EDITOR = "vim";
  environment.variables.TERMINAL = "kitty";

  services.gvfs = {
    enable = true;
    package = lib.mkForce pkgs.gnome.gvfs;
  };

  services.avahi.enable = true; # network discovery
  services.tumbler.enable = true; # thumbnails
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  programs.file-roller.enable = true;
  programs.xfconf.enable = true;
  
  security.polkit.enable = true;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  programs.ssh.startAgent = true;

  services.tailscale.enable = true;

  services.udev.extraRules = builtins.readFile ./99-custom.rules;

  nix.settings.experimental-features = "nix-command flakes";

  programs.npm.enable = true;

  xdg.portal.enable = true;
  services.flatpak.enable = true;
}
