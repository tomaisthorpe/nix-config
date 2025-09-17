{
  config,
  pkgs,
  lib,
  isDesktop ? false,
  isLinux ? true,
  ...
}:
{
  imports = [
    ./editors
  ]
  ++ lib.optionals isLinux [ ./linux.nix ]
  ++ lib.optionals (isLinux == false) [ ./darwin.nix ];

  home.username = "tom";
  
  # Set homeDirectory based on platform - use mkForce to override any conflicting definitions
  home.homeDirectory = lib.mkForce (
    if isLinux then 
      "/home/tom"
    else 
      "/Users/tom"
  );

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
