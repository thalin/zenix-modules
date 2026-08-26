# SDDM cinematic video-background theme.
#
# The original https://github.com/3ximus/aerial-sddm-theme has no
# QtVersion=6 marker in its metadata.desktop, so current (Qt6-only) SDDM
# assumes it needs the legacy "sddm-greeter" binary - which nixpkgs no
# longer ships at all - and silently falls back to a built-in default
# theme instead of erroring. Using a maintained Qt6 port of the same
# cinematic-video-background concept instead.
# https://github.com/RussH/Aerial-Cinematic-Qt6

{ pkgs }:

pkgs.stdenv.mkDerivation {
  name = "ariel-sddm-theme";
  src = pkgs.fetchFromGitHub {
    owner = "RussH";
    repo = "Aerial-Cinematic-Qt6";
    rev = "1b88045167f0f2916a3a7bb28c7102cd412747bf";
    sha256 = "0w6jgq791rhfhpi35qwlay6rb2qnd7498ph6q8hvqf0fndj51b0i";
  };
  installPhase = ''
    mkdir -p $out/share/sddm/themes/aerial-cinematic-qt6
    cp -R ./* $out/share/sddm/themes/aerial-cinematic-qt6/
  '';
}
