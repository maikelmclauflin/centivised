const Bond = artifacts.require("./Bond.sol")
const NotifyBeforeTokenTransferForTest = artifacts.require("./NotifyBeforeTokenTransferForTest.sol")

const { createAddress, zeroAddress } = require('../client/src/utils')
// const HEXContract = HEX(0x2b591e99afe9f32eaa6214f7b7629768c40eeb39)

module.exports = async function (deployer, network, accounts) {
  const notMainnet = network !== "mainnet"
  const overwrite = notMainnet
  const globalOptions = { 
    overwrite,
    from: accounts[0]
  }
  if (notMainnet) {
    await deployer.deploy(NotifyBeforeTokenTransferForTest, globalOptions)
  }
  await deployer.deploy(Bond, 1, globalOptions)
}
