{ pkgs, ... }: {
  imports = [ ./modules/home-manager/default.nix ];
  home = {
    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    username = "chu";
    homeDirectory = "/home/chu";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "24.05"; # Please read the comment before changing.

    # The home.packages option allows you to install Nix packages into your
    # environment.
    # home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    # ];

    packages = with pkgs; [
      # cli
      zsh
      bash
      neovim
      git
      git-crypt
      tldr
      w3m # terminal web browser
      roswell
      xclip # terminal copy and paste
      pulsemixer # audio controller
      ispell
      aspell
      hunspell
      lf
      mediainfo # provides audio/video file info
      nixfmt-rfc-style
      gnupg
      pinentry

      # gui/X11
      dwm
      st
      unclutter # hides inactive mice
      maim # screenshots
      redshift # f.lux for x11
      slock
      firefox
      nextcloud-client
      keepassxc
      arandr
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      ".xinitrc".text = "dwm";

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    };

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. These will be explicitly sourced when using a
    # shell provided by Home Manager. If you don't want to manage your shell
    # through Home Manager then you have to manually source 'hm-session-vars.sh'
    # located at either
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/chu/etc/profile.d/hm-session-vars.sh
    #

    sessionVariables = {
      EDITOR = "neovim";
      # VISUAL= "emacs";
      DOTFILES_HOME = "$XDG_CONFIG_HOME/dogfiles";
      STEAM_EXTRA_COMPAT_TOOLS_PATHS =
        "\\\${HOME}/.steam/root/compatibilitytools.d";
    };

    shellAliases = {
      g = "git";
      ga = "git add .";
      gc = "git commit -m";

      "..." = "cd ../..";
      "...." = "cd ../../..";

      "chu-sync" =
        " sudo nixos-rebuild switch --flake ~/.config/dogfiles/#$HOST";

    };
  };

  ## User programs settings
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    # Git
    git = {
      enable = true;
      userEmail = "chufilthymutt@gmail.com";
      userName = "chumutt";
      aliases = {
        ci = "commit";
        co = "checkout";
        s = "status";
      };
      extraConfig = { push = { autoSetupRemote = true; }; };
    };
    ssh.enable = true;
    ssh.controlMaster = "yes";
    ssh.forwardAgent = true;
    # GnuPG
    gpg.enable = true;
    # Z-Shell (zsh)
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      autocd = true;
    };
    bash.enable = true;
    firefox.profiles.chu = {
      name = "chu";
      path = "chu";
      search = { default = "DuckDuckGo"; };
    };
  };
}
