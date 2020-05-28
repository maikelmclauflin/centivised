pragma solidity ^0.6.2;

// import "./ContinuousStake.sol";
// import * as HEX from "./HEX.sol";

// /**
//  * @notice Creates and guarantees a claim
//  * @param warrantee address is the new owner of the token
//  * @param warrantor address is the new recipient of the funds of the contract
//  * @param valuation uint256 is the value agreed that is required to fulfill the claim at the end of its life
//  * @param expiresAfter uint256 creates a window in seconds within which a claim can be redeemed to be subesequently fulfilled.
//  * @param tokenURI optional string provides the token uri in json format: https://eips.ethereum.org/EIPS/eip-721
//  * @return tokenId uint256 sends back the tokenId created
//  */
// //  tx.gasprice

// // Continuous Staking for Hex
// contract CHEX is ContinuousStake {
//   constructor(address _hexContractAddress)
//     public
//     ContinuousStake()
//   {
//     hexContractAddress = _hexContractAddress;
//   }
//   function _startStake(uint256 amount, uint256 time) internal override {
//     HEX hexContract = HEX(hexContractAddress);
//     uint256 _stakeIndex = hexContract.stakeListRef[msg.sender].length;
//     hexContract.stakeStart(amount, time / 1 days);
//     return _stakeIndex;
//   }
//   function _endStake(uint256 amount, uint256 time) internal {
//     HEX.stakeEnd(amount, time / 1 days);
//   }
//   function _nextStakeTime() public view {
//     return HEX.currentDay().mul(1 days).add(HEX.LAUNCH_TIME);
//   }
// }
