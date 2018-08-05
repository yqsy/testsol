pragma solidity ^0.4.16;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract TokenERC20 {
    
    // 代币名称
    string public name;
    
    // 代币符号
    string public symbol;
    
    // 小数点位
    uint8 public decimals = 18;
    
    // 总发行量
    uint256 public totalSupply;

    // [账户]余额
    mapping (address => uint256) public balanceOf;
    
    // [账户A] => [账户B]允许额度
    // 账户A允许账户B转出的代币数额
    mapping (address => mapping (address => uint256)) public allowance;

    // 转账 通知所有人
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    // 允许转账值
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // 资金销毁
    event Burn(address indexed from, uint256 value);


    function TokenERC20(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals); // totalSupply, 总发行量是最小单位!!!
        balanceOf[msg.sender] = totalSupply;                // 创世者得到所有的代币
        name = tokenName;                                   // 代币名称
        symbol = tokenSymbol;                               // 代币符号
    }


    function _transfer(address _from, address _to, uint _value) internal {
        // 目的地不为0
        require(_to != 0x0);
        
        // 转账者有足够的资金
        require(balanceOf[_from] >= _value);
        
        // 是否溢出
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        
        // 用来assert,保持交易后总量不变
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        
        // A 扣钱
        balanceOf[_from] -= _value;
        
        // B 加钱
        balanceOf[_to] += _value;
        
        
        // 触发日志
        emit Transfer(_from, _to, _value);
        
        // 保证前后一致
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    
    // 包装了一下, 因为发送者不一定绝对是msg.sender
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    
    // 从他人账户中转账给_to(还可以不是自己哦)
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // [他人] => [自己账户] 允许额度
        require(_value <= allowance[_from][msg.sender]);    
        
        // [他人] => [自己账户] 允许额度减少
        allowance[_from][msg.sender] -= _value;
        
        
        // 还可以指定人转账
        _transfer(_from, _to, _value);
        return true;
    }

    
    // 允许他人(_spender)可以从自己(msg.sender)这里拿走代币
    function approve(address _spender, uint256 _value) public returns (bool success) {
        
        allowance[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // 对_spender(对方) 做receiveApproval (允许自己向对方转代币?  包括_extraData?)
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        
        if (approve(_spender, _value)) {
            
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    // 燃烧自己的代币 = = 谁会这么做,钱啊!
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    // 燃烧别人的钱
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }
}
