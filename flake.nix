{
  description = "Zig-Zoom";
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
              glfw
              glew
              zsh
            ];

            shellHook = ''
              export EGL_PLATFORM=wayland
              export GLFW_USE_WAYLAND=1
              export LD_LIBRARY_PATH="${glew}/lib"

              if [ -z "$IN_ZSH" ]; then
                export IN_ZSH=1
                exec zsh
              fi
            '';
          };
      }
    );
}
