pragma solidity ^0.6.2;

// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/math/Math.sol";
// import "@openzeppelin/contracts/utils/Address.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721Metadata.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/lifecycle/Pausable.sol";

// contract ERC20Bank is ReentrancyGuard {
//   using SafeMath for uint256;
//   using Math for uint256;
//   using Address for address payable;

//   // can't iterate over map
//   mapping(address => address[]) public accountTokens;
//   // account -> contract -> amount
//   mapping(address => mapping(address => uint256)) public balances;
//   // account -> contract -> amount
//   mapping(address => mapping(address => bool)) public deposited;

//   event BalanceChanged(address indexed account, address indexed contractHash, uint256 amount, uint256 balance, bool negative);
//   event Deposited(address indexed account, address indexed target, address indexed contractHash, uint256 amount, uint256 balance);
//   event Withdrawn(address indexed account, address indexed target, address indexed contractHash, uint256 amount, uint256 balance);

//   /**
//    * @notice Requires two values to be greater than or equal
//    * when compared to one another
//    * @param a uint256 is the first value, which must be greater than or equal to the second parameter
//    * @param b uint256 is the second value, which must be less than or equal to the first parameter
//    */
//   modifier greaterThanOrEqual(uint256 a, uint256 b) {
//     require(a >= b, "a must be greater than or equal to b");
//     _;
//   }

//   constructor()
//     ReentrancyGuard()
//     public
//   {}

//   function transferFrom(
//     address from,
//     address to,
//     address contractHash, // which one
//     uint256 amount // how much
//   )
//     internal
//   {
//     if (amount == 0) return;
//     bool negative = from == this;
//     address account = from;
//     if (negative) {
//       account = to;
//     }
//     uint256 nextBalance = balance(account, contractHash);
//     if (nextBalance == 0) {
//       if (!deposited[account][contractHash]) {
//         accountTokens[account].push(contractHash);
//       }
//       deposited[account][contractHash] = true;
//     }
//     if (negative) {
//       nextBalance = nextBalance.sub(amount);
//     } else {
//       nextBalance = nextBalance.add(amount);
//     }
//     balances[account][contractHash] = nextBalance;
//     emit BalanceChanged(account, contractHash, amount, nextBalance, negative);
//   }

//   /**
//    * @notice Deposits eth and directly credits an account
//    * @param account address to send the eth to
//    */
//   function depositToAccount(
//     address contractHash,
//     address account,
//     uint256 amount
//   )
//     public
//     payable
//   {
//     uint256 value = msg.value;
//     // eth is automatically deposited when the function is called
//     if (contractHash != address(0)) {
//       value = amount;
//       ERC20(contractHash).transferFrom(msg.sender, this, value);
//     }
//     transferFrom(this, account, contractHash, value);
//     emit Deposited(msg.sender, target, contractHash, value, balances[msg.sender]);
//   }
//   /**
//    * @notice Releases funds credited to the sender to a given account
//    * @dev account param will, in most cases, be the sender's address
//    * @dev nonReentrant modifier used to prevent double spends
//    * @param account address the account to send the eth to
//    * @param amount uint256 the amount of eth to send to the account
//    */
//   function releaseTo(
//     address payable account,
//     address contractHash,
//     uint256 amount
//   )
//     public
//     nonReentrant
//   {
//     address payable target = account;
//     if (address(0) == target) {
//       target = msg.sender;
//     }
//     // debit from contract
//     transferFrom(msg.sender, this, contractHash, amount);
//     if (address(0) == contractHash) {
//       // actually transfer the eth
//       target.sendValue(amount);
//     } else {
//       // actually transfer the token
//       ERC20(contractHash).transferFrom(this, target, amount);
//     }
//     emit Withdrawn(msg.sender, target, contractHash, amount, balances[msg.sender]);
//   }
//   /**
//    * @notice Checks the balance of a given account
//    * @param account address to check the balance credited by the contract
//    * @return amount as uint256 as the balance credited to the account and available for withdrawal
//    */
//   function balance(address account, address contractHash) public view returns(uint256 amount) {
//     return balances[account][contractHash];
//   }
// }
