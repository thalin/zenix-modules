nixzsh() {
    IN_NIX_SHELL=1 nix shell nixpkgs\#$1 -c zsh
}
