{
  inputs,
  cell,
}: let
  inherit (inputs.std) lib;
  inherit (inputs) std;
  l = inputs.nixpkgs.lib // builtins;
in {
  # Tool Homepage: https://numtide.github.io/devshell/
  default = lib.dev.mkShell {
    imports = [
      cell.shellsProfiles.default
    ];
    nixago = [
      (inputs.std-ext.preset.nixago.treefmt
        inputs.std-ext.preset.configs.treefmt.topiary)
    ];
  };
}
