# instawow, built from the tip of the `main` branch on GitHub.
#
# nixpkgs' instawow package tracks tagged releases, which lag behind what's
# actually needed here. This packages the latest main commit instead. The
# upstream pyproject.toml determines its version dynamically via
# versioningit, which needs real git tag history that a fetchFromGitHub
# tarball doesn't carry - so postPatch swaps that out for a static version
# string matching the pinned commit below.
{ pkgs }:
let
  # Must stay PEP 440-valid (no hyphens) since it's spliced verbatim into
  # pyproject.toml's static `version` field below.
  version = "7.0.0.dev20260919";
  rev = "02a430aad01475339569b60b0a3fe8a9b338551d";

  # nixpkgs' click (8.3.1) is older than main's floor (>=8.4.1) - and this
  # isn't just a metadata mismatch: instawow's CLI actually uses the
  # generic-subscriptable ParamType that 8.4 added, so it crashes at
  # runtime on 8.3.1. Pull a newer click from PyPI instead of relaxing it.
  click_8_4 = pkgs.python3.pkgs.click.overridePythonAttrs (_: rec {
    version = "8.4.1";
    src = pkgs.fetchPypi {
      pname = "click";
      inherit version;
      hash = "sha256-kYtWM+3fa0HDLU9FS/DegQBlx04/fb+O5UUvi+iNPpY=";
    };
  });
in
pkgs.python3.pkgs.buildPythonApplication {
  pname = "instawow";
  inherit version;
  pyproject = true;

  src = pkgs.fetchFromGitHub {
    owner = "layday";
    repo = "instawow";
    inherit rev;
    hash = "sha256-tyGdeBXLUv6EOYub+zVMkniXm1uq8+JXwJX+FOjQDoM=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'dynamic = [
  "version",
]' 'version = "${version}"' \
      --replace-fail '[tool.hatch.version]
source = "versioningit"' "" \
      --replace-fail 'requires = ["hatchling", "versioningit"]' 'requires = ["hatchling"]'
  '';

  nativeBuildInputs = with pkgs.python3.pkgs; [
    hatchling
  ];

  propagatedBuildInputs = with pkgs.python3.pkgs; [
    aiohttp
    aiohttp-client-cache
    attrs
    cattrs
    click_8_4
    diskcache
    loguru
    packaging
    pluggy
    prompt-toolkit
    rapidfuzz
    truststore
    typing-extensions
    wcwidth
    yarl
  ];

  pythonImportsCheck = [ "instawow" ];

  meta = {
    homepage = "https://github.com/layday/instawow";
    description = "World of Warcraft add-on manager CLI and GUI (main branch)";
    mainProgram = "instawow";
    license = pkgs.lib.licenses.gpl3Plus;
  };
}
