{
  pkgs,
  lib,
  polybar-themes,
  ...
}:
{
  imports = [
    ./packages.nix
  ];

  xsession = {
    enable = true;
    windowManager.i3 = {
      enable = true;
      config = lib.mkForce null; # ignore all home-manager default i3 config
      extraConfig = builtins.readFile ./config/i3-config;
    };
    scriptPath = ".xsession";
  };

  xdg.configFile = {
    "i3/scripts" = {
      source = ./config/scripts;
      # copy the scripts directory recursively
      recursive = true;
      executable = true; # make all scripts executable
    };
  };

  home.file = {
    ".config/polybar" = {
      source = ./config/polybar;
      recursive = true;
      executable = true;
    };
    ".local/share/fonts" = {
      source = "${polybar-themes}/fonts";
      recursive = true;
    };

    ".local/bin" = {
      source = ./bin;
      recursive = true;
      executable = true;
    };
  };
}
