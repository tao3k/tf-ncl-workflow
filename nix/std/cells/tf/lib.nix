{inputs, cell}:
let
  inherit (inputs) tf-ncl nickel;
  l = inputs.nixpkgs.lib // builtins;
  writeShellApplication = inputs.omnibus.ops.writeShellApplication {
    inherit (inputs) nixpkgs;
  };
in
{
  mkTfCommand =
    name: nixpkgs: tfPlugins: git:
    let
      terraform-with-plugins = nixpkgs.terraform.withPlugins (
        p: nixpkgs.lib.attrValues (tfPlugins p)
      );
      ncl-schema = initSchemaGenerator nixpkgs tfPlugins;
      initSchemaGenerator =
        nixpkgs: providerFn:
        let
          generateJsonSchema' =
            nixpkgs.callPackage
              (import (tf-ncl + /nix/terraform_schema.nix) (
                providerFn nixpkgs.terraform-providers.actualProviders
              ))
              {inherit (tf-ncl.packages.${nixpkgs.system}) schema-merge;};
        in
        nixpkgs.callPackage (tf-ncl + /nix/nickel_schema.nix) {
          jsonSchema = generateJsonSchema';
          inherit (tf-ncl.packages.${nixpkgs.system}) tf-ncl;
        };
    in
    writeShellApplication {
      inherit name;
      runtimeEnv = {
        TF_IN_AUTOMATION = 1;
        TF_PLUGIN_CACHE_DIR = "$PRJ_CACHE_HOME/tf-plugin-cache";
      };
      runtimeInputs = with inputs.nixpkgs; [
        nickel.packages.default
        terraform-with-plugins
        terraform-backend-git
      ];
      text = ''
        set -e

        if [[ ! -d "$PRJ_DATA_DIR"/tf-ncl/${name} ]]; then
           mkdir -p "$PRJ_DATA_DIR"/tf-ncl/${name}
           mkdir -p "$PRJ_CACHE_HOME"/tf-plugin-cache
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

        ${if git != {} then
          ''
            ENTRY_DIR="$(dirname "$ENTRY")"

            terraform-backend-git git \
               --dir "$PRJ_DATA_DIR"/tf-ncl/${name} \
               --repository ${git.repo} \
               --ref ${git.ref} \
               --state "''${ENTRY_DIR}/state.json" \
               terraform "$@"
          ''
        else
          ''
            terraform -chdir="$PRJ_DATA_DIR"/tf-ncl/${name} "$@"
          ''}
      '';
    };
}
