{
  inputs,
  cell,
}: let
  inherit (inputs.std-ext.writers.lib) writeShellApplication;
  inherit (inputs) tf-ncl nickel nixpkgs;
  l = inputs.nixpkgs.lib // builtins;
in {
  mkTfCommand = name: tfPlugins: let
    terraform-with-plugins =
      nixpkgs.terraform.withPlugins
      (p: nixpkgs.lib.attrValues (tfPlugins p));

    ncl-schema = tf-ncl.generateSchema tfPlugins;
  in
    writeShellApplication {
      inherit name;
      runtimeInputs = with inputs.nixpkgs; [
        nickel.packages.default
        terraform-with-plugins
      ];
      text = ''
        set -e
        if [[ ! -d "$PRJ_DATA_DIR"/tf-ncl/${name} ]]; then
           mkdir -p "$PRJ_DATA_DIR"/tf-ncl/${name}
        fi

        if [[ "$#" -le 1 ]]; then
          echo "terraform <ncl-file> ..."
          exit 1
        fi
        ENTRY="''${1}"
        shift
        ln -snfT ${ncl-schema} "$PRJ_DATA_DIR"/tf-ncl/${name}/schema.ncl
        nickel export > "$PRJ_DATA_DIR"/tf-ncl/${name}/main.tf.json <<EOF
          (import "''${ENTRY}").renderable_config
        EOF
        terraform -chdir="$PRJ_DATA_DIR"/tf-ncl/${name} "$@"
      '';
    };
}
