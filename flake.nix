{
  description = "chu's nixOS config flake";

  outputs =
    inputs@{
      self,
      nixpkgs,
      nur,
      ...
    }:
    let
      # ---- SYSTEM SETTINGS ---- #
      systemSettings = {
        system = "x86_64-linux";
        hostname = "chunix";
        profile = "work";
        timezone = "America/Chicago";
        locale = "en_US.UTF-8";
        bootMode = "uefi"; # uefi or bios
        bootMountPath = "/boot"; # mount path for efi boot partition; only used for uefi boot mode
        grubDevice = ""; # device identifier for grub; only used for legacy (bios) boot mode
        gpuType = "amd"; # amd, intel or nvidia; only makes some slight mods for amd at the moment
      };
      # ----- USER SETTINGS ----- #
      userSettings = rec {
        username = "chu";
        name = "chu";
        email = "chufilthymutt@gmail.com";
        dotfilesDir = "/home/chu/.config/dogfiles";
        theme = "solarized-dark"; # selcted theme from the LibrePhoenix themes directory (./themes/)
        wm = "plasma";
        # window manager type (hyprland or x11) translator
        wmType = "x11";
        browser = "firefox"; # Default browser; must select one from ./user/app/browser/
        defaultRoamDir = "roam"; # Default org roam directory relative to ~/Org
        term = "konsole";
        font = "Noto Sans"; # Selected font
        fontPkg = pkgs.noto-fonts; # Font package
        editor = "nvim";
        # spawnEditor =
        #   if (editor == "emacsclient") then
        #     "emacsclient -c -a 'emacs'"
        #   else
        #     (
        #       if ((editor == "vim") || (editor == "nvim") || (editor == "nano")) then
        #         "exec " + term + " -e " + editor
        #       else
        #         editor
        #     );
      };
      # create patched nixpkgs
      nixpkgs-patched =
        (import inputs.nixpkgs {
          system = systemSettings.system;
          rocmSupport = (if systemSettings.gpu == "amd" then true else false);
        }).applyPatches
          {
            name = "nixpkgs-patched";
            src = inputs.nixpkgs;
          };
      # configure pkgs
      # use nixpkgs if running a server (homelab or worklab profile)
      # otherwise use patched nixos-unstable nixpkgs
      pkgs = (
        if ((systemSettings.profile == "homelab") || (systemSettings.profile == "worklab")) then
          pkgs-stable
        else
          (import nixpkgs-patched {
            system = systemSettings.system;
            config = {
              allowUnfree = true;
              allowUnfreePredicate = (_: true);
            };
          })
      );

      pkgs-stable = import inputs.nixpkgs-stable {
        system = systemSettings.system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
      };

      pkgs-unstable = import inputs.nixpkgs-patched {
        system = systemSettings.system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
      };

      pkgs-emacs = import inputs.emacs-pin-nixpkgs { system = systemSettings.system; };

      pkgs-kdenlive = import inputs.kdenlive-pin-nixpkgs { system = systemSettings.system; };

      # configure lib
      # use nixpkgs if running a server (homelab or worklab profile)
      # otherwise use patched nixos-unstable nixpkgs
      lib = (
        if ((systemSettings.profile == "homelab") || (systemSettings.profile == "worklab")) then
          inputs.nixpkgs-stable.lib
        else
          inputs.nixpkgs.lib
      );

      # use home-manager-stable if running a server (homelab or worklab profile)
      # otherwise use home-manager-unstable
      home-manager = (
        if ((systemSettings.profile == "homelab") || (systemSettings.profile == "worklab")) then
          inputs.home-manager-stable
        else
          inputs.home-manager-unstable
      );

      # Systems that can run tests:
      supportedSystems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
      ];

      # Function to generate a set based on supported systems:
      forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;

      # Attribute set of nixpkgs for each system:
      nixpkgsFor = forAllSystems (system: import inputs.nixpkgs { inherit system; });

    in
    {
      homeConfigurations = {
        user = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            (./. + "/profiles" + ("/" + systemSettings.profile) + "/home.nix") # load home.nix from selected PROFILE
          ];
          extraSpecialArgs = {
            inherit pkgs-stable;
            inherit systemSettings;
            inherit userSettings;
            inherit inputs;
          };
        };
      };
      nixosConfigurations = {
        system = lib.nixosSystem {
          system = systemSettings.system;
          modules = [
            (./. + "/profiles" + ("/" + systemSettings.profile) + "/configuration.nix")
            { nixpkgs.overlays = [ nur.overlay ]; }
            (
              { pkgs, ... }:
              let
                nur-no-pkgs = import nur {
                  nurpkgs = import nixpkgs { system = "x86_64-linux"; };
                };
              in
              {
                # imports = [ nur-no-pkgs.repos.iopq.modules.xraya ];
                # services.xraya.enable = true;
              }
            )
            #./configuration.nix or other imports here
          ]; # load configuration.nix from selected PROFILE
          specialArgs = {
            inherit pkgs-stable;
            inherit systemSettings;
            inherit userSettings;
            inherit inputs;
          };
        };
      };
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = self.packages.${system}.install;
          install = pkgs.writeShellApplication {
            name = "install";
            runtimeInputs = with pkgs; [ git ]; # I could make this fancier by adding other deps
            text = ''${./bin/install} "$@"'';
          };
        }
      );
      apps = forAllSystems (system: {
        default = self.apps.${system}.install;
        install = {
          type = "app";
          program = "${self.packages.${system}.install}/bin/install";
        };
      });
    };

  inputs = {

    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-24.05";

    home-manager-unstable.url = "github:nix-community/home-manager/master";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs";
    home-manager-stable.url = "github:nix-community/home-manager/release-24.05";
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs-stable";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };

    # Ad blocker
    blocklist-hosts = {
      url = "github:StevenBlack/hosts";
      flake = false;
    };

    nur.url = "github:nix-community/NUR";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
}
