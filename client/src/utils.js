const _ = require('lodash')
module.exports = {
  zeroAddress: createAddress(0),
  oneAddress: createAddress(1),
  createAddress,
  toFilterFunction
}

function createAddress(number = (Math.random()*1e18)) {
  return "0x"+(""+number).padStart(40, "0")
}

const takeSameKeys = (filterOrObject, obj) => Object.keys(filterOrObject)
  .reduce((accumulator, key) => {
    if (obj.hasOwnProperty(key)) {
      accumulator[key] = obj[key];
    }
    return accumulator;
  }, {});

  function toFilterFunction(filterOrObject) {
  if (filterOrObject !== null && typeof filterOrObject === 'object') {
    return (obj) => {
      const objectToCompare = takeSameKeys(filterOrObject, obj);
      return _.isEqual(filterOrObject, objectToCompare);
    };
  }
  return filterOrObject;
};

function getTokenId(createTx, recipient) {
  let tokenId
  truffleAssert.eventEmitted(createTx, "Transfer", (ev) => {
    tokenId = ev.tokenId
    return web3.utils.toDecimal(ev.from) === 0 && recipient === ev.to;
  })
  return tokenId
}

async function throws(promise, reason) {
  try {
    await promise
  } catch (e) {
    if (!reason) {
      console.log(e)
    }
    expect(e.reason).to.be.equal(reason)
  }
}

function timeoutUntil(ms) {
  return timeout(ms - (new Date()))
}

function timeout(ms) {
  return new Promise((resolve) => _.delay(resolve, ms))
}
