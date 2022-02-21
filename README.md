My laptop Nix configuration. Depends on Nix, nix-darwin and home-manager

## How to install
1. Install Nix (if on Catalina see https://github.com/NixOS/nix/issues/2925#issuecomment-539570232) 
2. Install [nix-darwin](https://github.com/LnL7/nix-darwin/) 
3. Install [home-manager](https://nix-community.github.io/home-manager/index.html#sec-install-nix-darwin-module)
4. `git clone https://github.com/kevoriordan/nix-config ~/.nixpkgs`
5. `echo -n "your_email@your_provider.tld" > ~/.nixpkgs/local/userEmail.txt`
6. `echo -n "YOUR_SIGNING_KEY" > ~/.nixpkgs/local/signingKey.txt`
7. `darwin-rebuild switch`
