// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WBTC is ERC20{
    constructor () ERC20 ("WBTC Token" , "WBTC"){
        _mint(msg.sender, 10000 * (10 ** uint256(decimals())));
    }
    function GetSomeTestTokens (uint256 _amount) public {
        _mint(msg.sender, _amount);

    }
}