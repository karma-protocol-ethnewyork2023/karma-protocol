require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  networks: {
    hardhat: {
    },
    goerli: {
      url: "https://goerli.infura.io/v3/5c92864a308b45b6a8c3559b63cb5b38",
      accounts: [
        "9b7aa31fbbf25350d4bcd9c61ce56a9bfed0690ad98e7ac9dd21386937303e3e"
      ]
    },
    mumbai: {
      url: "https://polygon-mumbai.infura.io/v3/5c92864a308b45b6a8c3559b63cb5b38",
      accounts: [
        "9b7aa31fbbf25350d4bcd9c61ce56a9bfed0690ad98e7ac9dd21386937303e3e"
      ]
    }
  },
  etherscan: {
    apiKey: "N2E97JHH5HPFAWYN9TBNK3J5FIVGUFDTA4",
  },
};
