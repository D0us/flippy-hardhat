import { assert, expect } from "chai"
import { deployments, ethers, getNamedAccounts, network } from "hardhat"
import { BigNumber } from "ethers"
import { developmentChains, networkConfig } from "../../helper-hardhat-config"
import { Flippy } from "../../typechain-types"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"

if (developmentChains.includes(network.name)) {
    describe("Flippy Unit Tests", () => {
        const chainId = network.config.chainId ? network.config.chainId : 31337
        let flippy: Flippy
        let player: string
        let deployer: string
        let minimumWager: BigNumber = networkConfig[chainId]["minimumWager"]

        beforeEach(async () => {
            await deployments.fixture(["all"])
            const accounts = await getNamedAccounts()
            deployer = accounts.deployer
            player = accounts[1]
            flippy = await ethers.getContract("Flippy", deployer)
        })

        describe("constructor", () => {
            it("Initalises the flippy contract correctly", async () => {
                const minWager = await flippy.getMinimumWager()
                assert.equal(minWager.toString(), minimumWager.toString())
            })
        })

        describe("Flip a coin", () => {
            let accounts: SignerWithAddress[]
            beforeEach(async () => {
                await flippy.fund({ value: ethers.utils.parseEther("10") })
                accounts = await ethers.getSigners()
            })

            it("Rejects a wager that is lower than the minimum", async () => {
                const playerConnectedFlippy = flippy.connect(accounts[1])
                const coinFaceSelection = 0 //heads
                const wager = minimumWager.sub(1)
                await expect(playerConnectedFlippy.flipCoin(coinFaceSelection, { value: wager })).to.be.revertedWithCustomError(
                    flippy,
                    "Flippy__InsufficientWager"
                )
            })

            it("Emits the CoinFlipped event on flip", async () => {
                const playerConnectedFlippy = flippy.connect(accounts[1])
                const coinFaceSelection = 0 //heads
                const wager = minimumWager.mul(3)
                await expect(playerConnectedFlippy.flipCoin(coinFaceSelection, { value: wager })).to.emit(flippy, "CoinFlipped")
            })
        })
    })
}
