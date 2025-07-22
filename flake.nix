{
  description = "Nix (rofi) custom hyprland keybind previewer";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {nixpkgs, ...}: rec {
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    packages.x86_64-linux.default = import ./src/binds.nix {inherit pkgs;};
  };
}
