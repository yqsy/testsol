pragma solidity ^0.4.24;

import 'github.com/OpenZeppelin/zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';

contract ERC20_B is StandardToken {
    
    address public admin; // 管理员
    
    string public name = "IPFS FORCE"; // 代币名称
    
    string public symbol = "IPFS"; // 代币符号
    
    uint8 public decimals = 18; // 代币精度
    
    uint256 public INITIAL_SUPPLY = 1000000000000000000000000000; // 总量10亿 * 10^18
    
    // 同一个账户满足任意冻结条件均被冻结
    mapping (address => bool) public frozenAccount; // 无限期冻结的账户
    mapping (address => uint256) public frozenTimestamp; // 有限期冻结的账户
    
    
    // 代币兑换开启
    bool public exchangeFlag = true;
    
    
    // 不满足条件或募集完成多出的eth均返回给原账户
    uint256 public minWei = 1; // 最低打 1 wei ,  1eth = 1*10^18 wei
    
    uint256 public maxWei = 2000000000000000000000; // 最多一次打 2000 eth
    
    uint256 public maxRaiseAmount = 20000000000000000000000; // 募集上限 20000 eth
    
    uint256 public raisedAmount = 0; // 已募集 0 eth
    
    uint256 public raiseRatio = 20000; // 兑换比例 1eth = 20000 token
    
    // event 通知
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        admin = msg.sender;
        balances[msg.sender] = INITIAL_SUPPLY;
    }
    
    // TODO
    
    // 修改管理员
    function changeAdmin(address _newAdmin) public returns (bool) {
        require(msg.sender == admin);
        require(_newAdmin != address(0));
        balances[_newAdmin] = balances[_newAdmin].add(balances[admin]); // 将admin账户的代币转给新的admin
        balances[admin] = 0;
        admin = _newAdmin;
        return true;
    }
    
    // 给指定账户增加代币,并做总量增发
    function generateToken(address _target, uint256 _amount) public returns (bool) {
        require(msg.sender == admin);
        require(_target != address(0));
        balances[_target] = balances[_target].add(_amount); // 发代币
        totalSupply_ = totalSupply_.add(_amount);           // 增发
        INITIAL_SUPPLY = totalSupply_;
        return true;
    }
    
    // 从合约提现
    // 只能提给管理员
    function withdraw (uint256 _amount) public returns (bool) {
        require(msg.sender == admin);
        msg.sender.transfer(_amount);
        return true;
    }
    
    // 锁定账户
    function freeze(address _target, bool _freeze) public returns(bool) {
        require(msg.sender == admin);
        require(_target != address(0));
        
        frozenAccount[_target] = _freeze;
        return true;
    }
    
    // 通过时间戳锁定账户
    
    /// ...
}
