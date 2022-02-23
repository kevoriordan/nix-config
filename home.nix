{ config, pkgs, rosettaPkgs, lib, username, homeDir, ... }:
let
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
    awscli
    starship # gives you a nicer zsh prompt
    bat # nicer version of cat
    black
    broot
    dhall
    dhall-json
    dos2unix
    exa
    fd # nicer version of find command 
    fzf # Needed by zsh-interactive-cd plugin
    getopt
    git
    emacs
    gnumake
    nixpkgs-fmt
    niv
    nodejs
    postgresql_13.lib
    procs
    gitAndTools.gh
    jq
    curl
    aws-iam-authenticator
    cabal-install
   # rosettaPkgs.cabal2nix
    coreutils
    curl
    gettext
    go
    nix-prefetch-git
    oh-my-zsh # nice zsh plugins
    pre-commit
    sbt
    scala
    scala-cli
    skopeo
    stylish-haskell
    telnet
    direnv
    cachix
    nix-direnv
    gnupg
    bottom
    wget
    zsh-autosuggestions
    zsh-syntax-highlighting
    silver-searcher # ag command, grep -r on steroids
  ];

  home.file.".iterm2_shell_integration.zsh".source =
    ./home/.iterm2_shell_integration.zsh;
  home.file."${xdgCacheHome}/oh-my-zsh/.keep".text = "";
  home.file."${xdgConfigHome}/git/.keep".text = "";
  home.sessionPath = [ "$HOME/google-cloud-sdk/bin" ];

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
      ssh.postBuffer = 524288000;
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
          rev = "v0.7.0";
          sha256 = "sha256-1fD9HDIjlscFHekrlejtSM506Czzm4hfr4GrJOOkdJk=";
        };
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "2cd73fcbde1b47f0952027c0674c32b9f1756a59";
          sha256 = "sha256-1fD9HDIjlscFHekrlejtSM506Czzm4hfr4GrJOOkdJk=";
        };
      }
    ];
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "aws"
        "docker"
        "gcloud"
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
      hostname = "nix-docker";
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

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";

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
