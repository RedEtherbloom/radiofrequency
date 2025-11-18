{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
    inherit (pkgs) lib;
    # TODO: Generalize with flake-parts
  in {
    devShells."${system}".default = let
      # Source: https://github.com/NixOS/nixpkgs/blob/89c2b2330e733d6cdb5eae7b899326930c2c0648/pkgs/by-name/pr/prismlauncher/package.nix#L79
      # Mitigates issues with unresolved opengl contexts
      runtimeLibs = with pkgs; [
        (lib.getLib stdenv.cc.cc)
        ## native versions
        glfw3-minecraft
        openal

        ## openal
        alsa-lib
        libjack2
        libpulseaudio
        pipewire

        ## glfw
        libGL
        libx11
        libxcursor
        libxext
        libxrandr
        libxxf86vm

        udev # oshi

        vulkan-loader # VulkanMod's lwjgl
      ];

      runtimePrograms = with pkgs; [
        mesa-demos
        pciutils # need lspci
        xrandr # needed for LWJGL [2.9.2, 3) https://github.com/LWJGL/lwjgl/issues/128
      ];
    in
      pkgs.mkShell {
        packages = runtimeLibs ++ runtimePrograms;
        LD_LIBRARY_PATH = "${pkgs.addDriverRunpath.driverLink}/lib:${lib.makeLibraryPath runtimeLibs}";
        PATH = "${lib.makeBinPath runtimePrograms}:$PATH";
      };
  };
}
