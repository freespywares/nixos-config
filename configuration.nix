{ config, pkgs, inputs, ... }:

{
  # --------------------------------------------
  # System Configuration
  # --------------------------------------------

  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
  ];

  services.greetd = {
    enable = true;

    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd Hyprland";
        user = "simxnet";
      };
    };
  };

  networking.hostName = "nixos";
  time.timeZone = "Europe/Madrid";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
  };

  # --------------------------------------------
  # Boot Configuration
  # --------------------------------------------

  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      useOSProber = true;
      devices = [ "nodev" ];
    };
    efi.canTouchEfiVariables = true;
  };

  # --------------------------------------------
  # Networking
  # --------------------------------------------

  networking.networkmanager.enable = true;

  # --------------------------------------------
  # Hyprland Setup (Wayland)
  # --------------------------------------------

  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # Optional, default true
  };

  console.keyMap = "es";

  # --------------------------------------------
  # Audio
  # --------------------------------------------

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true; # Uncomment if needed
  };

  # --------------------------------------------
  # Printing
  # --------------------------------------------

  services.printing.enable = true;

  # --------------------------------------------
  # User Account
  # --------------------------------------------

  users.users.simxnet = {
    isNormalUser = true;
    description = "Juli";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    	(discord.override {
           withOpenASAR = true;
      	   # withVencord = true; # can do this here too
    	})
    ];
  };

  # --------------------------------------------
  # System Packages
  # --------------------------------------------

  environment.systemPackages = with pkgs; [
    git
    neovim
    wget
    curl
    broot
    just
    waybar
    swww
    grim
    slurp
    wl-clipboard
    phinger-cursors
    mako
    libnotify
    kitty
    gallery-dl
    zig
    libressl
    file
    yaak
    git-credential-manager
    inputs.lizzy.packages.${pkgs.system}.lizzy
  ];

  nixpkgs.config.allowUnfree = true;

  # --------------------------------------------
  # Fonts
  # --------------------------------------------

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      nerd-fonts.noto
      nerd-fonts.jetbrains-mono
    ];
    fontconfig.defaultFonts = {
      serif = [ "Noto Nerd Font" ];
      sansSerif = [ "Noto Nerd Font" ];
      monospace = [ "Noto Nerd Font" ];
    };
  };

  # --------------------------------------------
  # System Maintenance
  # --------------------------------------------

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # --------------------------------------------
  # Environment Variables
  # --------------------------------------------

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  # --------------------------------------------
  # Hardware
  # --------------------------------------------

  hardware.graphics.enable = true;

  # --------------------------------------------
  # Spicetify
  # --------------------------------------------

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
    in
    {
    enable = true;

    enabledExtensions = with spicePkgs.extensions; [
      adblock
      hidePodcasts
    ];

    theme = spicePkgs.themes.catppuccin;
    colorScheme = "mocha";
    };

  # --------------------------------------------
  # System State Version
  # --------------------------------------------

  system.stateVersion = "24.11";

  # --------------------------------------------
  # Imports
  # --------------------------------------------

  imports = [
    ./hardware-configuration.nix
    inputs.spicetify-nix.nixosModules.default
  ];
}

