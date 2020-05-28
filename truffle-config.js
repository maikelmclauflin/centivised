const path = require("path");
const HDWalletProvider = require("@truffle/hdwallet-provider");
const mnemonic = process.env.MNEMONIC
const infura_apikey = process.env.INFURA_APIKEY

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  package_name: "warrantee",
  version: "0.0.1",
  description: "Create bonds and provide enough incentive for someone to keep autostaking them on your behalf",
  dependencies: {
    "@openzeppelin/contracts": "^3.0.1",
    "solidity-linked-list": "^3.0.0"
  },
  contracts_build_directory: path.join(__dirname, "client/src/contracts"),
  networks: {
    develop: {
      port: 8545,
      network_id: "*",
      host: "127.0.0.1",
      blockTime: 1,
      gas: 6721975,
      websockets: true
    },
    test: {
      port: 8545,
      network_id: "*",
      host: "127.0.0.1",
      blockTime: 1,
      gas: 6721975,
      websockets: true
    },
    ropsten: {
      provider: () => new HDWalletProvider(mnemonic, 'https://ropsten.infura.io/v3/' + infura_apikey),
      network_id: 3
    }
  },
  mocha: {
    useColors: true
  },
  compilers: {
    solc: {
      parser: "solcjs",
      version: "0.6.2",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
    }
  }
};
