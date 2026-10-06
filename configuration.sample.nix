# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> {};
  noctalia-greeter = builtins.getFlake "github:noctalia-dev/noctalia-greeter";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      noctalia-greeter.nixosModules.default
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "efi"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  # security.pki.certificateFiles = [ ./root.crt ];  # redacted: private CA

  # networking.extraHosts = "...";  # redacted: internal host mapping

  # Run Garbage Collector Weekley
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
  };   

  security.sudo = {
    enable = true;
    extraRules = [
      {
        users = [ "erfan" ];
        commands = [
          {
            command = "/run/wrappers/bin/ip";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/ip";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/iptables";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };


  # Set your time zone.
  time.timeZone = "Asia/Tehran";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        # Shows battery charge of connected devices on supported
        # Bluetooth adapters. Defaults to 'false'.
        Experimental = true;
        # When enabled other devices can connect faster to us, however
        # the tradeoff is increased power consumption. Defaults to
        # 'false'.
        FastConnectable = true;
      };
       Policy = {
        # Enable all controllers when they are found. This includes
        # adapters present on start as well as adapters that are plugged
        # in later on. Defaults to 'true'.
        AutoEnable = true;
      };
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
  };

  hardware.opengl = {
    enable = true;
  };

  services.xserver.enable = true;
  programs.xwayland.enable = true;
  services.xserver.videoDrivers = [ "nvidia" "modesetting" ];
  hardware.graphics.enable = true;
  # hardware.nvidia.prime.offload.enable = true;

  # Noctalia greeter (greetd) replaces SDDM.
  services.displayManager.sddm.enable = false;
  services.displayManager.noctalia-greeter = {
    enable = true;
    settings = {
      session.default = "niri";
      appearance = {
        scheme = "Gruvbox";
        theme_mode = "dark";
        wallpaper = {
          path = "/home/erfan/.config/wallpaper/damavand-sunset.jpg";
          fill_mode = "stretch";
        };
      };
      clock = {
        enabled = true;
        position = "above-panel";
        time_format = "{:%H:%M}";
        date_format = "%A, %x";
      };
      keyboard = {
        layout = "us,ir";
        options = "grp:win_space_toggle,compose:ralt,ctrl:nocaps";
        numlock = true;
      };
      cursor = {
        theme = "Adwaita";
        size = 24;
      };
    };
  };

  services.displayManager.sessionPackages = [ pkgs.niri ];
  programs.niri.enable = true;

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.logind.settings.Login.HandleLidSwitch = "ignore";

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  services.openssh = {
    enable = true;
    ports = [ 5432 ];
    settings = {
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = true;
      PermitRootLogin = "no";
      AllowUsers = [ "erfan" ];
    };
  };

  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    host = "0.0.0.0";
    openFirewall = true;
  }; 

  # security.pki.certificates = [ ... ];  # redacted: private CA certificate

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.erfan = {
    isNormalUser = true;
    description = "Erfan";
    extraGroups = [ "networkmanager" "wheel" "docker" "vboxusers" ];
    packages = with pkgs; [];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true; 
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  virtualisation.docker = {
    enable = true;
    extraOptions = ''
      --insecure-registry https://10.22.0.222
    '';
  };
  virtualisation.virtualbox.host.enable = true;
  services.resolved.enable = true;

  programs.nekoray.tunMode.enable = true;
  programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    curl
    git

    xwayland-satellite
    libinput
    cudaPackages.cudatoolkit
    firefox
    home-manager nekoray python313Packages.pyinstaller jupyter
    partclone parted
    v2rayn
    qemu nmap ntfs3g
    proxychains
    unstable.opencode
    unrar teamviewer
    go
  ];

  environment.sessionVariables = {
    CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  systemd.user.services.stand-reminder = {
    description = "Hourly reminder to stand up and walk";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    
    serviceConfig = {
      Type = "simple";
      ExecStart = pkgs.writeShellScript "stand-reminder" ''
        # Get the user's bus address from the running environment
        export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
        
        while true; do
          sleep 3600
          ${pkgs.libnotify}/bin/notify-send \
            -u critical \
            -t 900000 \
            -i "preferences-system-time" \
            "Time to Move!" \
            "Stand up and walk for a few minutes 💪"
        done
      '';
      Restart = "always";
      RestartSec = 30;
      Environment = "DISPLAY=:0";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
