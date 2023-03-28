{
  description = "std && flake-parts && devenv template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
    mission-control.url = "github:Platonic-Systems/mission-control";
    flake-root.url = "github:srid/flake-root";
  };
  inputs = {
    std.url = "github:divnix/std";
    std.inputs.nixpkgs.follows = "nixpkgs";
    std-ext.url = "github:gtrunsec/std-ext";
    std-ext.inputs.std.follows = "std";
    std-ext.inputs.nixpkgs.follows = "nixpkgs";
    std-ext.inputs.org-roam-book-template.follows = "std/blank";
  };

  inputs = {
    tf-ncl.url = "github:tweag/tf-ncl";
    tf-ncl.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs @ {
    self,
    flake-parts,
    devenv,
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
        inputs.devenv.flakeModule
        inputs.mission-control.flakeModule
        inputs.flake-root.flakeModule
      ];
      # Flake outputs that will be split by system
      perSystem = {
        config,
        pkgs,
        inputs',
        self',
        ...
      }: {
        mission-control.scripts = {
          hello = {
            description = "Say Hello";
            exec = "echo Hello";
          };
          cliche = {
            description = "Run cliche example";
            exec = inputs.std-ext.${pkgs.system}.cliche.entrypoints.example;
          };
          ponysay = {
            exec = pkgs.ponysay;
          };
          run-terraform = {
            exec = ''
              set -e
              if [[ "$#" -le 1 ]]; then
                echo "terraform <ncl-file> ..."
                exit 1
              fi
              ENTRY="''${1}"
              shift
              ln -sfT ${self'.packages.ncl-schema} schema.ncl
              ${self'.packages.nickel}/bin/nickel export > main.tf.json <<EOF
                (import "''${ENTRY}").renderable_config
              EOF
              ${self'.packages.terraform-with-plugins}/bin/terraform "$@"
            '';
            description = "Run terraform with the NCL schema";
          };
        };
        packages = let
          inherit (inputs.std-ext.${pkgs.system}.common.lib) __inputs__;
          inherit (__inputs__.nickel.packages) nickel lsp-nls;

          ncl-schema = inputs.tf-ncl.generateSchema.${pkgs.system} providers;

          terraform-providers-bin = __inputs__.terraform-providers.legacyPackages.providers;

          terraform-with-plugins =
            pkgs.terraform.withPlugins
            (p: pkgs.lib.attrValues (providers p));

          providers = p: {
            inherit (p) null;
            inherit (terraform-providers-bin.hashicorp) nomad;
            inherit (terraform-providers-bin.dmacvicar) libvirt;
            inherit (terraform-providers-bin.hashicorp) aws;
            inherit (terraform-providers-bin.hashicorp) template;
            inherit (terraform-providers-bin.cloudflare) cloudflare;
          };
        in
          (import ./packages {inherit pkgs inputs';})
          // {
            inherit
              terraform-with-plugins
              nickel
              lsp-nls
              ncl-schema
              ;
          };
        devenv.shells = {
          default = {
            name = "default";
            enterShell = config.mission-control.banner;
            packages = [
              config.mission-control.wrapper
            ];
            imports = [
              self.devenvModules.default
              self.devenvModules.lint
              self.devenvModules.rust
              self.devenvModules.tf
              self.devenvModules.nickel
            ];
          };
        };
      };
    };
}
