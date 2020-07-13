My laptop Nix configuration. Depends on Nix, nix-darwin and home-manager

## How to install
1. Install Nix (if on Catalina see https://github.com/NixOS/nix/issues/2925#issuecomment-539570232) 
2. Install [nix-darwin](https://github.com/LnL7/nix-darwin/) 
3. `git clone https://github.com/amarrella/nix-config ~/.nixpkgs`
4. `echo -n "your_email@your_provider.tld" > ~/.nixpkgs/local/userEmail.txt`
5. `echo -n "YOUR_SIGNING_KEY" > ~/.nixpkgs/local/signingKey.txt`
6. `darwin-rebuild switch`
