{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs nickel terraform-providers;
  terraform-providers-bin = terraform-providers.legacyPackages.providers;

  providers = p: {
    inherit (p) null;
    inherit
      (terraform-providers-bin.hashicorp)
      # nomad
      
      # aws
      
      # template
      
      ;
    # inherit (terraform-providers-bin.dmacvicar) libvirt;
    # inherit (terraform-providers-bin.cloudflare) cloudflare;
  };
  github-users = p: {
    inherit (p) null external;
    inherit
      (terraform-providers-bin.integrations)
      github
      ;
  };
in {
  packages = [
    nickel.packages.default
    nickel.packages.lsp-nls
  ];
  commands = [
    {
      package = cell.lib.mkTfCommand "hello-tf" providers;
      help = "null: Terraform with tf-nickel";
    }
    {
      package = cell.lib.mkTfCommand "github-users" github-users;
      help = "github-users: Terraform with tf-nickel";
    }
  ];
}
