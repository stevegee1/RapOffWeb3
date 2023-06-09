// //require("@nomicfoundation/hardhat-toolbox");
 //require("@nomicfoundation/hardhat-verify");
// //import type { HardhatUserConfig } from "hardhat/types";

// /** @type import('hardhat/config').HardhatUserConfig */
// module.exports = {
//   solidity: "0.8.9",
//   networks: {
//     mantle_testnet: {
//       url: "https://rpc.testnet.mantle.xyz/",
//       chainId: 5001,
//       accounts: [
//         "0x5e2f1327a7bd0e106c9bb265dbe362aef5144f1e5525deb07f729deae7e63b1d",
//       ],
//     },
//   },
  

//   etherscan: {
//     apiKey: {
//       "mantle-testnet": "f44d30c7-8787-4b3b-a138-7a1d7178eef9",
//     },
//     customChains: [
//       {
//         mantle_testnet: {
//           chainId: 5001,
//           urls: {
//             apiURL: "https://explorer.testnet.mantle.xyz/api",
//             browserURL: "https://explorer.testnet.mantle.xyz",
//           },
//         },
//       },
//     ],
//   },
// };
require("@nomicfoundation/hardhat-toolbox");
//import type { HardhatUserConfig } from "hardhat/types";

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  networks: {
    mantle_testnet: {
      url: "https://rpc.testnet.mantle.xyz/",
      chainId: 5001,
      accounts: [
        "0x5e2f1327a7bd0e106c9bb265dbe362aef5144f1e5525deb07f729deae7e63b1d",
      ],
    },
  },

  etherscan: {
    apiKey: {
      mantle_testnet: "f44d30c7-8787-4b3b-a138-7a1d7178eef9",
    },
    customChains: [
      {
        mantle_testnet: {
          chainId: 5001,
          urls: {
            apiURL: "https://explorer.testnet.mantle.xyz/api",
            browserURL: "https://explorer.testnet.mantle.xyz",
          },
        },
      },
    ],
  },
};