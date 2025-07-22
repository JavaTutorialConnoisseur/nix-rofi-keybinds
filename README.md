# Nix Rofi Keybinds

... for Hyprland. But having that long of a title is gauche.

A teeny project to get keybinds from hyprland with `hyprctl` and
list the ones with descriptions using rofi.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Examples](#examples)
- [Credits](#credits)

## Installation

### Nix

Just `nix run github:JavaTutorialConnoisseur/nix-rofi-keybinds`, or
incorporate it into your config's flake with:

```nix
...
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    binds = {
      url = "github:JavaTutorialConnoisseur/nix-rofi-keybinds";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
...
```

... Or use any other nix way to get a flake running.

I'm too lazy to make theme getting dynamic, just move the one in src/themes to
`~/.config/rofi/themes/custom-binds.rasi` or write your own theme and symlink / set it.

I have it as `home.file.".config/rofi/themes/custom-binds.rasi" = ...`.

### Not Nix

Idk man figure it out yourself.

## Credits

The `rofi-json.sh` is basically just: `https://github.com/luiscrjunior/rofi-json/blob/master/rofi-json.sh` but worse.
