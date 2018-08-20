pragma solidity ^0.4.16;

import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";

contract ERC20_A is StandardToken {
    address public owner;                     // 所有人
    string public name = "DMDCOIN";      // 代币名称
    string public symbol = "DMD";           // 代币符号
    uint8 public decimals = 18;               // 代币精度
    uint256 public INITIAL_SUPPLY = 1000000000000000000000000000; // 总量10亿

    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        owner = msg.sender;
    }
}
