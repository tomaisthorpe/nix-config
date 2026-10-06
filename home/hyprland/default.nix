{
  pkgs,
  lib,
  isDesktop,
  ...
}:
let
  # Pick an entry from clipboard history and put it back on the clipboard
  clipboardPicker = pkgs.writeShellScript "clipboard-picker" ''
    export PATH=${
      lib.makeBinPath [
        cliphist
        pkgs.rofi
        pkgs.wl-clipboard
      ]
    }:$PATH
    selection=$(cliphist list | rofi -theme hyprland -dmenu -p clipboard) || exit 0
    [ -n "$selection" ] || exit 0
    printf '%s' "$selection" | cliphist decode | wl-copy
  '';
  # `cliphist wipe -older-than` isn't in a release yet (0.7.0 in nixpkgs), so build master
  cliphist = pkgs.cliphist.overrideAttrs (old: {
    version = "0.7.0-unstable-daa99da";
    src = pkgs.fetchFromGitHub {
      owner = "sentriz";
      repo = "cliphist";
      rev = "daa99daef3ed37dc37013b1fae381fe626025a13";
      hash = "sha256-LHYHKtKzmWEupsypAMZgG4drpCF7DmklnWgnK3dXrUE=";
    };
    vendorHash = "sha256-fDl+ul1t2Ux1w5WcCo6YMJtrcC20o+eUEO3NNycSNvI=";
  });
in
{
  home.packages = with pkgs; [
    waybar
    wl-clipboard
    brightnessctl
    playerctl
    grim
    slurp
    satty
  ];

  # Clipboard history; only keep the last hour, pruned every 5 minutes
  services.cliphist = {
    enable = true;
    package = cliphist;
    allowImages = true;
  };

  systemd.user.services.cliphist-wipe = {
    Unit.Description = "Wipe clipboard history older than an hour";
    Service = {
      Type = "oneshot";
      ExecStart = "${cliphist}/bin/cliphist wipe -older-than 1h";
    };
  };

  systemd.user.timers.cliphist-wipe = {
    Unit.Description = "Prune old clipboard history";
    Timer = {
      OnCalendar = "*:0/5";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

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
      # waybar's hyprland/workspaces sends legacy dispatch syntax, which the Lua config rejects,
      # so workspaces are custom modules that follow Hyprland events and click via Lua
      wsWatch = pkgs.writeShellScript "waybar-workspace" ''
        export PATH=${lib.makeBinPath [ pkgs.socat pkgs.jq ]}:$PATH
        n=$1
        monitor=$2
        # With a monitor, only show workspaces that live on it (like polybar's pin-workspaces).
        # Without one (single screen), always show 1-5 and any others that exist.
        show() {
          class=$(jq -n -r --argjson n "$n" --arg m "$monitor" \
            --argjson monitors "$(hyprctl -j monitors)" --argjson workspaces "$(hyprctl -j workspaces)" '
            ([$workspaces[] | select(.id == $n and ($m == "" or .monitor == $m))] | first) as $ws
            | if [$monitors[] | select(($m == "" or .name == $m) and .activeWorkspace.id == $n)] | length > 0 then "active"
              elif $ws != null and $ws.windows > 0 then "occupied"
              elif $m == "" and $n <= 5 then "empty"
              else "hidden" end')
          # exit once waybar has gone, so reloads don't leave orphaned scripts behind
          if [ "$class" = hidden ]; then
            printf '{"text":""}\n' || exit 0
          else
            printf '{"text":"%s","class":"%s"}\n' "$n" "$class" || exit 0
          fi
        }
        show
        socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" |
          while read -r _; do show; done
      '';
      workspaceIds = lib.range 1 10;
      workspaceModule = monitor: n: {
        name = "custom/ws#${toString n}";
        value = {
          exec = "${wsWatch} ${toString n} '${monitor}'";
          return-type = "json";
          format = "{}";
          tooltip = false;
          on-click = "hyprctl dispatch 'hl.dsp.focus({ workspace = ${toString n} })'";
        };
      };
      sep = name: {
        "custom/sep#${name}" = {
          format = "|";
          tooltip = false;
        };
      };
      bar =
        monitor:
        (
      {
        layer = "top";
        height = 34;
        spacing = 12;
        modules-left = map (n: "custom/ws#${toString n}") workspaceIds;
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
          on-click = "printf 'Lock\\nLogout\\nReboot\\nShutdown' | rofi -theme hyprland -dmenu -p power | xargs -r -I{} sh -c 'case {} in Lock) loginctl lock-session;; Logout) uwsm stop;; Reboot) systemctl reboot;; Shutdown) systemctl poweroff;; esac'";
        };
      }
      // lib.listToAttrs (map (workspaceModule monitor) workspaceIds)
      // sep "a"
      // sep "b"
      // sep "c"
      // sep "d"
      // lib.optionalAttrs (monitor != "") { output = monitor; }
      # the vertical monitor only gets workspaces, like polybar's secondary bar
      // lib.optionalAttrs (monitor == "DP-1") { modules-right = [ ]; }
        );
      # one bar per screen on the desktop (DP-2 left, DP-1 the vertical one); a single bar elsewhere
      monitors = if isDesktop then [ "DP-2" "DP-1" ] else [ "" ];
    in
    builtins.toJSON (map bar monitors);

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

    #custom-ws {
      padding: 0 10px;
      color: @text;
      border-bottom: 2px solid transparent;
    }

    #custom-ws.empty {
      color: @sep;
    }

    #custom-ws.active {
      border-bottom: 2px solid @pink;
    }

    #custom-ws:hover {
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

  # Rofi theme matching the waybar look; kept separate so the i3 rofi theme is untouched
  xdg.configFile."rofi/themes/hyprland.rasi".text = ''
    /* Catppuccin Mocha */
    * {
      base: #1e1e2e;
      surface: #313244;
      sep: #45475a;
      text: #cdd6f4;
      pink: #f5c2e7;

      background-color: transparent;
      text-color: @text;
      font: "Iosevka Nerd Font 14";
    }

    window {
      width: 520px;
      background-color: @base;
      border: 2px;
      border-color: @sep;
    }

    mainbox {
      padding: 12px;
      spacing: 8px;
    }

    inputbar {
      padding: 8px 10px;
      spacing: 8px;
      background-color: @surface;
      children: [ prompt, entry ];
    }

    prompt {
      text-color: @pink;
    }

    entry {
      placeholder: "search";
      placeholder-color: @sep;
    }

    listview {
      lines: 8;
      scrollbar: false;
      spacing: 2px;
    }

    element {
      padding: 6px 10px;
      spacing: 8px;
      border: 0 0 2px 0;
      border-color: transparent;
    }

    element selected {
      background-color: @surface;
      border-color: @pink;
    }

    element-icon {
      size: 1.2em;
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
      general = {
        col = {
          active_border = { colors = { "rgba(cba6f7ee)", "rgba(89b4faee)" }, angle = 45 },
          inactive_border = "rgba(45475aaa)",
        },
      },
      animations = {
        enabled = false,
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

    -- Media, volume and brightness keys (wpctl comes with pipewire's wireplumber)
    hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
    hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
    hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
    hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
    hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
    hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
    hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
    hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
    hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

    -- Screenshots: select an area and annotate it in satty, or copy it straight to the clipboard
    hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | satty --filename - --early-exit --copy-command wl-copy --output-filename "$HOME/Pictures/screenshot-%Y-%m-%d_%H-%M-%S.png"'))
    hl.bind("SUPER + Print", hl.dsp.exec_cmd('grim -g "$(slurp -d)" - | wl-copy'))

    -- Clipboard history: rofi picker on SUPER + V
    hl.bind("SUPER + V", hl.dsp.exec_cmd("${clipboardPicker}"))

    hl.on("hyprland.start", function()
      -- graphical-session.target isn't active in this session, so start the clipboard watchers by hand
      hl.exec_cmd("systemctl --user start cliphist cliphist-images")
      hl.exec_cmd("waybar")
      hl.exec_cmd("dunst")
    end)

    hl.bind("SUPER + Return", hl.dsp.exec_cmd("kitty"))
    hl.bind("SUPER + D", hl.dsp.exec_cmd("rofi -theme hyprland -combi-modi 'window#run' -show combi -modi combi"))
    hl.bind("SUPER + G", hl.dsp.exec_cmd("rofi -theme hyprland -show drun"))
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
