{inputs, cell}:
let
  inherit (nixpkgs) terraform-providers;
  nixpkgs =
    (import inputs.nixpkgs.path {
      config = {
        allowUnfree = true;
        allowUnfreePredicate =
          pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) ["terraform"];
      };
      system = inputs.nixpkgs.system;
      overlays = [inputs.terraform-providers.overlay];
    });

  providers = p: {
    inherit (p) null;
    inherit (terraform-providers.hashicorp)
    # inherit (terraform-providers-bin.dmacvicar) libvirt;
    # inherit (terraform-providers-bin.cloudflare) cloudflare;
  };

  github-users = p: {
    inherit (p) null external;
    inherit (terraform-providers) github;
  };
in
{
  packages = [nixpkgs.terraform];
  commands = [
    {
      package = cell.lib.mkTfCommand "hello-tf-git" nixpkgs providers {
        repo = "git@github.com:GTrunSec/tf-ncl-workflow.git";
        ref = "deploy";
      };
      help = "null: terraform-backend-git with tf-nickel";
    }
    {
      package = cell.lib.mkTfCommand "hello-tf" nixpkgs providers {};
      help = "null: terraform with tf-nickel";
    }
    {
      package = cell.lib.mkTfCommand "github-users" nixpkgs github-users {};
      help = "github-users: terraform with tf-nickel";
    }
  ];
}
