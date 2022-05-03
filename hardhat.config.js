require('hardhat-deploy')
const {ethers} = require('@nomiclabs/hardhat-ethers')

// Fill these in for testing
private_key = ''
rpcURL = ''

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.7",
  networks: {
    hardhat: {
      chainId: 31337,
    },
    rinkeby: {
      chainId: 4,
      url: rpcURL,
      accounts: [private_key]
    }
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  }
};
