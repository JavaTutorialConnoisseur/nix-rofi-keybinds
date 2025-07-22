{pkgs, ...}: let
  keys = [
    ["LMB" 272]
    ["RMB" 273]
    ["volOff" 121]
    ["volDown" 122]
    ["volUp" 123]
    ["brightDown" 232]
    ["brightUp" 233]
    ["prtScrn" 107]
    ["=" 21]
    ["/" 61]
    ["`" 49]
    ["-" 20]
    ["play1" 172]
    ["play2" 208]
    ["play3" 209]
  ];

  startKeyCode = with builtins;
    (it: let
      key = toString (elemAt it 1);
      keyName = elemAt it 0;
    in "(\nif (.keycode == ${key}) then\n\"${keyName}\"\n")
    (elemAt keys 0);

  mapKeyCode = with builtins;
    (foldl'
      (acc: it: let
        key = toString (elemAt it 1);
        keyName = elemAt it 0;
      in
        acc + "elif (.keycode == ${key}) then\n\"${keyName}\"\n")
      startKeyCode
      (tail keys))
    + "else \"INVALID\" end\n)";

  maskCharMap = {
    "2" = "CAPS+";
    "4" = "CTRL+";
    "8" = "ALT+";
    "16" = "M2+";
    "32" = "M3+";
    "64" = " ";
    "128" = "M5+";
  };

  maskUnwrap =
    map
    (x:
      "(if ((.modmask / ${builtins.toString x} | floor) % 2 == 1) "
      + "then \"${maskCharMap.${builtins.toString x}}\" else \"\" end) +")
    [128 64 32 16 8 4 2];

  mapShift =
    "(if ((.key | test(\"[a-zA-Z]\")) and (.modmask % 2 == 1)) "
    + "then (.key | ascii_upcase) "
    + "elif ((.key | test(\"[a-zA-Z]\")) and (.modmask % 2 == 0)) "
    + "then (.key | ascii_downcase) "
    + "elif (.modmask % 2 == 1) "
    + "then (\"SHIFT+\" + .key) "
    + "else .key end)";

  rofi-json =
    pkgs.writeShellScriptBin
    "rofi-json.sh"
    (builtins.readFile ./rofi-json.sh);
in
  pkgs.writeShellApplication
  {
    name = "binds";
    runtimeInputs = [pkgs.jq pkgs.rofi];

    # this is so goddamn cursed
    text = ''
      tmp_file=$(mktemp /tmp/tempfile.XXXXXX.json)
      hyprctl -j binds \
        | jq '[.[] | select(.has_description == true) |
            {
              arg: .arg,
              dispatcher: .dispatcher,
              submap: .submap,
              description: .description,
              modmask: .modmask,
              key: (if (.key != "") then .key else ${mapKeyCode} end),
            }
          ] | sort_by(.description)' | jq '
      def center(text; total_length):
        (" " * (((total_length - (text | length)) / 2) | floor)) + text + (" " * (((total_length - (text | length)) / 2) | ceil)); [.[] |
            {
              command: ("hyprctl dispatch " + .dispatcher + " " + .arg),
              name: (
                center((${builtins.concatStringsSep "\n" maskUnwrap} ${mapShift}); 45) + " <> " + center(.description; 43)
              ),
              description: .description,
            }
          ]
        ' > "$tmp_file"

      rofi -modi "Keybinds":"${rofi-json}/bin/rofi-json.sh $tmp_file" \
           -theme "$HOME/.config/rofi/themes/custom-binds.rasi" \
           -show "Keybinds"
    '';
  }
