require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks:{
    sepolia:{
      chainId: 11155111,
      url:process.env.ALCHEMY_KEY,
      accounts:[`0x${process.env.PRIVATE_KEY}`],
    },
  },
  paths :{
    artifacts : "../artifacts",
  },
};
