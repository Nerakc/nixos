# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{ inputs, lib, config, pkgs, ... }:

let
  unstable = inport <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";
        # Opinionated: disable global registry
        flake-registry = "";
        # Workaround for https://github.com/NixOS/nix/issues/9574
        nix-path = config.nix.nixPath;
      };
      # Opinionated: disable channels
      channel.enable = false;

      # Opinionated: make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };


  # ---------- GLOBAL SETTINGS ----------



  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    unstable.neovim
    rofi
    zsh
    neofetch
    killall
    btop
    gnumake
    gcc
    python3
    cargo
    nodejs
    man-pages
    man-pages-posix
  ];
  # FIXME: Add the rest of your current configuration

  networking.hostName = "NerakcOS";



  # ---------- USER SETTINGS ----------

  users.users = {
    nerakc = {
      initialPassword = "12345";
      isNormalUser = true;
      shell = pkgs.zsh;

      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];


      packages = with pkgs; [
        brave
        tree
        gh
        (discord.overrie {
          withOpenASAR = true;
          withVencord = true;
        })
        kitty
        obsidian
        nerdfotns
        lazygit
        ripgrep
        fzf
        fd
        fastfetch
        eza
      ];

      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = [ "wheel" "networkmanager" "audio" ];
    };
  };



  # ---------- SYSTEM SETTINGS ----------

  boot.loader =
    {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;
      grub = {
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
      };
    };


  networking.networkmanager =
    {
      enable = true; # Easiest to use and most distros use this by default.
      wifi.powersave = true;
    };


  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };
  services.blueman.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Prague";


  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    settings = {
      # Opinionated: forbid root login through SSH.
      PermitRootLogin = "no";
      # Opinionated: use keys only.
      # Remove if you want to SSH using passwords
      PasswordAuthentication = false;
    };
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    # keyMap = "us";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.


  services = {
    xserver = {
      enable = true;
      # windowManager.awesome.enable = true;
      # displayManager.startx.enable = true;
      # autorun = true;
    };
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "eurosign:e,caps:escape";


  # enable sound.
  hardware = {
    pulseaudio.enable = true;
  };
  # or
  services.pipewire = {
    enable = false;
    pulse.enable = false;

  };



  documentation.dev.enable = true;

  documentation.man = {
    # In order to enable to mandoc man-db has to be disabled.
    man-db.enable = false;
    mandoc.enable = true;
  };


  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
