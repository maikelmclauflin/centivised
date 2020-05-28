pragma solidity ^0.6.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./INotifyBeforeTokenTransfer.sol";

contract Bond is ERC20, ERC20Capped, ERC20Burnable, Ownable {
  uint256 start;
  uint256 end;
  address target;
  address notifyOnTransfer;

  constructor(uint256 cap) public
    // no ticker because there can be overlapping bonds
    // need custom ticker / categorization by attributes
    ERC20("Bond", "")
    ERC20Capped(cap)
    ERC20Burnable()
    Ownable() // creator is owner
  {}

  function defineParameters(
    address _notifyOnTransfer,
    address _target,
    uint256 _start,
    uint256 _end
  ) public onlyOwner {
    target = _target;
    notifyOnTransfer = _notifyOnTransfer;
    start = _start;
    end = _end;
  }

  function mint(address account, uint256 amount) public onlyOwner {
    _mint(account, amount);
  }

  function _mint(address account, uint256 amount) internal override {
    super._mint(account, amount);
  }

  function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20, ERC20Capped) {
    super._beforeTokenTransfer(from, to, amount);
    // if beforeTokenTransfer is false, the underlying transfer is rejected
    // on the other side of this, one could change the allowance from one user to another
    INotifyBeforeTokenTransfer(owner()).beforeTokenTransfer(target, from, to, amount);
  }
}
