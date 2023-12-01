(inputs.omnibus.load {
  src = ./devshellProfiles;
  inputs = {
    inherit cell inputs;
  };
})
