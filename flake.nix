{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      with pkgs;
      {
        devShells.default = mkShell
          {
            buildInputs = [
              glew
              glfw3
              gcc
              zig_0_13
              zls
              wayland-scanner
              libGL
              libGLU
              freeglut
              wayland
              mesa
              mesa.drivers
            ];
            shellHook = ''
              export GBM_BACKEND=nvidia-drm
              export EGL_PLATFORM=wayland
              export __GLX_VENDOR_LIBRARY_NAME=nvidia
              export GLFW_USE_WAYLAND=1
              export LD_LIBRARY_PATH="${libGL}/lib:${libGLU}/lib:${freeglut}/lib:${glfw}/lib:${wayland}/lib"
            '';
          };
      }
    );
}
