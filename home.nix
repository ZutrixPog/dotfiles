{ config, pkgs, ... }:

{
  home.username = "erfan";
  home.homeDirectory = "/home/erfan";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    git curl wget unzip inetutils
    zip tmux android-tools
    alacritty
    waybar
    wofi
    wlogout
    wl-clipboard grim slurp swappy
    swww
    swaybg
    mako libnotify
    swaylock-effects
    bluez blueman
    ffmpeg
    gcc gnumake
    go
    imagemagick
    rustup just
    ripgrep mpv
    nekoray gimp

    xfce.thunar
    xfce.thunar-volman
    xfce.thunar-archive-plugin
    xfce.tumbler

    pkgs.nerd-fonts.comic-shanns-mono
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    oh-my-zsh.enable = true;

    oh-my-zsh.theme = "robbyrussell";

    initContent = ''
      export PATH="$PATH:$HOME/.local/bin:$HOME/.cargo/bin:${PATH:-/run/current-system/sw/bin}"
    '';
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true; # plugins
  };


  gtk = {
    enable = true;

    theme = {
      name = "Gruvbox-Dark";
      package = pkgs.gruvbox-gtk-theme;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

  programs.tmux.enable = true;

  fonts.fontconfig.enable = true;

  home.file = {
    ".tmux.conf".source = ./config/tmux/tmux.conf;
  };

  xdg.configFile."alacritty".source = ./config/alacritty;
  xdg.configFile."nvim".source = ./config/nvim;
  xdg.configFile."waybar".source = ./config/waybar;
  xdg.configFile."niri".source = ./config/niri;
  xdg.configFile."wofi".source = ./config/wofi;
  xdg.configFile."wallpaper".source = ./config/wallpaper;
  xdg.configFile."scripts".source = ./config/scripts;
  xdg.configFile."wlogout".source = ./config/wlogout;
  xdg.configFile."mako".source = ./config/mako;

}

