pragma solidity ^0.4.23;


contract AccessControl
{
    // 合约中存储的一个映射,对它的访问进行了权限的控制
    mapping (bytes32 => string) secretsMap;
    
    // 管理员账户数组,可以添加管理员,Readers和Writers
    address[] admins;
    
    // 可以读secretsMap的账户白名单
    address[] allowedReaders;
    
    // 可以写secretsMap的账户白名单
    address[] allowedWriters;
    
    // 初始化管理账户数组
    
    constructor (address[] initialAdmins) public {
        admins = initialAdmins;
    }
    
    // 判断用户数组是否包含用户
    function isAllowed(address user, address[] allowedUsers)  private pure returns (bool) {
        for (uint i = 0; i < allowedUsers.length; i++) {
            if (allowedUsers[i] == user) {
                return true;
            }
        }
        return false;
    }
    
    // 函数修改器,根据传入的签名(v,r,s)判断是否有读权限
    modifier onlyAllowedReaders(uint8 v, bytes32 r, bytes32 s) {
        bytes32 hash = msg.sig;
        
        address reader = ecrecover(hash,v,r,s);
        require(isAllowed(reader, allowedReaders));
        _;
    }
    
    
    // 函数修改器,判断调用者(msg.sender)是否有写权限
    modifier onlyAllowedWriters {
        require(isAllowed(msg.sender, allowedWriters));
        _;
    }
    
    
    // 函数修改器,判断调用者(msg.sender)是否是管理员账户
    modifier onlyAdmins {
        require(isAllowed(msg.sender, admins));
        _;
    }
    
    // 读函数,返回指定key对应的字符串
    // 同时需要传入到"函数名"(msg.sig)的签名(v,s,r)
    function read(uint8 v, bytes32 r, bytes32 s, bytes24 key) onlyAllowedReaders(v,r,s) public view returns(string){
        return secretsMap[key];
    }
    
    
    // 写函数
    function write(bytes32 key, string value) onlyAllowedWriters public {
        secretsMap[key] = value;
    }
    
    // 添加可读用户,只有管理员可以操作
    function addAuthorizedReader(address a) onlyAdmins public {
        allowedReaders.push(a);    
    }
    
    // 添加可写用户,只有管理员可以操作
    function addAuthorizedWriter(address a) onlyAdmins public {
        allowedWriters.push(a);    
    }
    
    // 添加管理员,只有管理员可以操作
        function addAdmin(address a) onlyAdmins public {
        admins.push(a);    
    }
}