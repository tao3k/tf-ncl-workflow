{inputs, cell}:
let
  l = nixpkgs.lib // builtins;
  inherit (inputs) nixpkgs std;
in
l.mapAttrs (_: std.lib.dev.mkShell) {
  default =
    {...}:
    {
      name = "tf-nickel DevShell";
      imports = [
        cell.pops.devshellProfiles.exports.default.nickel
        inputs.cells.tf.shellsProfiles.default
      ];

      nixago = [
        cell.nixago.treefmt.default
        cell.nixago.lefthook.default
        cell.nixago.conform.default
      ];
    };
}
