{
  description = "Virtual environments for Scala projects";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, devshell, ... }:
    let
      typelevelShell = ./modules/typelevelShell.nix;

      systems = [
        "aarch64-darwin"
        # TODO no scala-cli
        # "aarch64-linux"
        # TODO jdk17 refers to openjdk-headless-16
        # "i686-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      forSystem = system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              self.overlays.default
            ];
          };

          devShells = {
            library = pkgs.devshell.mkShell {
              imports = [ typelevelShell ];
              name = "typelevel-lib-shell";
              typelevelShell.jdk.package = pkgs.jdk8_headless;
              typelevelShell.nodejs.enable = true;
              typelevelShell.native.enable = true;
            };
            application = pkgs.devshell.mkShell {
              imports = [ typelevelShell ];
              name = "typelevel-app-shell";
              typelevelShell.jdk.package = pkgs.jdk17_headless;
            };
          };
        in
        {
          checks = devShells // (import ./tests {
            inherit pkgs;
            inherit typelevelShell;
          });
        };
    in
    {
      inherit typelevelShell;
      overlays.default = devshell.overlays.default;
      templates = {
        library = {
          path = ./library;
          description = "A simple nix flake with the oldest LTS JDK supported set as the default.";
        };
        application = {
          path = ./application;
          description = "A simple nix flake with a more recent supported JDK set as the default.";
        };
      };
    } // flake-utils.lib.eachSystem systems forSystem;
}
