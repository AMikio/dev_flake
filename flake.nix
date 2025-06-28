{
    description = "Development environments for Python and ML.";

    inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    outputs = {nixpkgs, ...}: let
        forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in {
        templates = {
            default = {
                description = ''
                    Default flake - Basic uv setup with Python.
                '';
                path = ./templates/default;
            };

            cuda = {
                description = ''
                    CUDA flake - Development with GPU accelerated tools using CUDA.
                '';
                path = ./templates/cuda;
            };
        };

        formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    };
}
