############################################################################
#
#  Nix commands related to the local machine
#
############################################################################

# Thanks hyduez.

# Build system packages and create a new entry on boot
# usage: make deploy
deploy:
  sudo nixos-rebuild switch --flake .

# Updgrade all system packages
# usage: make upgrade
upgrade:
  sudo nixos-rebuild switch --upgrade --flake .

# Same as deploy command, but log every action
# usage: make debug
debug:
  sudo nixos-rebuild switch --flake . --show-trace --verbose

# Update all flakes links
# usage: make up
up:
  sudo nix flake update

# Update specific input
# usage: make upp i=home-manager
upp:
  sudo nix flake update $(i)

# Create a new system without entry on boot
# usage: make test
test:
  sudo nixos-rebuild test --flake .

history:
  nix profile history --profile /nix/var/nix/profiles/system

repl:
  nix repl -f flake:nixpkgs

clean:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

gc-sudo:
  sudo nix-collect-garbage -d

gc:
  nix-collect-garbage -d

gcboot:
  sudo /run/current-system/bin/switch-to-configuration boot
