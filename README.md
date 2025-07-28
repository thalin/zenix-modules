# Zen Nix Modules

Common modules to make it easier to support multiple NixOS host repos for different purposes. As much configuration as possible is stored here so I can just import it in other repos.

Uses [snowfall-lib](https://snowfall.org/guides/lib/quickstart/) for easy file structuring and reduced boilerplate.

## Structure

This repository is structured to provide a modular and reusable set of configurations for NixOS, home-manager, and Darwin.

-   `flake.nix`: The entry point for the flake, which uses `snowfall-lib` to build the final outputs.
-   `lib/`: Contains custom helper functions used throughout the repository.
-   `modules/`: This is the core of the repository, containing all the NixOS, home-manager, and Darwin modules.
    -   `home/`: Home-manager modules.
    -   `nixos/`: NixOS modules.
    -   `darwin/`: Darwin modules (planned).
-   `packages/`: Contains custom packages that are not available in nixpkgs or need to be overridden.

Within each of the `home`, `nixos`, and `darwin` directories, the modules are further organized into:

-   **modules**: Individual configurations for specific applications or services (e.g., `git`, `zsh`, `steam`).
-   **roles**: Collections of modules that represent a specific function of a machine (e.g., `cli`, `gui-desktop`, `server`).
-   **suites**: Collections of roles that define a complete system type (e.g., `workstation`, `laptop`, `gaming`).

## Usage

To use these modules in your own NixOS configuration, add this repository as an input to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    zenix-modules.url = "github:thalin/zenix-modules";
  };

  outputs = { self, nixpkgs, zenix-modules, ... }@inputs: {
    nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        # Import the zenix modules
        zenix-modules.nixosModules.default
        # Enable a suite
        ({ config, ... }: {
          zen.suites.workstation.enable = true;
        })
      ];
    };
  };
}
```

You can then enable the modules, roles, or suites you want to use in your configuration.

## Contributing

Feel free to open an issue or pull request if you have any suggestions or improvements.