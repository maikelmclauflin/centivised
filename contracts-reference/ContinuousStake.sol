pragma solidity ^0.6.2;

// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "solidity-linked-list/contracts/StructuredLinkedList.sol";
// import "github.com/Arachnid/solidity-stringutils/strings.sol";

// contract ContinuousStake {
//   using Strings for uint256;
//   using SafeMath for uint256;
//   using StructuredLinkedList for StructuredLinkedList.List;
//   // stakeDelay => stakeInterval
//   mapping(string => address) rhythmByHash;
//   // user public address => rhythm address => rhythm profile
//   mapping(address => mapping(address => uint256)) provisionedToLock;
//   mapping(address => mapping(address => uint256)) currentlyLocked;
//   mapping(address => mapping(address => uint256)) setLockedAtNextBeat;

//   mapping(address => uint256) rhythmAddressToId;
//   address[] rhythms;
//   // rhythmContract => x
//   mapping(address => uint256) nextStakeTime;
//   mapping(address => uint256) startStakeCursor;
//   mapping(address => address[]) enabledList;
//   mapping(address => StructuredLinkedList.List) stakerList;
//   // uuid256 identiifer points to the identifier of the stakerList
//   mapping(address => mapping(address => uint256)) enabledStakerIdentifier;

//   string ErrNotEnoughFunds = "ContinuousStake: unable to deprovision from stake: not enough funds";

//   /**
//    * @notice returns a timestamp (reduces the number of warnings in lint)
//    * @return timestamp uint256 the timestamp of the current block
//    */
//   function timestamp () public returns(uint256) {
//     return block.timestamp;
//   }

//   /**
//    * @notice Computes the number of days until the stake is defined to be released
//    * @param currentTime uint256 the Time of staking to compute for
//    * @param stakeDelay uint256 the number of Times to shift the start Time
//    * @param stakeInterval uint256 the number of Times interval to stake
//    * @return uint256 the number of Times
//    */
//   // function endStakeTime(uint256 currentTime, uint256 stakeDelay, uint256 stakeInterval) public pure returns(uint256) {
//   //   return currentTime.sub(stakeDelay).mod(stakeInterval);
//   // }

//   function rhythmOptIn(address rhythmContract, address staker) public {
//     require(this.enabledStakerIdentifier[rhythmContract][staker] == 0, "staker cannot already be in the enabledStakerIdentifier list");
//     this.enabledList[rhythmContract].push(staker);
//     this.enabledStakerIdentifier[rhythmContract][staker] = rhythm.enabledList.length;
//   }

//   function hashAttributes(string namespace, uint256 stakeDelay, uint256 stakeInterval) public pure returns(string) {
//     return keccak256(
//       abi.encodePacked(
//         namespace,
//         abi.encodePacked(
//           "-",
//           abi.encodePacked(
//             stakeDelay.toString(),
//             abi.encodePacked(
//               "-",
//               stakeInterval.toString()
//             )
//           )
//         )
//       )
//     );
//   }

//   function createRhythm(string namespace, uint256 _rawStakeDelay, uint256 stakeInterval) public returns(uint256) {
//     // to dedupe rhythms
//     require(stakeInterval > 0, "stake interval must be at least 1 day");
//     uint256 rawStakeDelay = _rawStakeDelay;
//     if (rawStakeDelay == 0) {
//       rawStakeDelay = this.nextStakeTime();
//     }
//     uint256 stakeDelay = rawStakeDelay.mod(stakeInterval);
//     // do not create another rhythm
//     address rhythmAddress = rhythmByHash[this.hashAttributes(namespace, stakeDelay, stakeInterval)];
//     if (rhythmAddress == address(0)) {
//       uint256 rhythmId = rhythms.length;
//       RhythmToken rhythm = new RhythmToken(rhythmId, stakeDelay, stakeInterval);
//       rhythmAddress = address(rhythm);
//       // set on contract
//       rhythms.push(rhythmAddress);
//       this.rhythmAddressToId[rhythmAddress] = rhythmId;
//       this.rhythmByHash[stakeDelay][stakeInterval] = rhythmAddress;
//     }
//     return rhythmAddressToId[rhythmAddress];
//   }

//   function provisionToJumpIntoRhythm(address rhythmContract, uint256 amount, uint256 insertionPoint) public {
//     // RhythmToken(rhythmContract)._mint(msg.sender, amount);
//     this.stakerList.insertAfter(insertionPoint, this.enabledStakerIdentifier[rhythmContract][msg.sender]);
//     this.provisionedToLock[rhythmContract][msg.sender] = this.provisionedToLock[rhythmContract][msg.sender].add(amount);
//     uint amountToBeLocked = this.lockedToken[msg.sender].add(amount);
//     require(amountToBeLocked <= this.allowance(msg.sender, address(this)), "");
//     this.lockedToken[msg.sender] = amountToBeLocked;
//   }

//   function markProvisionedTokens(address rhythmContract, address stakingOwner) internal returns(uint256) {
//     uint256 toLock = this.setLockedAtNextBeat[rhythmContract][stakingOwner];
//     uint256 toMint = toLock.sub(this.currentlyLocked[rhythmContract][stakingOwner]);
//     this.currentlyLocked[rhythmContract][stakingOwner] = toLock;
//     return toMint;
//   }

//   function startRhythmicStake(address rhythmContract) public returns(bool) {
//     uint256 nextStakeTime = this.nextStakeTime();
//     uint256 stakeStep = rhythm.stakeStep[nextStakeTime];
//     if (stakeStep == 0) {
//       this.rhythmicStakeStep1(rhythmContract);
//       stakeStep = this.setStakeStep(rhythmContract, nextStakeTime, 1);
//     }
//     // check enough gas
//     if (stakeStep == 1) {
//       bool finished = this.rhythmicStakeStep2(rhythmContract);
//       if (!finished) {
//         return finished;
//       }
//       stakeStep = this.setStakeStep(rhythmContract, nextStakeTime, 2);
//       this.startStakeCursor[rhythmContract] = 0;
//     }
//     if (gasleft() < 40000) {
//       break;
//     }
//     if (stakeStep == 2) {
//       this.rhythmicStakeStep3(rhythmContract, nextStakeTime);
//       stakeStep = this.setStakeStep(rhythmContract, nextStakeTime, 3);
//     }
//     if (stakeStep == 3) {
//       // unlock profits
//       stakeStep = this.setStakeStep(rhythmContract, nextStakeTime, 4);
//     }
//     if (stakeStep == 4) {
//       // distribute profits
//       stakeStep = this.setStakeStep(rhythmContract, nextStakeTime, 0);
//     }
//     return true;
//   }

//   function rhythmicStakeStep1(address rhythmContract, uint256 nextStakeTime) internal {
//     Rhythm storage rhythm = rhythms[rhythmContract];
//     // makes the rhythm "late" for the "current day" but in time for the next state to start... when the stake is supposed to
//     require((rhythm.startDay - 1) == nextStakeTime, "the rhythm must only start the day before it is set to start");
//     // a rhythm must have value to be staked
//     require(rhythm.token.totalBalance() != 0, "the rhythm must have a total to stake");
//     // do not allow people to deposit into the rhythm after staking has started
//     rhythm.nextStakeTime = nextStakeTime;
//     rhythm.initiateBlockNumber = block.number;
//   }
  
//   function rhythmicStakeStep3(address rhythmContract) {
//     ERC20 memory rhythm = rhythms[rhythmContract];
//     uint256 daysCanStakeFor = this.durationOfStake(nextStakeTime, rhythm.stakeDelay, rhythm.stakeInterval);
//     uint256 stakeEndId = this._startStake(rhythm.total, daysCanStakeFor);
//     stakeEndIds[rhythmContract] = stakeEndId;
//   }

//   function rhythmicStakeStep2(address bondAddress) internal returns(bool) {
//     // iterate over involved individuals pending stake token (low cost / mint)
//     Bond bond = Bond(this.futures[bondAddress]);
//     do {
//       if (gasleft() < 5000) {
//         return;
//       }
//       (bool exists, , uint256 nextNode) = this.stakerList[bondAddress].getNode(self, this.startStakeCursor[bondAddress], true);
//       if (!exists) {
//         break;
//       }
//       this.startStakeCursor[bondAddress] = nextNode;
//       if (nextNode == 0) {
//         break;
//       }
//       // provision token to be staked
//       address stakingAddress = this.enabledList[bondAddress][nextNode.sub(1)];
//       uint256 toMint = this.markProvisionedTokens(bondAddress, stakingAddress);
//       bond._mint(stakingAddress, toMint);
//     } while (true);
//     return true;
//   }

//   function deprovisionRhythm(address sender, address rhythmContract, uint256 amount) internal {
//     provisionedToLock[sender][rhythmContract] = provisionedToLock[sender][rhythmContract].sub(amount);
//     require(input[sender][rhythmContract] >= continueLocking[sender][rhythmContract], ErrNotEnoughFunds);
//   }

//   function setStakeStep(address rhythmContract, uint256 nextStakeTime, uint256 state) internal returns(uint256) {
//     rhythms[rhythmContract].stakeStep[nextStakeTime] = state;
//     return state;
//   }

//   function _startStake(uint256 amount, uint256 time) internal virtual { }

//   function _endStake(uint256 amount, uint256 time) internal virtual { }

//   function durationOfStake(uint256 nextStakeTime, uint256 stakeDuration) public pure virtual {
//     return nextStakeTime.add(stakeDuration);
//   }

//   fallback() external payable {
//     require(false, "this function should fail");
//   }
// }
