{
  pkgs,
  inputs,
  ...
}: let
  inherit (inputs.std-ext.${pkgs.system}.common.lib) __inputs__;
in {
  packages = [
    __inputs__.nickel.packages.nickel
  ];
}
