# CLIProxyAPI: a proxy that exposes OpenAI/Gemini/Claude/Codex-compatible
# APIs on top of CLI OAuth logins. Not in nixpkgs.
#
# Upstream ships the binary as `CLIProxyAPI` built from ./cmd/server; it's
# renamed to `cli-proxy-api` here. CGO stays on (the nixpkgs default on
# linux) because the plugin host dlopens plugins through cgo.
{ pkgs }:
let
  version = "8.0.11";
in
pkgs.buildGoModule {
  pname = "cli-proxy-api";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "router-for-me";
    repo = "CLIProxyAPI";
    tag = "v${version}";
    hash = "sha256-1QbpQwtVRml8q5pP4QPVJe2okCTgwzaftN9KK5MAfP4=";
  };

  vendorHash = "sha256-r3yWkdMcM40G9jV7MxW/qNv3E9WrHavFilW24quEf+8=";

  subPackages = [ "cmd/server" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
    "-X main.Commit=v${version}"
    "-X main.BuildDate=1970-01-01T00:00:00Z"
  ];

  postInstall = ''
    mv $out/bin/server $out/bin/cli-proxy-api
  '';

  meta = {
    homepage = "https://github.com/router-for-me/CLIProxyAPI";
    description = "Proxy exposing OpenAI/Gemini/Claude/Codex-compatible APIs over CLI OAuth logins";
    mainProgram = "cli-proxy-api";
    license = pkgs.lib.licenses.mit;
    platforms = pkgs.lib.platforms.unix;
  };
}
