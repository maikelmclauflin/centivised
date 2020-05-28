pragma solidity ^0.6.2;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "solidity-linked-list/contracts/StructuredLinkedList.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/math/SafeMath.sol";
// import "github.com/Arachnid/solidity-stringutils/strings.sol";
import "./Bond.sol";

contract NotifyBeforeTokenTransferForTest {
  // using StructuredLinkedList for StructuredLinkedList.List;
  // using strings for *;
  using SafeMath for uint256;

  address public __token;
  address public __from;
  address public __to;
  uint256 public __amount;
  uint256 public __start;
  uint256 public __end;
  uint256 public __cap;
  mapping(address => uint256) public holdings;
  mapping(address => uint256) public staked;
  StructuredLinkedList[] public derivedBonds;
  StructuredLinkedList[] public stakers;
  Bond public __contractTarget;

  struct Data {
    address owner;
    address token;
    address from;
    address to;
    uint256 amount;
    uint256 start;
    uint256 end;
    uint256 cap;
  }

  // this should be done in a different way in production
  // this is just to get the point of some sort of accounting system can generate the funds
  function creditAccount(address account, uint256 amount) public {
    holdings[account] = holdings[account].add(amount);
    // if (stakers[account]) {}
  }

  function setContractTarget(
    address _contractTarget,
    address _token,
    uint256 _start,
    uint256 _end,
    uint256 _cap
    // ,
    // address[] memory claimHolders
  ) public returns(address) {
    __start = _start;
    __end = _end;
    __cap = _cap;
    __contractTarget = new Bond(_cap);
    __contractTarget.defineParameters(_contractTarget, _token, __start, __end);
    return __contractTarget.owner();
  }
  // be sure to check msg.sender on the other side of this function
  // if you don't anyone would be able to run cleanup code and tokens can be lost
  // a simple check could look something like: require(msg.sender == from, "the sender must be the current owner of the tokens");
  function beforeTokenTransfer(address token, address from, address to, uint256 amount) external {
    __token = token;
    __from = from;
    __to = to;
    __amount = amount;
    // add and remove from derived bonds
  }

  function mint(uint256 amount) public {
    __contractTarget.mint(msg.sender, amount);
  }

  function retreiveData() public view returns(Data memory) {
    return Data({
      owner: __contractTarget.owner(),
      token: __token,
      from: __from,
      to: __to,
      amount: __amount,
      start: __start,
      end: __end,
      cap: __cap
    });
  }
}
