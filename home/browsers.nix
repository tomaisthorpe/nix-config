{
  pkgs,
  config,
  ...
}: {
  programs = {
    chromium = {
      enable = true;
      commandLineArgs = [];
      extensions = [
        # {id = "";}  // extension id, query from chrome web store
      ];
    };

    firefox = {
      enable = true;
      profiles.tom = {};
    };
  };
}