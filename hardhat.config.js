require("@nomicfoundation/hardhat-toolbox");
require('hardhat-tracer');
require('hardhat-storage-layout');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  networks: {
    hardhat: {
      chainId: Number(process.env.HARDHAT_CHAIN_ID ?? 31337)
    },
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
