{ inputs, cell }:
let
  inherit (inputs.std) lib;
  inherit (inputs) std;
  l = inputs.nixpkgs.lib // builtins;
in
{
  # Tool Homepage: https://numtide.github.io/devshell/
  default = lib.dev.mkShell {
    imports = [ cell.shellsProfiles.default ];
    nixago = [
      (inputs.std-ext.presets.nixago.treefmt
        inputs.std-ext.presets.configs.treefmt.topiary
      )
    ];
  };
}
