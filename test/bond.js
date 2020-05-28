const Bond = artifacts.require("./Bond.sol")
const NotifyBeforeTokenTransferForTest = artifacts.require("./NotifyBeforeTokenTransferForTest.sol")
const chai = require("chai")
const { assert, expect } = chai
const truffleAssert = require('truffle-assertions')
const chaiBigNumber = require('bn-chai')
chai.use(chaiBigNumber())
const Web3 = require('web3')
const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:8545'))
const { _, toWei } = web3.utils
const { zeroAddress, createAddress, toFilterFunction } = require('../client/src/utils')

contract("Bond", accounts => {
  let bond, 
    notifyBeforeTokenTransferForTest
  beforeEach(async () => {
    ;([bond, notifyBeforeTokenTransferForTest] = await Promise.all([
      Bond.new(1, { from: accounts[0] }),
      NotifyBeforeTokenTransferForTest.new({ from: accounts[0] })
    ]))
  })
  afterEach(async () => {
    bond = null
    notifyBeforeTokenTransferForTest = null
  })
  it("should notify the passed contract of a transfer", async () => {
    await notifyBeforeTokenTransferForTest.creditAccount(accounts[1], 50)

    await notifyBeforeTokenTransferForTest.creditAccount(accounts[2], 20)

    await notifyBeforeTokenTransferForTest.creditAccount(accounts[3], 30)

    const setContractTargetReceipt = await notifyBeforeTokenTransferForTest.setContractTarget(
      bond.address, // which bond contract to generate
      zeroAddress, // the erc20 being bound
      1, // the timestamp to start the bond
      2, // the timestamp to end the bond
      100, // the max number of bound tokens in notifyBeforeTokenTransferForTest
      {
        from: accounts[0]
      }
    )
    const target = await notifyBeforeTokenTransferForTest.__contractTarget.call()
    const bondTarget = new Bond(target)
    assert.equal(
      await bondTarget.owner(),
      notifyBeforeTokenTransferForTest.address,
      "the owner of the bond contract should be the contract that created it"
    )

    // Get stored value
    const values = await notifyBeforeTokenTransferForTest.retreiveData.call()
    assert.isTrue(toFilterFunction({
      owner: notifyBeforeTokenTransferForTest.address,
      token: zeroAddress,
      from: zeroAddress,
      to: zeroAddress,
      amount: "0",
      start: "1",
      end: "2",
      cap: "100"
    })(values), "The value was not stored.")

    await notifyBeforeTokenTransferForTest.mint(10, {
      from: accounts[1]
    })

    const afterMintValues = await notifyBeforeTokenTransferForTest.retreiveData.call()
    assert.isTrue(toFilterFunction({
      owner: notifyBeforeTokenTransferForTest.address,
      token: zeroAddress,
      from: zeroAddress,
      to: accounts[1],
      amount: "10",
      start: "1",
      end: "2",
      cap: "100"
    })(afterMintValues), "The value was not stored.")
    
    await bondTarget.transfer(accounts[2], 5, {
      from: accounts[1]
    })

    const afterTransferValues = await notifyBeforeTokenTransferForTest.retreiveData.call()
    assert.isTrue(toFilterFunction({
      owner: notifyBeforeTokenTransferForTest.address,
      token: zeroAddress,
      from: accounts[1],
      to: accounts[2],
      amount: "5",
      start: "1",
      end: "2",
      cap: "100"
    })(afterTransferValues), "The value was not stored.")
  })
  // it('')
})
