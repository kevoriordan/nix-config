{ config, pkgs, lib, ... }:
let
  username = builtins.getEnv "USER";
  homeDir = "/Users/${username}";
  inherit (pkgs) lorri;

in
{

  imports = [ <home-manager/nix-darwin> ];

  home-manager.useUserPackages = true;

  users.users.${username} = {
    home = homeDir;
    description = "${username}'s account";
    shell = pkgs.zsh;
  };

  home-manager.users.${username} = import ./home.nix {
    inherit config;
    inherit pkgs;
    inherit lib;
    inherit username;
    inherit homeDir;
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [ lorri source-code-pro ];

  fonts.enableFontDir = true;
  # Source code pro is needed by Spacemacs
  # powerline-fonts needed by zsh agnoster theme
  fonts.fonts = with pkgs; [ source-code-pro powerline-fonts ];
  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  networking.hostName = "KevinMacbookPro";

  programs.nix-index.enable = true;
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  services.activate-system.enable = true;

  # Don't want Spotlight trying to index /nix dir
  system.activationScripts.postActivation.text = ''
    printf "disabling spotlight indexing... "
    mdutil -i off -d / &> /dev/null
    mdutil -E / &> /dev/null
    echo "ok"
  '';

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  nix = {
    package = pkgs.nix;

    maxJobs = 8;
    buildCores = 1;
    trustedUsers = [ "@root" username ];
    distributedBuilds = true;
    buildMachines = [{
      hostName = "nix-docker";
      sshUser = "root";
      sshKey = "/etc/nix/docker_rsa";
      systems = [ "x86_64-linux" ];
      maxJobs = 6;
      buildCores = 6;
    }];


    binaryCaches = [
      "https://cache.nixos.org"
      "https://cache.dhall-lang.org"
      "https://static-haskell-nix.cachix.org"
      "https://nix-tools.cachix.org"
      "https://all-hies.cachix.org"
      "https://earnestresearch-public.cachix.org"
      "https://earnestresearch-private.cachix.org"
      "https://iohk.cachix.org"
      "https://hercules-ci.cachix.org"
      "https://ghcide-nix.cachix.org"
      "https://nix-community.cachix.org"
    ];

    binaryCachePublicKeys = [
      "cache.dhall-lang.org:I9/H18WHd60olG5GsIjolp7CtepSgJmM2CsO813VTmM="
      "static-haskell-nix.cachix.org-1:Q17HawmAwaM1/BfIxaEDKAxwTOyRVhPG5Ji9K3+FvUU="
      "nix-tools.cachix.org-1:ebBEBZLogLxcCvipq2MTvuHlP7ZRdkazFSQsbs0Px1A="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "all-hies.cachix.org-1:JjrzAOEUsD9ZMt8fdFbzo3jNAyEWlPAwdVuHw4RD43k="
      "earnestresearch-public.cachix.org-1:eX0tpfc0sCJOdMQrnIUuh1jzzbpED7WIj7GVRxiCkio="
      "earnestresearch-private.cachix.org-1:zD6+/1y6BmLQDgnf5TI0q09cRTxDYYcs9dsh1z3BMa4="
      "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
      "hercules-ci.cachix.org-1:ZZeDl9Va+xe9j+KqdzoBZMFJHVQ42Uu/c/1/KMC5Lw0="
      "ghcide-nix.cachix.org-1:ibAY5FD+XWLzbLr8fxK6n8fL9zZe7jS+gYeyxyWYK5c="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
    gc = {
      automatic = false;
      options = "--delete-older-than 14d";
    };
    nixPath = [
      "darwin-config=$HOME/.nixpkgs/darwin-configuration.nix"
      "darwin=$HOME/.nix-defexpr/channels/darwin"
      "$HOME/.nix-defexpr/channels"
    ];
  };

  nixpkgs.config.allowUnfree = true;



  system.defaults.NSGlobalDomain.AppleKeyboardUIMode = 3;
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
  # Enable subpixel font rendering on non-Apple LCD
  system.defaults.NSGlobalDomain.AppleFontSmoothing = 2;
  # system.defaults.NSGlobalDomain.InitialKeyRepeat = 10;
  # system.defaults.NSGlobalDomain.KeyRepeat = 1;
  system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
  # Enable/disable autocorrect
  system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
  system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
  system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;

  system.defaults.dock.autohide = false;
  system.defaults.dock.orientation = "bottom";
  system.defaults.dock.showhidden = true;
  system.defaults.dock.mru-spaces = false;

  # Show all filename extensions in Finder
  system.defaults.finder.AppleShowAllExtensions = true;
  # Allow quitting Finder via ⌘ + Q; doing so will also hide desktop icons
  system.defaults.finder.QuitMenuItem = true;
  system.defaults.finder.FXEnableExtensionChangeWarning = false;
  # Show full POSIX path in Finder window title
  system.defaults.finder._FXShowPosixPathInTitle = true;

  # Lorri watches for changes in nix config to speed up direnv reloading
  # XXX: Copied verbatim from https://github.com/iknow/nix-channel/blob/7bf3584e0bef531836050b60a9bbd29024a1af81/darwin-modules/lorri.nix
  launchd.user.agents = {
    "lorri" = {
      serviceConfig = {
        WorkingDirectory = (builtins.getEnv "HOME");
        EnvironmentVariables = { };
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "/var/tmp/lorri.log";
        StandardErrorPath = "/var/tmp/lorri.log";
      };
      script = ''
        source ${config.system.build.setEnvironment}
        exec ${lorri}/bin/lorri daemon
      '';
    };
  };

}
