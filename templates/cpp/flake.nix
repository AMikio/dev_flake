{
  description = "Basic Development flake for C++.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (
        system:
          f {
            pkgs = import nixpkgs {inherit system;};
          }
      );
  in {
    devShells = forEachSupportedSystem ({pkgs}: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          clang-tools
          cmake
          vcpkg
          vcpkg-tool
          pkg-config
          cmake-language-server
        ];

        env = {
          CC = "clang";
          CXX = "clang++";
        };

        shellHook = ''
          echo
          echo "Development environment activated."
          echo
        '';
      };
    });
  };
}
