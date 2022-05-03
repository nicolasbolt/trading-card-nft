const {network} = require('hardhat')
const { IPFS_URLS } = require("../helpers/constants")

const FUND_AMOUNT = "100000000000000"

module.exports = async function(hre) {
    const {getNamedAccounts, deployments} = hre
    const {deployer} = await getNamedAccounts()
    const {deploy, log} = deployments
    const chainId = network.config.chainId
    let vrfCoordinatorV2Address, subscriptionId

    if (chainId == 31337) {
        // use mock
        const vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock")
        vrfCoordinatorV2Address = vrfCoordinatorV2Mock.address
        const tx = await vrfCoordinatorV2Mock.createSubscription()
        const txReceipt = await tx.wait(1)
        subscriptionId = txReceipt.events[0].args.subId
        await vrfCoordinatorV2Mock.fundSubscription(subscriptionId, FUND_AMOUNT)
    } else {
        vrfCoordinatorV2Address = '0x6168499c0cFfCaCD319c818142124B7A15E857ab'
        subscriptionId = '3665'
    }

    const args = [
        vrfCoordinatorV2Address,
        '0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc',
        subscriptionId,
        '500000',
        IPFS_URLS
    ]

    const tradingCardNFT = await deploy("TradingCardNFT", {
        from: deployer,
        args: args,
        log: true,
    })
}