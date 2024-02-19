require("@nomicfoundation/hardhat-toolbox");
require('hardhat-tracer');
require('hardhat-storage-layout');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  networks: {
    hardhat: {
      chainId: Number(process.env.HARDHAT_CHAIN_ID ?? 31337)
    },
    mainnet: {
      url: 'https://ethereum.llamarpc.com',
      chainId: 1,
    }
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: process.env.ETHERSCAN
  },
  solidity: {
    compilers: [
      {
        version: '0.8.24',
        settings: {
          evmVersion: 'paris',
          optimizer: {
            enabled: true,
            runs: 200,
          }
        }
      }
    ]
  },
};
