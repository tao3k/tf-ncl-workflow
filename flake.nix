{
  description = "std && flake-parts && devenv template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };
  inputs = {
    std.url = "github:divnix/std";
    std.inputs.nixpkgs.follows = "nixpkgs";
    std.inputs.paisano-mdbook-preprocessor.follows = "std/blank";
    std-ext.url = "github:gtrunsec/std-ext";
    std-ext.inputs.std.follows = "std";
    std-ext.inputs.nixpkgs.follows = "nixpkgs";
    std-ext.inputs.org-roam-book-template.follows = "std/blank";
  };

  inputs = {
    tf-ncl.url = "github:tweag/tf-ncl";
    tf-ncl.inputs.nixpkgs.follows = "nixpkgs";
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
    __inputs__ = inputs.std-ext.x86_64-linux.common.lib.callFlake ./lock {};
  in
    flake-parts.lib.mkFlake {
      inputs = inputs // __inputs__;
    } {
      inherit systems;
      # Raw flake outputs (generally not system-dependent)
      flake = {
        devenvModules = inputs.std-ext.lib.digga.rakeLeaves ./devenvModules;
      };
      std.grow.cellsFrom = ./cells;
      std.grow.cellBlocks = with inputs.std.blockTypes; [
        #: lib
        (functions "lib")
        (nixago "nixago")
        (installables "packages")

        #: presets
        (nixago "nixago")

        (devshells "devshells")
        (data "devshellsProfiles")
        (nixago "nixago")
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
          ];
        };
      };
    };
}
