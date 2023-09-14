{
  description = "std && flake-parts && devenv template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };
  inputs = {
    std.follows = "std-ext/std";
    std-ext.url = "github:gtrunsec/std-ext";
    std-ext.inputs.nixpkgs.follows = "nixpkgs";
    flops.follows = "std-ext/flops";
  };

  inputs = {
    tf-ncl.url = "github:tweag/tf-ncl";
    tf-ncl.inputs.nixpkgs.follows = "nixpkgs";
    tf-ncl.inputs.topiary.follows = "";
    nickel.follows = "tf-ncl/nickel";

    terranix.url = "github:terranix/terranix";
    terranix.inputs.nixpkgs.follows = "nixpkgs";
    terranix.inputs.terranix-examples.follows = "";

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
      __inputs__ =
        removeAttrs (inputs.std-ext.inputs.flops.inputs.call-flake ./nix/lock).inputs
          [ "nixpkgs" ];
    in
    flake-parts.lib.mkFlake { inputs = inputs // __inputs__; } {
      inherit systems;
      # Raw flake outputs (generally not system-dependent)
      flake = {
        devShells = inputs.std.harvest inputs.self [ [
          "repo"
          "shells"
        ] ];
      };
      std.grow.cellsFrom = ./nix/cells;
      std.grow.cellBlocks = with inputs.std.blockTypes; [
        #: lib
        (functions "lib")
        (functions "configs")
        (nixago "nixago")
        (installables "packages")

        #: presets
        (nixago "nixago")

        (devshells "shells")
        (data "shellsProfiles")
      ];
      imports = [ inputs.std.flakeModule ];
      # Flake outputs that will be split by system
      perSystem =
        {
          config,
          pkgs,
          inputs',
          self',
          ...
        }:
        { };
    };
}
