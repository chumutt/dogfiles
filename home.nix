{ config, pkgs, ... }: {
  imports = [ ./shells.nix ]; # Do not rename to shell.nix: filename is reserved.
  home = {
    username = "chu";
    homeDirectory = "/home/chu";
    stateVersion = "24.05"; # Do not change.

    packages = with pkgs; [
      cachix
      man-db
      zsh
      tldr
      bc
      rsync
      ffmpeg
      yt-dlp
      fontconfig
      # put dwm here (?)
      dmenu
      (dwmblocks.overrideAttrs {
        src = pkgs.fetchFromGitHub {
          owner = "chumutt";
          repo = "dwmblocks";
          rev = "main";
          sha256 = "KTW2fUWiWJjyHbpEbnaEq3wcuncn4fM5xk1o8CpEdOE=";
        };
      }) # TODO add missing sb-* scripts
      st
      arandr
      xwallpaper
      dunst
      pywal # the new wal
      pavucontrol
      raysession

      # Doom Emacs stack
      fd
      (ripgrep.override { withPCRE2 = true; })
      nixfmt-rfc-style # :lang nix
      emacs-all-the-icons-fonts
      (nerdfonts.override { fonts = [ "FiraCode" ]; }) # doom emacs default font
      gnumake
      cmake
      gcc
      libtool

      thunderbird
      nextcloud-client
    ];

    file = { ".xinitrc".source = ./x11/xinitrc; };

    sessionVariables = {
      EDITOR = "neovim";
      TERMINAL = "st";
      TERMINAL_PROG = "st";
      VISUAL = "emacs";
      BROWSER = "librewolf";
      DOOMDIR = "${config.xdg.configHome}/doom";
      EMACSDIR = "${config.xdg.configHome}/emacs";
      DOOMLOCALDIR = "${config.xdg.dataHome}/doom";
      DOOMPROFILELOADFILE = "${config.xdg.stateHome}/doom-profiles-load.el";
    };

    sessionPath =
      [ "${config.xdg.configHome}/emacs/bin" ]; # ./doom sync, upgrade etc

  };

  programs = {
    home-manager.enable = true;
    zsh.enable = true;
    librewolf = {
      enable = true;
      settings = {
        "webgl.disabled" = false;
        "privacy.resistFingerprinting" = false;
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.cookies" = false;
        "network.cookie.lifetimePolicy" = 0;
      };
    };
    # Emacs
    emacs = { enable = true; };

    git = {
      enable = true;
      userName = "chumutt";
      userEmail = "chufilthymutt@gmail.com";
      extraConfig = { init.defaultBranch = "main"; };
    };
  };

  # thanks j4m3s
  systemd.user.sessionVariables = {
    DOOMLOCALDIR = "$HOME/.local/share/doomemacs";
    DOOMPROFILELOADFILE = "$HOME/.local/share/doomemacs/profiles/load.el";
  };

  # emacs daemon (emacsclient) service
  services.emacs.enable = true;

  # Autoload fonts from packages installed via Home Manager
  fonts.fontconfig.enable = true;

}
