require('babel-register');
require('babel-polyfill');
require('dotenv').config();
const HDWalletProvider = require("truffle-hdwallet-provider");

let ver;
if (process.env.POLYMATH_NATIVE_SOLC) {
  ver = "native";
} else {
  ver = "0.7.6";
}

module.exports = {
  networks: {
    development: {
      host: 'localhost',
      port: 9000,
      network_id: '*', // Match any network id
    },
    mainnet: {
      provider: () => {
        return new HDWalletProvider(process.env.PRIVATE_KEY, process.env.MAINNET_ENDPOINT)
      },
      network_id: '1', // Match any network id
      gasPrice: 10000000000 // 10 gwei
    },
    ropsten: {
      provider: () => {
        return new HDWalletProvider(process.env.PRIVATE_KEY, process.env.ROPSTEN_ENDPOINT)
      },
      network_id: '3', // Match any network id
      gas: 4500000,
      gasPrice: 150000000000
    },
    rinkeby: {
      provider: () => {
        return new HDWalletProvider(process.env.PRIVATE_KEY, process.env.RINKEBY_ENDPOINT)
      },
      network_id: '4', // Match any network id
      gas: 7500000,
      gasPrice: 10000000000
    },
    kovan: {
      provider: () => {
        return new HDWalletProvider(process.env.PRIVATE_KEY, process.env.KOVAN_ENDPOINT)
      },
      network_id: '42', // Match any network id
      gasPrice: 5000000000, // 5 gwei
      skipDryRun: true
    },
    goerli: {
      provider: () => {
        return new HDWalletProvider(process.env.PRIVATE_KEY, process.env.GOERLI_ENDPOINT)
      },
      network_id: '5', // Match any network id
      gas: 7900000,
      gasPrice: 21000000000
    },
    coverage: {
      host: "localhost",
      network_id: "*",
      port: 8545,         // <-- If you change this, also set the port option in .solcover.js.
      gas: 0xfffffffff  , // <-- Use this high gas value
      gasPrice: 0x01      // <-- Use this low gas price
    }
  },
  compilers: {
    solc: {
      version: ver,
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
    }
  },
  mocha: {
    enableTimeouts: false,
    reporter: 'eth-gas-reporter',
  },
  plugins: [
    'truffle-plugin-verify', 'solidity-coverage'
  ],
  api_keys: {
    etherscan: process.env.ETHERSCAN_API_KEY
  }
};
