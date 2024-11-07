# Ariel SDDM theme
# https://github.com/3ximus/aerial-sddm-theme

{ pkgs }:

pkgs.stdenv.mkDerivation {
  name = "ariel-sddm-theme";
  src = pkgs.fetchFromGitHub {
    owner = "3ximus";
    repo = "aerial-sddm-theme";
    rev = "92b85ec7d177683f39a2beae40cde3ce9c2b74b0";
    sha256 = "10c38q5d6czjlmcazf99ynrpkzppshrh0bx3kq1v4fpdwy367iyh";
  };
  installPhase = ''
    mkdir -p $out
    cp -R ./* $out/
  '';
}
