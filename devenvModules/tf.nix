{
  pkgs,
  self,
  ...
}: {
  packages = with pkgs; [
    self.packages.${pkgs.system}.terraform-with-plugins
    terragrunt
  ];
  env = {
    AWS_PROFILE = "tf-ncl";
    AWS_DEFAULT_REGION = "us-east-1";
  };
}
