(inputs.omnibus.load {
  src = ./shellsProfiles;
  inputs = {
    inherit cell inputs;
  };
})
