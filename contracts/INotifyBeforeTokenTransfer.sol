pragma solidity ^0.6.2;

interface INotifyBeforeTokenTransfer {
  /**
   * @notice Notifies a creator contract that a token is being moved so any cleanup work can be done
   * @notice be sure to check msg.sender on the other side of this function
   * @notice if you don't anyone would be able to run cleanup code and tokens can be lost
   * @notice a simple check could look something like: require(msg.sender == from, "the sender must be the current owner of the tokens");
   * @param token address the token being transferred. usually refers to this contract, but can reference other tokens depending on your setup.
   * @param from address where the token is being transferred from
   * @param to address where the token is being transferred to
   * @param amount uint256 the amount of the token
   */
  function beforeTokenTransfer(address token, address from, address to, uint256 amount) external;
  /**
   * @notice Mints a token
   */
  function mintAndTransfer(address token, address to, uint256 amount) external;
  function receiveAndBurn(address token, address to, uint256 amount) external;
}
