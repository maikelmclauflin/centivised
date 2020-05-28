pragma solidity ^0.6.2;

// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/math/Math.sol";
// import "@openzeppelin/contracts/utils/Address.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721Metadata.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// /**
//  * @title A digital relationship between two entities
//  * @author Michael McLaughlin
//  * @notice You can use this contract for basic warranties
//  */
// contract Warranty is ERC721Metadata, ReentrancyGuard, ERC20Bank {
//   using SafeMath for uint256;
//   using Math for uint256;
//   using Address for address payable;

//   mapping(uint256 => address) public _pendingTransfer;

//   Claim[] public _claims;
//   struct Claim {
//     address warrantor;
//     uint256 value;
//     uint256 valuation;
//     uint256 expiresAfter;
//     uint256 activatedAt;
//     uint256 delayTime;
//     bool redeemed;
//     bool fulfilled;
//     bool terminated;
//   }

//   event Redeemed(uint256 indexed tokenId, address indexed warrantor, address indexed warrantee, bool redeemed);
//   event Fulfilled(uint256 indexed tokenId, address indexed warrantor, address indexed warrantee, bool redeemed);
//   event Terminated(uint256 indexed tokenId, address indexed account);
//   event WarrantorshipChanged(uint256 indexed tokenId, address indexed warrantor);
//   event ClaimBalanceUpdated(uint256 indexed tokenId, address indexed contractHash, uint256 value);
//   event NotesAppended(uint256 indexed tokenId, address indexed account, string notes);

//   constructor()
//     ERC20("Warranty", "WRNT")
//     ReentrancyGuard()
//     ERC20Bank()
//     public
//   {}

//   fallback() external payable {
//     require(false, "fallback function use not allowed");
//   }

//   /**
//    * @notice Allows only the two entities to run operation
//    * @param tokenId uint256 ID is the token in question
//    */
//   modifier warranteeOrWarrantorOnly(uint256 tokenId) {
//     require((
//       isWarrantee(msg.sender, tokenId) ||
//       isWarrantor(msg.sender, tokenId)
//     ), "sender must either be the token owner (warrantee) or the warrantor");
//     _;
//   }
//   /**
//    * @notice Allows only the warrantee of a claim to operate
//    * @param tokenId uint256 ID is the token in question
//    */
//   modifier warranteeOnly(uint256 tokenId) {
//     require(isWarrantee(msg.sender, tokenId), "sender must be the owner of the token");
//     _;
//   }
//   /**
//    * @notice Allows only the warrantor of a claim to operate
//    * @param tokenId uint256 ID is the token in question
//    */
//   modifier warrantorOnly(uint256 tokenId) {
//     require(isWarrantor(msg.sender, tokenId), "sender must be the warrantor of the token");
//     _;
//   }
//   /**
//    * @notice Allows only non redeemed tokens to be operated upon
//    * @param tokenId uint256 ID is the token in question
//    */
//   modifier notRedeemedOnly(uint256 tokenId) {
//     require(!_claims[tokenId].redeemed, "only non redeemed claims can use this method");
//     _;
//   }
//   /**
//    * @notice Allows only non terminated tokens to be operated upon
//    * @param tokenId uint256 ID is the token in question
//    */
//   modifier notTerminatedOnly(uint256 tokenId) {
//     require(!_claims[tokenId].terminated, "only non terminated claims can use this method");
//     _;
//   }
//   /**
//    * @notice Allows only non expired tokens to be operated upon
//    * @param tokenId uint256 ID is the token in question
//    */
//   modifier notExpiredOnly(uint256 tokenId) {
//     require(
//       _claims[tokenId].activatedAt == 0 ||
//       _claims[tokenId].activatedAt.add(_claims[tokenId].delayTime).add(_claims[tokenId].expiresAfter) > timestamp(),
//       "only non expired claims can use this method"
//     );
//     _;
//   }
//   /**
//    * @notice Checks whether a given token is owned by a particular address
//    * @param warrantee address is the owner in question
//    * @param tokenId uint256 is the token in question
//    */
//   modifier checkWarranteeOf(address warrantee, uint256 tokenId) {
//     if (warrantee != address(0)) { // any owner is honored
//       require(isWarrantee(warrantee, tokenId), "must be working with the correct warrantee");
//     }
//     _;
//   }
//   /**
//    * @notice Makes sure that the account passed is the owner of the token
//    * @param account address is the address being checked against
//    * @param tokenId uint256 ID is the token in question
//    * @return matches as bool whether the account is indeed the owner of the token
//    */
//   function isWarrantee(address account, uint256 tokenId) public view returns(bool matches) {
//     return account == this.ownerOf(tokenId);
//   }
//   /**
//    * @notice Makes sure that the account passed is set as the token's warrantor
//    * @param account address is the address being checked against
//    * @param tokenId uint256 ID is the token in question
//    * @return matches as bool whether the account is indeed the warrantor of the token
//    */
//   function isWarrantor(address account, uint256 tokenId) public view returns(bool matches) {
//     return account == _claims[tokenId].warrantor;
//   }
//   function timestamp() internal view returns(uint256) {
//     return block.timestamp;
//   }
//   /**
//    * @notice Extend the timeline until the claim expires
//    * @param tokenId uint256 as the targeted token
//    * @param expiryTime uint256 as the amount of time to be added to the expiry time first set when the claim was created
//    * @param delayTime uint256 as the amount of time to be added to the delay time first set to zero
//    */
//   function extendClaimExpiration(uint256 tokenId, uint256 expiryTime, uint256 delayTime)
//     public
//     warrantorOnly(tokenId)
//     notTerminatedOnly(tokenId)
//     notRedeemedOnly(tokenId)
//     // ensure no overflow occurs
//     greaterThanOrEqual(_claims[tokenId].activatedAt.add(delayTime).add(expiryTime), _claims[tokenId].activatedAt)
//   {
//     _claims[tokenId].delayTime = _claims[tokenId].delayTime.add(delayTime);
//     _claims[tokenId].expiresAfter = _claims[tokenId].expiresAfter.add(expiryTime);
//   }
//   /**
//    * @notice Warrantor can fulfill the claim for the amount agreed upon when the claim was first created.
//    * @param warrantee address to check ownership of the token (optional)
//    * @param tokenId uint256 the id of the token in question
//    */
//   function fulfillClaim(uint256 tokenId, address contractHash, address warrantee)
//     public
//     payable
//     warrantorOnly(tokenId)
//     checkWarranteeOf(warrantee, tokenId)
//   {
//     Claim storage claim = _claims[tokenId];
//     // if the warrantor sends more than enough or has enough in their balance
//     uint256 bal = balance(contractHash, msg.sender);
//     debitAccount(msg.sender, bal); // guarantor temporarily has zero balance
//     uint256 value = claim.value.add(msg.value).add(bal);
//     require(value >= claim.valuation, "claim can only be fullfilled for the original agreed upon valuation");
//     creditAccount(msg.sender, value.sub(claim.valuation));
//     creditAccount(this.ownerOf(tokenId), claim.valuation);
//     updateClaimValue(tokenId, contractHash, 0); // remove funds locked in claim
//     claim.fulfilled = true;
//     emit Fulfilled(tokenId, msg.sender, warrantee, claim.redeemed);
//     _terminateClaim(tokenId, contractHash);
//   }
//   function _terminateClaim(uint256 tokenId, address contractHash)
//     internal
//     notTerminatedOnly(tokenId)
//   {
//     Claim storage claim = _claims[tokenId];
//     if (!claim.fulfilled && claim.value != 0) {
//       // should only have value assigned, to be divii'd up if claim has not been fulfilled
//       uint256 elapsed = claim.expiresAfter.sub(timeToClaimExpire(tokenId));
//       uint256 leftover = claim.value.mul(claim.expiresAfter).sub(claim.value.mul(elapsed)).div(claim.expiresAfter);
//       creditAccount(this.ownerOf(tokenId), leftover);
//       creditAccount(claim.warrantor, claim.value.sub(leftover));
//     }
//     claim.terminated = true;
//     updateClaimValue(tokenId, contractHash, 0); // remove funds locked in claim
//     emit Terminated(tokenId, msg.sender);
//   }
//   /**
//    * @notice Terminates the claim in question. Ends the claim completely and hands all funds over to the warrantor.
//    * disallow redeemed tokens from being terminated
//    * @param tokenId uint256 is the targeted token
//    */
//   function terminateClaim(uint256 tokenId, address contractHash)
//     public
//     warranteeOnly(tokenId)
//     notRedeemedOnly(tokenId)
//   {
//     _terminateClaim(tokenId, contractHash);
//   }
//   /**
//    * @notice Creates and guarantees a claim
//    * @param warrantee address is the new owner of the token
//    * @param warrantor address is the new recipient of the funds of the contract
//    * @param valuation uint256 is the value agreed that is required to fulfill the claim at the end of its life
//    * @param expiresAfter uint256 creates a window in seconds within which a claim can be redeemed to be subesequently fulfilled.
//    * @param tokenURI optional string provides the token uri in json format: https://eips.ethereum.org/EIPS/eip-721
//    * @return tokenId uint256 sends back the tokenId created
//    */
//   function createAndFundClaim(
//     address payable warrantee,
//     address payable warrantor,
//     uint256 valuation,
//     uint256 expiresAfter,
//     string memory tokenURI
//   )
//     public
//     payable
//     returns(uint256)
//   {
//     uint256 tokenId = createClaim(warrantee, valuation, expiresAfter, tokenURI);
//     transferWarrantorship(tokenId, warrantor);
//     fundClaim(tokenId, msg.value);
//     return tokenId;
//   }
//   /**
//    * @notice transfers the warrantor of the erc721 to another owner
//    * @param tokenId uint256 the token to transfer
//    * @param account address the account to transfer to
//    */
//   function transferWarrantorship(uint256 tokenId, address account)
//     public
//     notExpiredOnly(tokenId)
//     warranteeOnly(tokenId)
//   {
//     _activateClaim(tokenId);
//     _claims[tokenId].warrantor = account;
//     emit WarrantorshipChanged(tokenId, account);
//   }
//   /**
//    * @notice provides the full timeline for a given claim's expiration
//    * @param tokenId uint256 defines the token in question
//    * @return expireTime uint256 defines when the claim will no longer be redeemable by the warrantee
//    */
//   function claimExpireTime(uint256 tokenId)
//     public
//     view
//     returns(uint256 expireTime)
//   {
//     return _claims[tokenId].activatedAt.add(_claims[tokenId].delayTime).add(_claims[tokenId].expiresAfter);
//   }
//   /**
//    * @notice provides the number of seconds until the expireTime will be reached
//    * @param tokenId uint256 the token in question
//    * @return timeUntil uint256 defines the number of seconds until the expireTime is met
//    */
//   function timeToClaimExpire(uint256 tokenId)
//     public
//     view
//     returns(uint256 timeUntil)
//   {
//     uint256 expireTime = claimExpireTime(tokenId);
//     uint256 tsmp = timestamp();
//     if (expireTime <= tsmp) {
//       return 0;
//     }
//     return expireTime.sub(tsmp);
//   }
//   /**
//    * @notice Guarantees a claim by claiming responsibility for the other side of the transaction, the warrantor
//    * also useful when being sold a warranty by another warrantor or by the warrantee
//    * @param tokenId uint256 targets a specific token
//    */
//   function guaranteeClaim(uint256 tokenId, uint256 value)
//     public
//     payable
//     notRedeemedOnly(tokenId)
//     notTerminatedOnly(tokenId)
//   {
//     Claim storage claim = _claims[tokenId];
//     require((
//       _pendingTransfer[tokenId] == msg.sender
//     ), "unable to hand off claim unless it is first posted for transfer");
//     // activatedAt will not yet be set if first time
//     uint256 availableCredit = balance(msg.sender).add(msg.value);
//     require(availableCredit >= claim.value, "available credit must meet or exceed claim value");
//     require(value >= claim.value, "claim must preserve currently backed value");
//     address previousOwner = this.ownerOf(tokenId);
//     creditAccount(previousOwner, claim.value); // give back the value provided by previous warrantor
//     claim.value = 0; // reset value
//     fundClaim(tokenId, value); // back claim with new and old value
//     transferFrom(previousOwner, msg.sender, tokenId); // transfer token
//     setApprovalForAll(previousOwner, false); // disallow previous owner to move token
//     _pendingTransferClaim(tokenId, address(0));
//   }
//   function _activateClaim(uint256 tokenId) internal {
//     if (_claims[tokenId].activatedAt == 0) {
//       _claims[tokenId].activatedAt = timestamp();
//     }
//   }
//   /**
//    * @notice Posts a claim to be picked up "guaranteed" by another entity
//    * @dev can only sell if the token is not already being sold
//    * @param tokenId uint256 the targeted token
//    * @param account address the buyer to pick up the claim
//    */
//   function postClaim(uint256 tokenId, address account)
//     public
//     warranteeOnly(tokenId)
//   {
//     require(_pendingTransfer[tokenId] == address(0), "only claims that are not being sold can be put up for sale");
//     _pendingTransfer[tokenId] = account;
//     approve(account, tokenId);
//   }
//   /**
//    * @notice Un-posts a claim that was previously posted.
//    * If there is a disagreement, the warrantee can refuse the transfer
//    * @param tokenId uint256 the targeted token
//    */
//   function depostClaim(uint256 tokenId)
//     public
//     warranteeOnly(tokenId)
//   {
//     require(_pendingTransfer[tokenId] != address(0), "only claims that are being sold can be deposted");
//     _pendingTransferClaim(tokenId, address(0));
//   }
//   function _pendingTransferClaim(uint256 tokenId, address account) internal {
//     _pendingTransfer[tokenId] = account;
//   }
//   /**
//    * @notice Fund a claim
//    * @notice anybody can add to a claim's value. value will only be accessable to the owner
//    * @dev only funds if the claim has not already been terminated.
//    * Otherwise it would go directly to the warrantor or the warrantee if it was redeemed.
//    * That's just confusing.
//    * @param tokenId uint256 the token to be targeted
//    */
//   function fundClaim(uint256 tokenId, uint256 amount)
//     public
//     payable
//     notTerminatedOnly(tokenId)
//   {
//     depositToAccount(msg.sender);
//     creditClaim(tokenId, amount);
//     debitAccount(msg.sender, amount);
//   }
//   function creditClaim(uint256 tokenId, uint256 value) internal {
//     if (value != 0) {
//       updateClaimValue(tokenId, _claims[tokenId].value.add(value));
//     }
//   }
//   function updateClaimValue(uint256 tokenId, address contractHash, uint256 value) internal {
//     if (_claims[tokenId].value != value) {
//       _claims[tokenId].value = value;
//       emit ClaimBalanceUpdated(tokenId, contractHash, value);
//     }
//   }
//   /**
//    * @notice De-Redeems a claim. Allows for warrantee or warrantor to reset time if guarantee's submission did not meet agreement, or for any other reason
//    * @dev Can only be completed by the warrantee or warrantor.
//    * only warrantor adds extra time. transactions would be no-ops if they came from user, or at worst would waste the tx fees from the business
//    * @param tokenId uint256 targets a token
//    * @param expiryTime uint256 adds more time (in seconds) to the expiration decay
//    * @param delayTime uint256 adds more time to the delay offset (in seconds)
//    */
//   function deredeemClaim(uint256 tokenId, uint256 expiryTime, uint256 delayTime)
//     public
//     warranteeOrWarrantorOnly(tokenId)
//   {
//     require(_claims[tokenId].redeemed, "only a redeemed claim can be reset");
//     _claims[tokenId].redeemed = false;
//     emit Redeemed(tokenId, _claims[tokenId].warrantor, this.ownerOf(tokenId), _claims[tokenId].redeemed);
//     if (msg.sender == _claims[tokenId].warrantor) {
//       extendClaimExpiration(tokenId, expiryTime, delayTime);
//     }
//   }
//   function refundClaim(uint256 tokenId, address contractHash)
//     public
//     warrantorOnly(tokenId)
//     // can be expired, just not terminated
//     notTerminatedOnly(tokenId)
//   {
//     creditAccount(this.ownerOf(tokenId), _claims[tokenId].value);
//     _claims[tokenId].value = 0;
//     _terminateClaim(tokenId, contractHash);
//   }
//   /**
//    * @notice Redeems a claim such that an account is notified that it needs to be fulfilled
//    * if claim is accepted guarantee will get the funds defined in valuation back
//    * @param tokenId targets a given token
//    */
//   function redeemClaim(uint256 tokenId)
//     public
//     warranteeOnly(tokenId)
//     notRedeemedOnly(tokenId)
//     notTerminatedOnly(tokenId)
//   {
//     require(!_claims[tokenId].redeemed, "claim cannot be redeemed");
//     _claims[tokenId].redeemed = true;
//     emit Redeemed(tokenId, _claims[tokenId].warrantor, this.ownerOf(tokenId), _claims[tokenId].redeemed);
//   }
//   /**
//    * @notice overwrites an internal safeMint to allow anyone to mint their own
//    * could probably be gotten rid of if a factory was used instead
//    * @param to address the address to assign ownership of the newly minted token to
//    * @param tokenId uint256 the id of the token to be minted
//    * @param _data bytes a set of bytes to hold with the tokenId
//    */
//   function safeMint(address to, uint256 tokenId, bytes memory _data) public returns (bool) {
//     _safeMint(to, tokenId, _data);
//     return true;
//   }
//   /**
//    * @notice Create a claim by minting it yourself or any given contract
//    * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
//    * @dev safeMint is used so integrating with a contract should be possible
//    * @param warrantee address is the address that should own the token to start
//    * @param valuation holds the agreed upon valuation of the claim
//    * @param expiresAfter holds the number of seconds after the claim is guaranteed by a warrantor that the warranty should expire
//    * @param tokenURI optional string provides the token uri in json format: https://eips.ethereum.org/EIPS/eip-721
//    * @return tokenId uint256 sends back the tokenId created
//    */
//   function createClaim(
//     address warrantee,
//     uint256 valuation,
//     uint256 expiresAfter,
//     string memory tokenURI
//   )
//     public
//     returns(uint256)
//   {
//     uint256 tokenId = _claims.length;
//     require(expiresAfter < 100000000000, "expires after value cannot be too large");
//     _safeMint(warrantee, tokenId);
//     if (bytes(tokenURI).length > 0) {
//       _setTokenURI(tokenId, tokenURI);
//     }
//     // metadata to associate with the id
//     _claims.push(Claim({
//       valuation: valuation,
//       // set when the claim is guaranteed
//       value: 0,
//       warrantor: warrantee,
//       activatedAt: 0,
//       delayTime: 0,
//       // only need approximations
//       expiresAfter: expiresAfter,
//       redeemed: false,
//       fulfilled: false,
//       terminated: false
//     }));
//     return tokenId;
//   }
//   /**
//    * @notice adds notes to a particular claim
//    * @param tokenId uint256 the token to target
//    * @param notes optional string the notes to append
//    */
//   function addNotes(
//     uint256 tokenId,
//     string memory notes
//   )
//     public
//     warranteeOrWarrantorOnly(tokenId)
//   {
//     if (bytes(notes).length > 0) {
//       emit NotesAppended(tokenId, msg.sender, notes);
//     }
//   }
// }
