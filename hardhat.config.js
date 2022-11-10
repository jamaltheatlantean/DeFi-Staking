require("@nomiclabs/hardhat-waffle")
require("hardhat-deploy")

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require('@nomiclabs/hardhat-waffle');
module.exports = {
  solidity: "0.8.13",
  namedAccounts: {
    deployer: {
      default: 0, // ethers built in accounts at index 0
    },
  },
};
