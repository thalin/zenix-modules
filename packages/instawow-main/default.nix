# instawow, pinned to a release ahead of what's currently in nixpkgs.
#
# nixpkgs' instawow package (7.0.0.post1 as of writing) lags behind what's
# actually needed here. This packages a newer upstream release instead. The
# upstream pyproject.toml determines its version dynamically via
# versioningit, which needs real git tag history that a fetchFromGitHub
# tarball doesn't carry - so postPatch swaps that out for a static version
# string matching the pinned tag below.
{ pkgs }:
let
  version = "7.2.1";

  # nixpkgs' click (8.3.1) is older than this release's floor (>=8.4.1) -
  # and this isn't just a metadata mismatch: instawow's CLI actually uses
  # the generic-subscriptable ParamType that 8.4 added, so it crashes at
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
    tag = "v${version}";
    hash = "sha256-5y+oJfzWwaUc3p4fzsQ4j8a6YJEsI+3Qy3gK6VPkjA4=";
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
    description = "World of Warcraft add-on manager CLI and GUI (newer than nixpkgs)";
    mainProgram = "instawow";
    license = pkgs.lib.licenses.gpl3Plus;
  };
}
