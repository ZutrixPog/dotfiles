{ config, pkgs, ... }:

{
  home.username = "erfan";
  home.homeDirectory = "/home/erfan";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    git curl wget unzip inetutils
    zip tmux android-tools
    alacritty
    wl-clipboard
    libnotify
    bluez blueman
    ffmpeg
    gcc gnumake
    imagemagick
    rustup just
    ripgrep mpv
    nekoray gimp
    zip

    xfce.thunar
    xfce.thunar-volman
    xfce.thunar-archive-plugin
    xfce.tumbler
    loupe

    pkgs.nerd-fonts.comic-shanns-mono
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # syntaxHighlighting.enable = true;
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

  programs.noctalia = {
    enable = true;
    settings = ./config/noctalia/config.toml;
  };

  fonts.fontconfig.enable = true;

  home.file = {
    ".tmux.conf".source = ./config/tmux/tmux.conf;
  };

  xdg.configFile."alacritty".source = ./config/alacritty;
  xdg.configFile."nvim".source = ./config/nvim;
  xdg.configFile."niri".source = ./config/niri;
  xdg.configFile."wallpaper".source = ./config/wallpaper;
  xdg.configFile."scripts".source = ./config/scripts;

}

