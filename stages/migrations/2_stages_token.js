var Migrations = artifacts.require("./StagesToken.sol");

module.exports = function(deployer) {
    deployer.deploy(Migrations,"StagesToken", "ST", 18, 5000000);
};

