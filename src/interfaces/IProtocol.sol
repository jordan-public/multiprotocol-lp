// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IProtocol {
    function setParent() external;
    function token(uint256 index) external view returns (address);
    function happy() external;
    function move(address user, uint256 tokenIndex, int256 amount) external;
    function deposit(uint256 [] memory amounts) external;
    function withdraw(uint256 [] memory amounts) external;
}