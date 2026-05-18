{
  description = "Development flake with uv and Python.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    inherit (nixpkgs) lib;

    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    forEachSupportedSystem = f:
      lib.genAttrs supportedSystems (
        system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          }
      );
  in {
    devShells = forEachSupportedSystem ({pkgs}: let
      python = pkgs.python312;
    in {
      default = pkgs.mkShell {
        packages = [
          python
          pkgs.python312Packages.python-lsp-server
          pkgs.ruff
          pkgs.uv
        ];
        env =
          {
            UV_PYTHON_DOWNLOADS = "never";
            UV_PYTHON = python.interpreter;
          }
          // lib.optionalAttrs pkgs.stdenv.isLinux {
            # glibc excluded: Determinate Nix (glibc-2.40, DT_RUNPATH) segfaults when a newer
            # glibc appears on LD_LIBRARY_PATH. Wheels resolve glibc via ELF interpreter, not here.
            LD_LIBRARY_PATH = lib.makeLibraryPath
              (builtins.filter (p: (p.pname or "") != "glibc") pkgs.pythonManylinuxPackages.manylinux1);
          };
        shellHook = ''
          unset PYTHONPATH
          echo
          echo "Development environment activated."
          echo
        '';
      };
    });
  };
}
