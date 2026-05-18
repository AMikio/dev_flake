{
  description = "Development flake with uv, Python, and CUDA.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    inherit (nixpkgs) lib;

    # CUDA only works on Linux
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    forEachSupportedSystem = f:
      lib.genAttrs supportedSystems (
        system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
              config.cudaSupport = true;
            };
          }
      );
  in {
    devShells = forEachSupportedSystem ({pkgs}: let
      python = pkgs.python312;
      cuda = pkgs.cudaPackages.cudatoolkit;
    in {
      default = pkgs.mkShell {
        packages = [
          python
          pkgs.python312Packages.python-lsp-server
          pkgs.ruff
          pkgs.uv
          cuda
        ];
        env = {
          UV_PYTHON_DOWNLOADS = "never";
          UV_PYTHON = python.interpreter;
          CUDA_PATH = "${cuda}";
          # makeLibraryPath appends /lib; /run/opengl-driver/lib is appended as-is
          # glibc excluded: Determinate Nix (glibc-2.40, DT_RUNPATH) segfaults when a newer
          # glibc appears on LD_LIBRARY_PATH. Wheels resolve glibc via ELF interpreter, not here.
          LD_LIBRARY_PATH = "${lib.makeLibraryPath (
            (builtins.filter (p: (p.pname or "") != "glibc") pkgs.pythonManylinuxPackages.manylinux1)
            ++ [cuda pkgs.stdenv.cc.cc.lib]
          )}:/run/opengl-driver/lib";
          EXTRA_LDFLAGS = "-L/lib -L${cuda}/lib";
          EXTRA_CCFLAGS = "-I/usr/include";
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
