{
  description = "Development environments for Python and ML.";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
  in {
    templates = rec {
      default = python;

      python = {
        description = ''
          Default flake - Basic uv setup with Python.
        '';
        path = ./templates/python;
      };

      python-cuda = {
        description = ''
          CUDA flake - Development with GPU accelerated tools using CUDA.
        '';
        path = ./templates/python-cuda;
      };
    };

    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}
