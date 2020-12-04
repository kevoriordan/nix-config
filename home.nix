{ config, pkgs, username, homeDir, ... }:
let
  erNixUrl =
    "https://github.com/EarnestResearch/er-nix/archive/5cee1a6f0bd707785924dcb4fb427c7bcd3e1765.tar.gz";
  erNix = (import (builtins.fetchTarball erNixUrl)).pkgs;
  cfg = config.home-manager.users.${username};
  xdgConfigHomeRelativePath = ".config";
  xdgDataHomeRelativePath = ".local/share";
  xdgCacheHomeRelativePath = ".cache";

  xdgConfigHome = "${homeDir}/${xdgConfigHomeRelativePath}";
  xdgDataHome = "${homeDir}/${xdgDataHomeRelativePath}";
  xdgCacheHome = "${homeDir}/${xdgCacheHomeRelativePath}";

in
{
  home.packages = with pkgs; [
    erNix.okta-aws-login
    awscli
    starship # gives you a nicer zsh prompt
    bat # nicer version of cat
    black
    broot
    dhall
    dhall-json
    dos2unix
    fd # nicer version of find command 
    fzf # Needed by zsh-interactive-cd plugin
    getopt
    git
    emacs
    nixpkgs-fmt
    pinentry_mac # For yubikey
    postgresql
    gitAndTools.gh
    kubectx
    kubectl
    eksctl
    jq
    curl
    aws-iam-authenticator
    cabal-install
    cabal2nix
    erNix.stack
    erNix.hlint
    coreutils
    curl
    ghc
    gettext
    go
    nix-prefetch-git
    oh-my-zsh # nice zsh plugins
    python3
    python3Packages.pip
    python3Packages.pylint
    pre-commit
    sbt
    scala
    skopeo
    stylish-haskell
    telnet
    direnv
    cachix
    nix-direnv
    gnupg
    wget
    zsh-autosuggestions
    zsh-syntax-highlighting
    silver-searcher # ag command, grep -r on steroids
  ];

  home.file.".iterm2_shell_integration.zsh".source =
    ./home/.iterm2_shell_integration.zsh;
  home.file."${xdgCacheHome}/oh-my-zsh/.keep".text = "";
  home.file."${xdgConfigHome}/git/.keep".text = "";

  xdg = {
    enable = true;
    configHome = xdgConfigHome;
    dataHome = xdgDataHome;
    cacheHome = xdgCacheHome;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.bat.enable = true;
  programs.broot.enable = true;

  # Git commit signing stuff
  programs.git = {
    enable = true;
    userName = "Kevin O'Riordan";
    userEmail = builtins.readFile ./local/userEmail.txt;
    signing = {
      key = builtins.readFile ./local/signingKey.txt;
      signByDefault = true;
      gpgPath = "gpg";
    };
    extraConfig = {
      push.default = "current";
      pull.rebase = true;
      core.editor = "vim";
      credential.helper = "osxkeychain";
      color.ui = true;
    };
    ignores = [ ".direnv/" ".metals/" ".vscode/" "live/application/shared/configs/application.ini" ];
  };

  programs.zsh = {
    enable = true;
    history = {
      size = 500;
      save = 500;
    };
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.6.3";
          sha256 = "1h8h2mz9wpjpymgl2p7pc146c1jgb3dggpvzwm9ln3in336wl95c";
        };
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "be3882aeb054d01f6667facc31522e82f00b5e94";
          sha256 = "0w8x5ilpwx90s2s2y56vbzq92ircmrf0l5x8hz4g1nx3qzawv6af";
        };
      }
    ];
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "aws"
        "docker"
        "kubectl"
        "cabal"
        "stack"
        "sudo"
        "sbt"
        "scala"
        "zsh-interactive-cd"
      ];
      theme = "robbyrussell";
    };
    shellAliases = {
      gs = "git status";
      gc = "git commit";
      gl = "git log";
      gb = "git checkout";
      pull = "git pull";
      okta = "okta-aws-login -p development -p production --user koriordan";
      devaws = "export AWS_PROFILE=development";
      prodaws = "export AWS_PROFILE=production";
      k8 = "kubectl";
      prodctx =
        "export AWS_PROFILE=production; kubectx services-production-admin";
      devctx = "export AWS_PROFILE=development; kubectx services-development";
      listpods = "kubectl get pod -n data-platform";
    };
    enableAutosuggestions = true;
    sessionVariables = {
      AWS_PROFILE = "development";
      EDITOR = "vim";
      VISUAL = "vim";
      GIT_EDITOR = "vim";
      HOME_MANAGER_CONFIG = "/Users/${username}/.config/nixpkgs/home.nix";
    };
    # Need this for gpg-agent init
    initExtraBeforeCompInit = builtins.readFile ./home/pre-compinit.zsh;
  };

  # Starship is nicer prompt for zsh
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = false;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.ssh = {
    enable = true;
    matchBlocks.nix-docker = {
      hostname = "127.0.0.1";
      user = "root";
      port = 3022;
      identityFile = "/etc/nix/docker_rsa";
      extraOptions = {
        StrictHostKeyChecking = "no";
      };
    };
    # Configure SSH tunnelling
    matchBlocks."172.16.*" = {
      extraOptions = {
        ProxyCommand =
          "/usr/bin/ssh ubuntu@${username}.bastion.dev.earnestresearch.com /bin/nc %h %p";
      };
    };
    matchBlocks."10.2.*" = {
      extraOptions = {
        ProxyCommand =
          "/usr/bin/ssh ubuntu@${username}.bastion.earnestresearch.com /bin/nc %h %p";
      };
    };
  };

  programs.gpg.enable = true;

  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
    enable-ssh-support
    default-cache-ttl 60
    max-cache-ttl 120
  '';

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";

  # I prefer Neovim to traditional Vim
  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;

    plugins = with pkgs.vimPlugins; [
      vim-nix
      vim-gitgutter
      vim-airline
      vim-stylish-haskell
      ghcid
      vim-scala
      haskell-vim
      vim-flake8
    ];
  };

}
