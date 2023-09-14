{ inputs, cell }:
let
  terraEval = import (inputs.terranix + /core/default.nix);
  pkgs = inputs.nixpkgs;
in
{
  mkTerra =
    config:
    (terraEval {
      inherit pkgs; # only effectively required for `pkgs.lib`
      terranix_config = {
        imports = [ config ];
      };
      strip_nulls = true;
    }).config;
}
