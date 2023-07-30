{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs tf-ncl terraform-providers;
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
in {
  commands = [
    {
      package = cell.lib.mkTfCommand "template" providers;
      help = "Terraform with plugins";
    }
  ];
}
