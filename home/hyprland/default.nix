{
  pkgs,
  lib,
  isDesktop,
  ...
}:
{
  home.packages = with pkgs; [
    fuzzel
    waybar
    wl-clipboard
  ];

  xdg.configFile."hypr/hyprland.lua".text = ''
    hl.config({
      input = {
        kb_layout = "gb",
        kb_options = "caps:escape",
      },
    })

    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
    ${lib.optionalString isDesktop ''
      hl.monitor({ output = "DP-2", mode = "preferred", position = "0x0", scale = 1 })
      hl.monitor({ output = "DP-0", mode = "preferred", position = "auto-right", scale = 1, transform = 1 })
    ''}

    hl.on("hyprland.start", function()
      hl.exec_cmd("waybar")
      hl.exec_cmd("dunst")
    end)

    hl.bind("SUPER + Return", hl.dsp.exec_cmd("kitty"))
    hl.bind("SUPER + D", hl.dsp.exec_cmd("fuzzel"))
    hl.bind("SUPER + SHIFT + Q", hl.dsp.window.close({}))
    hl.bind("SUPER + F", hl.dsp.window.fullscreen({}))
    hl.bind("SUPER + SHIFT + SPACE", hl.dsp.window.float({}))
    hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("uwsm stop"))

    for key, direction in pairs({ H = "l", J = "d", K = "u", L = "r", left = "l", down = "d", up = "u", right = "r" }) do
      hl.bind("SUPER + " .. key, hl.dsp.focus({ direction = direction }))
      hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ direction = direction }))
    end

    for workspace = 1, 10 do
      local key = tostring(workspace % 10)
      hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = workspace }))
      hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
    end
  '';
}
