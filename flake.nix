{
  description = "tf-ncl with std&flak-parts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  inputs = {
    tf-ncl.url = "github:gtrunsec/tf-ncl/dev";
    tf-ncl.inputs.topiary.follows = "";
    nickel.follows = "tf-ncl/nickel";

    terraform-providers.url = "github:numtide/nixpkgs-terraform-providers-bin";
    terraform-providers.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    inputs@{
      self,
      flake-parts,
      nixpkgs,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
    flake-parts.lib.mkFlake {inherit inputs;} {
      inherit systems;
      # Raw flake outputs (generally not system-dependent)
      flake = {};
      imports = [];
      # Flake outputs that will be split by system
      perSystem =
        {
          config,
          pkgs,
          inputs',
          self',
          ...
        }:
        {};
    };
  nixConfig = {
    extra-substituters = ["https://tweag-nickel.cachix.org"];
    extra-trusted-public-keys = [
      "tweag-nickel.cachix.org-1:GIthuiK4LRgnW64ALYEoioVUQBWs0jexyoYVeLDBwRA="
    ];
  };
}
