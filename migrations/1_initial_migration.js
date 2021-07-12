const Migrations = artifacts.require("PermissionControl");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
