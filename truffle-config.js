// A file that configures the Truffle framework for deploying smart contracts
const HDWalletProvider = require("@truffle/hdwallet-provider"); // A library that allows to sign transactions from a mnemonic phrase
const fs = require("fs"); // A library that allows to read and write files

// Load the mnemonic phrase from a file named .secret
const mnemonic = fs.readFileSync(".secret").toString().trim();

// Define the networks to deploy the contracts
module.exports = {
  networks: {
    // The development network using Ganache
    development: {
      host: "127.0.0.1", // The local host address
      port: 7545, // The port used by Ganache
      network_id: "*", // Match any network id
    },
    // The Rinkeby testnet network using Infura
    rinkeby: {
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          `https://mainnet.infura.io/v3/d2fa1a45d1f04ad9a0fbf0d425a39059`
        ), // The provider that connects to Infura with the mnemonic phrase
      network_id: 4, // The id of the Rinkeby network
      gas: 5500000, // The gas limit for the transactions
      confirmations: 2, // The number of confirmations to wait between deployments
      timeoutBlocks: 200, // The number of blocks before a deployment times out
      skipDryRun: true, // Skip dry run before migrations
    },
  },

  // Configure how to compile the contracts
  compilers: {
    solc: {
      version: "0.8.0", // The version of Solidity to use
      settings: {
        optimizer: {
          enabled: true, // Enable the optimizer for better performance
          runs: 200, // Set the number of optimization runs
        },
        evmVersion: "byzantium", // Set the EVM version to use
      },
    },
  },
};
