{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs nickel topiary terraform-providers;
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
  packages = [
    nickel.packages.default
    nickel.packages.lsp-nls
    topiary.packages.default
  ];
  commands = [
    {
      package = cell.lib.mkTfCommand "template" providers;
      help = "Terraform with plugins";
    }
  ];
}
