{
  pkgs,
  lib,
  isDesktop,
  ...
}:
{
  home.packages = with pkgs; [
    waybar
    wl-clipboard
  ];

  home.pointerCursor = {
    enable = true;
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    hyprcursor.enable = true;
  };

  # Flat full-width bar modelled on the old i3 polybar "forest" theme, Catppuccin Mocha colours
  xdg.configFile."waybar/config.jsonc".text =
    let
      # Font Awesome glyphs as escapes so they survive editing
      icon = code: builtins.fromJSON ("\"\\u" + code + "\"");
      coloured = color: glyph: "<span foreground='${color}'>${glyph} </span>";
      # waybar needs one {iconN} per thread; 24 threads on the desktop, 4 on the laptop
      cpuThreads = if isDesktop then 24 else 4;
      sep = name: {
        "custom/sep#${name}" = {
          format = "|";
          tooltip = false;
        };
      };
    in
    builtins.toJSON (
      {
        layer = "top";
        height = 34;
        spacing = 12;
        modules-left = [ "hyprland/workspaces" ];
        modules-right = [
          "cpu"
          "memory"
          "disk"
          "custom/sep#a"
          "clock"
        ]
        ++ lib.optionals (!isDesktop) [ "battery" ]
        ++ [
          "custom/sep#b"
          "network"
          "custom/sep#c"
          "pulseaudio"
        ]
        ++ lib.optionals (!isDesktop) [ "backlight" ]
        ++ [
          "custom/sep#d"
          "tray"
          "custom/power"
        ];
        "hyprland/workspaces" = {
          format = "{id}";
          on-click = "activate";
          persistent-workspaces."*" = 5;
        };
        cpu = {
          format = "${coloured "#f9e2af" (icon "f2db")} ${lib.concatMapStrings (n: "{icon${toString n}}") (lib.range 0 (cpuThreads - 1))}";
          format-icons = [ "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
          interval = 1;
        };
        memory = {
          format = "${coloured "#89b4fa" (icon "f538")} {percentage}%";
          interval = 2;
        };
        disk = {
          format = "${coloured "#fab387" (icon "f0a0")} {free}";
          interval = 30;
        };
        clock = {
          format = "${coloured "#f38ba8" (icon "f073")} {:%Y/%m/%d %H:%M}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };
        battery = {
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-icons = [ "󰁺" "󰁼" "󰁾" "󰂀" "󰁹" ];
        };
        backlight = {
          format = "󰃟 {percent}%";
          on-scroll-up = "brightnessctl set +5%";
          on-scroll-down = "brightnessctl set 5%-";
        };
        network = {
          format-wifi = "${coloured "#cba6f7" (icon "f1eb")} {essid}";
          format-ethernet = "${coloured "#cba6f7" "󰈀"} {ipaddr}";
          format-disconnected = "${coloured "#fab387" "󰖪"} Offline";
          tooltip-format = "{ifname}: {ipaddr}";
        };
        pulseaudio = {
          format = "${coloured "#94e2d5" (icon "f028")} {volume}%";
          format-muted = "${coloured "#94e2d5" (icon "f026")} muted";
          on-click = "pavucontrol";
        };
        tray.spacing = 10;
        "custom/power" = {
          format = coloured "#89dceb" (icon "f011");
          tooltip = false;
          on-click = "printf 'Lock\\nLogout\\nReboot\\nShutdown' | rofi -dmenu -p power | xargs -r -I{} sh -c 'case {} in Lock) loginctl lock-session;; Logout) uwsm stop;; Reboot) systemctl reboot;; Shutdown) systemctl poweroff;; esac'";
        };
      }
      // sep "a"
      // sep "b"
      // sep "c"
      // sep "d"
    );

  xdg.configFile."waybar/style.css".text = ''
    /* Catppuccin Mocha */
    @define-color base #1e1e2e;
    @define-color text #cdd6f4;
    @define-color sep #45475a;
    @define-color pink #f5c2e7;
    @define-color red #f38ba8;

    * {
      border: none;
      border-radius: 0;
      min-height: 0;
      font-family: "Iosevka Nerd Font";
      font-size: 15px;
    }

    window#waybar {
      background-color: @base;
      color: @text;
    }

    #workspaces button {
      padding: 0 10px;
      background: transparent;
      color: @text;
      border-bottom: 2px solid transparent;
    }

    #workspaces button.active {
      border-bottom: 2px solid @pink;
    }

    #workspaces button.urgent {
      color: @red;
    }

    #workspaces button:hover {
      background: @sep;
    }

    #custom-sep {
      color: @sep;
    }

    #tray,
    #custom-power {
      padding: 0 6px;
    }
  '';

  xdg.configFile."hypr/hyprland.lua".text = ''
    hl.env("XCURSOR_THEME", "Adwaita")
    hl.env("XCURSOR_SIZE", "24")
    hl.env("HYPRCURSOR_THEME", "Adwaita")
    hl.env("HYPRCURSOR_SIZE", "24")

    hl.config({
      input = {
        kb_layout = "gb",
        kb_options = "caps:escape",
      },
      misc = {
        background_color = 0xff11111b,
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
      },
    })

    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
    ${lib.optionalString isDesktop ''
      hl.monitor({ output = "DP-2", mode = "preferred", position = "0x0", scale = 1 })
      hl.monitor({ output = "DP-1", mode = "preferred", position = "auto-right", scale = 1, transform = 1 })
    ''}

    hl.on("hyprland.start", function()
      hl.exec_cmd("waybar")
      hl.exec_cmd("dunst")
    end)

    hl.bind("SUPER + Return", hl.dsp.exec_cmd("kitty"))
    hl.bind("SUPER + D", hl.dsp.exec_cmd("rofi -show drun"))
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
