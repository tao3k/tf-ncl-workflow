{
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/d2b52322f35597c62abf56de91b0236746b2a03d";

    terranix-module-github.url = "github:terranix/terranix-module-github";
    terranix-module-github.flake = false;

    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {...}: {};
}
