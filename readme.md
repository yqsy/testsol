<!-- TOC -->

- [1. bollot_navie的缺点](#1-bollot_navie的缺点)
- [2. BlindAuction流程](#2-blindauction流程)
- [3. 权限控制](#3-权限控制)
- [4. erc20](#4-erc20)
- [5. 复杂erc20](#5-复杂erc20)
- [6. 猜数字](#6-猜数字)
- [7. 更复杂erc20](#7-更复杂erc20)
- [8. stages](#8-stages)

<!-- /TOC -->


<a id="markdown-1-bollot_navie的缺点" name="1-bollot_navie的缺点"></a>
# 1. bollot_navie的缺点

* 如果没有投票权的地址调用了vote函数,那么这样的调用也能正常运行
* 投票下标可能会造成数组越界


<a id="markdown-2-blindauction流程" name="2-blindauction流程"></a>
# 2. BlindAuction流程

bid时需要指定一个bytes32类型的参数blindedBid,并支付一定数目的`以太币`,被记为`deposit`:
* `实际出价金额`
* 本次出价的`真伪`
* 出价者生成的一个`秘钥`

三者取散列生成,这个参数有两个作用:
* 隐含本次出价真伪的信息
* 用以揭晓期验证用户所揭晓的实际出价信息是否可信

注意:
无论本次出价行为是`真`还是`假`,deposit`并不代表实际出价的价格数值`,理论上只要大于实际出价数值即可.


揭晓时,出价者调用时需要指定三个数组:
* 每次出价的实际金额
* 出价行为的真伪
* 对应的秘钥

按照出价的先后顺序,依次揭晓每次出价,求 (value,fake,secret)的散列值是否与先前被记录在合约中的bind.blindedBid相等

```
if 预出价 与 实际出价 hash对上 {
    
    if (无伪造 && 声称出价 >= 实际出价) {
        if (实际出价战胜第一名) {
            1. 这个出价的钱(实际)不马上退
            2. 上一个第一名的钱(钱)放到退钱列表
        } else {
            退钱(deposit)
        }
    } else {
        退钱(deposit)
    }

} else {
    钱(deposit)没了
}


```


<a id="markdown-3-权限控制" name="3-权限控制"></a>
# 3. 权限控制

为什么`读`和`写`权限管理不相同呢?
* 对于view函数,使用者可以通过`eth_call`,同样能得到结果,调用者可以使用任意的msg.sender
* 而修改合约状态的函数,必须通过`eth_sendTransaction`调用,对交易签名的验证保证了msg.sender不可伪造

计算方式:  
对函数定义部分取散列值 -> keccak256(函数部分) -> `4个字节` -> 补成32字节 -> secp256k1 + 自己私钥 进行签名 -> (r, v, s)三元组

还原地址方式:  
(r, v, s) + 签名对象(hash (`msg.sig`)) -> 地址

因为r,v,s是使用私钥生成的签名,所以我们可以认为reader的身份是真实的.

这里我还有问题:
* msg.sig暴露
* r,v,s(签名)暴露

岂不是?

再回到https的协议, 证书公开,证书签名公开,岂不是可以使得中间人可以复用啦? 怎么思考这个问题?

<a id="markdown-4-erc20" name="4-erc20"></a>
# 4. erc20

* https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC20/StandardToken.sol

---
* 转账:  需要消耗点燃料费
* 空投: 实现balanceof函数,空投变量

```
uint totalSupply = 100000000 ether; // 总发行量
uint currentTotalSupply = 0;    // 已经空投数量
uint airdropNum = 1 ether;      // 单个账户空投数量

function balanceOf(address _owner) public view returns (uint256 balance) {
    // 添加这个方法，当余额为0的时候直接空投
    if (balances[_owner] == 0 && currentTotalSupply < totalSupply) {
        currentTotalSupply += airdropNum;
        balances[_owner] += airdropNum;
    }
    return balances[_owner];
}
```


<a id="markdown-5-复杂erc20" name="5-复杂erc20"></a>
# 5. 复杂erc20


* https://github.com/eoshackathon/ipfs_development_tutorial/blob/master/doc/complex_erc20.md
* https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC20/StandardToken.sol

<a id="markdown-6-猜数字" name="6-猜数字"></a>
# 6. 猜数字

* https://github.com/merlox/casino-ethereum/blob/master/contracts/Casino.sol

<a id="markdown-7-更复杂erc20" name="7-更复杂erc20"></a>
# 7. 更复杂erc20


* https://github.com/eoshackathon/multi-stage-ico

```bash
cd /mnt/disk1/linux/reference/refer
git clone https://github.com/eoshackathon/multi-stage-ico
```

<a id="markdown-8-stages" name="8-stages"></a>
# 8. stages

* 修改_totalSupply为internal
* 修改_balances为internal
