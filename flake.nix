{
  description = "std && flake-parts && devenv template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };
  inputs = {
    std.follows = "std-ext/std";
    std.inputs.paisano-mdbook-preprocessor.follows = "std/blank";
    std-ext.url = "github:gtrunsec/std-ext";
    std-ext.inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs = {
    tf-ncl.url = "github:tweag/tf-ncl";
    tf-ncl.inputs.nixpkgs.follows = "nixpkgs";
    nickel.follows = "tf-ncl/nickel";
    topiary.url = "github:tweag/topiary";
  };
  outputs = inputs @ {
    self,
    flake-parts,
    nixpkgs,
    ...
  }: let
    systems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    __inputs__ = inputs.std-ext.inputs.flops.inputs.call-flake ./lock;
  in
    flake-parts.lib.mkFlake {
      inputs = inputs // __inputs__;
    } {
      inherit systems;
      # Raw flake outputs (generally not system-dependent)
      flake = {};
      std.grow.cellsFrom = ./cells;
      std.grow.cellBlocks = with inputs.std.blockTypes; [
        #: lib
        (functions "lib")
        (functions "configs")
        (nixago "nixago")
        (installables "packages")

        #: presets
        (nixago "nixago")

        (devshells "devshells")
        (data "devshellsProfiles")
      ];
      imports = [
        inputs.std.flakeModule
      ];
      # Flake outputs that will be split by system
      perSystem = {
        config,
        pkgs,
        inputs',
        self',
        ...
      }: {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            inputs.topiary.packages.${pkgs.system}.default
            inputs.nickel.packages.${pkgs.system}.default
            inputs.nickel.packages.${pkgs.system}.lsp-nls
          ];
        };
      };
    };
}
