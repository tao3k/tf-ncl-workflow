{
  pkgs,
  inputs,
  ...
}: let
  inherit (inputs.std-ext.${pkgs.system}.common.lib) __inputs__;
  terraform-providers-bin = __inputs__.terraform-providers.legacyPackages.providers;

  terraform = pkgs.terraform.withPlugins (p: [
    terraform-providers-bin.hashicorp.nomad
    terraform-providers-bin.dmacvicar.libvirt
    terraform-providers-bin.hashicorp.aws
    terraform-providers-bin.hashicorp.template
    terraform-providers-bin.cloudflare.cloudflare
  ]);
in {
  packages = with pkgs; [
    terraform
    terragrunt
  ];
  env = {
    AWS_PROFILE = "tf-ncl";
    AWS_DEFAULT_REGION = "us-east-1";
  };
}
