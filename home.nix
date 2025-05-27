{ config, pkgs, ... }:

let
  wallpaperDir = "${config.home.homeDirectory}/Pictures/wallpapers";

  # Custom startup script: swww, waybar, mako
  startupScript = pkgs.writeShellScriptBin "start" ''
    systemctl --user start plasma-polkit-agent
    ${pkgs.swww}/bin/swww-daemon &

    sleep 1
    WALP=$(find "${wallpaperDir}" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.gif" \) | shuf -n 1)
    [ -n "$WALP" ] && ${pkgs.swww}/bin/swww img "$WALP"

    ${pkgs.waybar}/bin/waybar &
    ${pkgs.mako}/bin/mako &
  '';
  
  randomWallpaperScript = pkgs.writeShellScriptBin "random-wallpaper" ''
    WALP=$(find "${wallpaperDir}" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.gif" \) | shuf -n 1)
    [ -n "$WALP" ] && ${pkgs.swww}/bin/swww img --transition-type wipe --transition-angle 30 "$WALP"
  '';
in {
  home.username = "simxnet";
  home.homeDirectory = "/home/simxnet";

  home.packages = with pkgs; [
    fastfetch
    ripgrep jq yq-go eza fzf
    mtr iperf3 dnsutils ldns aria2 socat nmap ipcalc
    zstd gnupg
    nix-output-monitor
    btop
    strace ltrace lsof
    firefox
    wofi
    randomWallpaperScript
  ];

  programs.git = {
    enable = true;
    userName = "Simonet";
    userEmail = "simxnet@envs.net";
    extraConfig.credential.helper = "manager";
    extraConfig.credential."https://github.com".username = "simxnet";
    extraConfig.credential.credentialStore = "cache";
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "FiraCode Nerd Font";
      size = 11;
    };
    settings = {
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      cursor_shape = "beam";
      enable_audio_bell = "no";
      window_padding_width = "22";
      hide_window_decorations = "yes";
      background_opacity = "0.8";
      tab_bar_min_tabs = "1";
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_title_template = "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";
      background = "#181818";
      cursor = "#f5e0dc";
      cursor_text_color = "#1e1e2e";
      url_color = "#f5e0dc";
      active_tab_foreground = "#11111b";
      active_tab_background = "#cba6f7";
      inactive_tab_foreground = "#cdd6f4";
      inactive_tab_background = "#181825";
      tab_bar_background = "#1f1f1f";
      mark1_foreground = "#1e1e2e";
      mark1_background = "#b4befe";
      mark2_foreground = "#1e1e2e";
      mark2_background = "#cba6f7";
      mark3_foreground = "#1e1e2e";
      mark3_background = "#74c7ec";
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin"
    '';
    shellAliases = {
      k = "kubectl";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    };
  };

  programs.gallery-dl = {
    enable = true;
    settings = {
      extractor.base-directory = "~/Gallery";
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = [
        ",1920x1080,auto,1,bitdepth,8"
        ",preferred,auto,1,mirror,eDP-1,bitdepth,8"
      ];

      exec-once = [
        "${startupScript}/bin/start"
	"hyprctl setcursor phinger-cursors-light 16"
      ];

      "$terminal" = "kitty";
      "$browser" = "firefox";
      "$screenshot" = "hyprshot";
      "$menu" = "wofi --show drun";
      "$discord" = "discord";

      env = [
        "HYPRCURSOR_THEME,phinger-cursors-light"
        "HYPRCURSOR_SIZE,16"
      ];

      general = {
        gaps_in = "5";
        gaps_out = "20";
        border_size = "2";
        "col.active_border" = "rgba(33ccffee) rgba(BB00AAee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        resize_on_border = "false";
        allow_tearing = "false";
        layout = "dwindle";
      };

      decoration = {
        rounding = "8";
        active_opacity = "0.9";
        inactive_opacity = "0.8";
        shadow.enabled = false;
        blur = {
          size = 10;
          passes = 2;
          noise = 0.0150;
        };
      };

      blurls = "waybar";
      layerrule = "blur,waybar";

      animations = {
        enabled = "true";
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      misc = {
        force_default_wallpaper = "0";
        disable_hyprland_logo = "true";
      };

      gestures.workspace_swipe = "false";

      device = {
        name = "epic-mouse-v1";
        sensitivity = "-0.5";
      };

      "$mainMod" = "SUPER";

      bind = [
	", PRINT, exec, grim -g \"$(slurp)\" - | bash ~/bin/tixte"
	"$mainMod, PRINT, exec, grim - | bash ~/bin/tixte"
        "$mainMod, SPACE, exec, $menu"
        "$mainMod, K, exec, $terminal"
        "$mainMod, F, exec, $browser"
	"$mainMod, D, exec, $discord"
        "$mainMod, Q, killactive"
	"$mainMod, W, exec, random-wallpaper"
        "$mainMod SHIFT, M, exit"
        "$mainMod, V, togglefloating"
        "$mainMod, P, pseudo,"
        "$mainMod, J, togglesplit,"
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];

      input = {
        kb_layout = "es,ru";
        kb_options = "grp:alt_space_toggle";
        numlock_by_default = true;
      };

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      windowrulev2 = "suppressevent maximize, class:.*";
    };
  };

  services.mako = {
    enable = true;
    settings = {
      anchor = "top-right";
      backgroundColor = "#282a36";
      borderColor = "#bd93f9";
      borderSize = 3;
      defaultTimeout = 3000;
      font = "FiraCode Nerd Font";
      height = 150;
      width = 300;
      icons = true;
      textColor = "#f8f8f2";
      layer = "overlay";
      sort = "-time";
      extraConfig = ''
        [urgency=low]
        border-color=#282a36
        [urgency=normal]
        border-color=#bd93f9
        [urgency=high]
        border-color=#ff5555
        default-timeout=0
        [category=mpd]
        default-timeout=2000
        group-by=category
      '';
    };
  };

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}

