import { HardhatUserConfig } from "hardhat/config"
import "@nomicfoundation/hardhat-toolbox"
import "@typechain/hardhat" // generate typings for compiled contracts
import "dotenv/config"
import "hardhat-gas-reporter"
import "solidity-coverage"
import "hardhat-deploy"

const GOERLI_PRIVATE_KEY = process.env.GOERLI_PRIVATE_KEY || ""
const GOERLI_RPC_URL = process.env.GOERLI_RPC_URL || ""
const ETHERSCAN_API_KET = process.env.ETHERSCAN_API_KEY || ""
const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY || ""

const config: HardhatUserConfig = {
    defaultNetwork: "hardhat",
    networks: {
        goerli: {
            chainId: 5,
            url: GOERLI_RPC_URL,
            accounts: [`0x${GOERLI_PRIVATE_KEY}`],
            blockConfirmations: 1,
        },
        localhost: {
            chainId: 31337,
            url: "http://127.0.0.1:8545/",
        },
    },
    etherscan: {
        // Your API key for Etherscan
        // Obtain one at https://etherscan.io/
        apiKey: ETHERSCAN_API_KET,
    },
    gasReporter: {
        enabled: true,
        outputFile: "gas-report.txt",
        noColors: true,
        currency: "AUD",
        coinmarketcap: COINMARKETCAP_API_KEY,
        token: "ETH",
    },
    solidity: "0.8.17",
    namedAccounts: {
        deployer: {
            default: 0,
        },
        player: {
            default: 1,
        },
    },
    mocha: {
        timeout: 200000, //200 sec max
    },
}

export default config
