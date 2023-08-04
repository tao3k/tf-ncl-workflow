(inputs.flops.lib.configs.haumea.setInit {
  src = ./shellsProfiles;
  inputs = {
    inherit cell;
    inputs = removeAttrs inputs [ "self" ];
  };
}).outputsForTarget
  "default"
