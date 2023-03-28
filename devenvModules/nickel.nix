{
  pkgs,
  self,
  ...
}: {
  packages = [
    self.packages.${pkgs.system}.nickel
    self.packages.${pkgs.system}.lsp-nls
  ];
}
