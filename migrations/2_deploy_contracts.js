var compiledRegistrationAuthority = artifacts.require("RegistrationAuthority")

module.exports = function(deployer) {
  deployer.deploy(compiledRegistrationAuthority);
};

