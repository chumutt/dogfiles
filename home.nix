{ pkgs, ... }:
let
  myShellAliases = { # TODO
    ls = "eza --icons -l -T -L=1";
    cat = "bat";
    htop = "btm";
    fd = "fd -Lu";
    w3m = "w3m -no-cookie -v";
    neofetch = "disfetch";
    fetch = "disfetch";
    gitfetch = "onefetch";
    # "," = "comma";
  };
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "chu";
  home.homeDirectory = "/home/chu";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    # cli/novel
    fortune
    hyfetch
    asciiquarium
    cowsay

    # cli/useful
    lolcat
    killall
    htop-vim
    bottom
    disfetch
    onefetch
    gnugrep
    gnused
    bat
    eza
    fd
    bc
    direnv
    nix-direnv

    # gui
    firefox
    # librewolf
    qutebrowser
    # nyxt
    zathura
    nextcloud-client

  ];

  # Per-directory shell environments
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".config/emacs/init.el".source = ./chumacs/init.el;
    ".config/emacs/config.el".source = ./chumacs/config.el;
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

  home.sessionVariables = { EDITOR = "emacs"; };

  # Whether to manage {file}$XDG_CONFIG_HOME/user-dirs.dirs.
  # The generated file is read-only.
  xdg.userDirs = {
    enable = true; # Default is false.
    createDirectories =
      true; # Automatically create XDG directories if none exist.
  };

  # Whether to make programs use XDG directories whenever supported.
  home.preferXdgDirectories = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Z-Shell
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    autocd = true;
    dotDir = ".config/zsh";
    shellAliases = myShellAliases;
    history = {
      size = 10000000; # Number of history lines to keep
      save = 10000000; # Number of history lines to save
      path = ".cache/zsh/history";
      expireDuplicatesFirst = true;
    };
    historySubstringSearch.enable = true;
    initExtra = ''
    [ $TERM = "dumb" ] && unsetopt zle && PS1='$ '

    # Enable colors and change prompt:
    autoload -U colors && colors # Load colors

    PS1="%B%{$fg[green]%}[%{$fg[magenta]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[green]%}]%{$reset_color%}$%b "
    
    # Basic auto/tab complete:
    autoload -U compinit
    zstyle ':completion:*' menu select
    zmodload zsh/complist
    compinit
    _comp_options+=(globdots)		# Include hidden files.
    
    # vi mode
    bindkey -v
    export KEYTIMEOUT=1
    
    # Use vim keys in tab complete menu:
    bindkey -M menuselect 'h' vi-backward-char
    bindkey -M menuselect 'k' vi-up-line-or-history
    bindkey -M menuselect 'l' vi-forward-char
    bindkey -M menuselect 'j' vi-down-line-or-history
    bindkey -v '^?' backward-delete-char
    
    # Use lf to switch directories and bind it to ctrl-o
    lfcd () {
    tmp=\"$(mktemp -uq)\"
    trap 'rm -f $tmp >/dev/null 2>&1 && trap - HUP INT QUIT TERM PWR EXIT' HUP INT QUIT TERM PWR EXIT
    lf -last-dir-path=\"$tmp\" \"$@\"
    if [ -f \"$tmp\" ]; then
    dir=\"$(cat \"$tmp\")\"
    [ -d \"$dir\" ] && [ \"$dir\" != \"$(pwd)\" ] && cd \"$dir\"
    fi
    }
    bindkey -s '^o' '^ulfcd\n'
    bindkey -s '^a' '^ubc -lq\n'
    bindkey -s '^f' '^ucd \"$(dirname \"$(fzf)\")\"\n'
    bindkey '^[[P' delete-char
    
    # Edit line in vim with ctrl-e:
    autoload edit-command-line; zle -N edit-command-line
    bindkey '^e' edit-command-line
    bindkey -M vicmd '^[[P' vi-delete-char
    bindkey -M vicmd '^e' edit-command-line
    bindkey -M visual '^[[P' vi-delete
    '';
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = myShellAliases;
  };

  # GNU Emacs
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-gtk;
    extraPackages = epkgs:
      with epkgs; [
        nix-mode
        magit
        evil-collection
        command-log-mode
        doom-modeline
        all-the-icons
        doom-themes # optional
        which-key
        ivy-rich
        counsel
        rainbow-delimiters
      ];
  };

  services.emacs = {
    # Whether to enable the Emacs daemon
    client.enable = true;
    # Whether to enable systemd socket activation for the Emacs service daemon.
    socketActivation.enable = true;
    # Whether to launch Emacs service with the systemd user session.
    # If it is [set to] "graphical", Emacs service is started by graphical-session.target.
    startWithUserSession = "graphical";
  };

  # Neovim
  programs.neovim.enable = true;

  # Git
  programs.git = {
    enable = true;
    userEmail = "chufilthymutt@gmail.com";
    userName = "chu";
  };

  # TeX Live, used for TeX typesetting package distribution.
  programs.texlive = { enable = true; };

  # thefuck - magnificent app that corrects your previous console command.
  programs.thefuck = { enable = true; };

  # Thunderbird.
  programs.thunderbird = {
    enable = true;
    profiles."chu".isDefault = true; # TODO make this the generic user variable
  };

  # GnuPG private key agent.
  services.gpg-agent = {
    enable = true;
    # Set the time a cache entry is valid to the given number of seconds.
    defaultCacheTtl = 1800;
    # Whether to use the GnuPG key agent for SSH keys or not.
    enableSshSupport = true;
  };
}
