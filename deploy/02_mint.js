const { ethers } = require('hardhat')

module.exports = async function(hre) {
    const { getNamedAccounts, deployments } = hre
    const {deployer} = await getNamedAccounts()
    const tradingCardNFT = await ethers.getContract("TradingCardNFT", deployer)
    const tradingCardNFTTx = await tradingCardNFT.requestTradingCard()
    const tradingCardNFTReceipt = await tradingCardNFTTx.wait(1)

}

module.exports.tags = ["all", "mint"]