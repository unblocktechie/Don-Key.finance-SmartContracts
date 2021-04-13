// migrations/2_deploy.js
// SPDX-License-Identifier: MIT
const bdollar = artifacts.require("BdollarInterface");
module.exports = function(deployer) {
  deployer.deploy(bdollar);
};