pragma solidity ^0.4.23;

contract BlindAuction {
    
    // 出价的数据结构
    struct Bid {
        bytes32 blindedBid; // 加密后的出价的真伪
        uint deposit;       // 出价时所付的金额
    }
    
    // 拍卖的收益者
    address public beneficiary;
    
    // 竞拍结束的时间戳
    uint public biddingEnd;
    
    // 揭晓期结束的时间戳
    uint public revealEnd;
    
    // 合约是否完全执行结束
    bool public ended;
    
    
    // 各个出价者和其屡次出价的映射
    mapping(address => Bid[]) public bids;
    
    // 在揭晓每次出价后,当前出价最高者
    address public highestBidder;
    
    // 在揭晓每次出价后,当前的最高出价
    uint public highestBid;
    
    // 需要退回竞拍者的地址和钱款
    mapping(address => uint) pendingReturns;
    
    event AuctionEnded(address winner, uint highestBid);
    
    
    // 函数修改器,用来限制函数的执行时间在_time时间戳之前
    modifier onlyBefore(uint _time) { require(now < _time); _; }
    
    //函数修改器,用来限制函数的执行时间在_time时间戳之后
    modifier onlyAfter(uint _time) { require(now > _time); _; }
    
    
    constructor(uint _biddingTime, uint _revealTime, address _beneficiary) public {
        
        beneficiary = _beneficiary;
        biddingEnd = now + _biddingTime;
        revealEnd = biddingEnd + _revealTime;
    }
    
    // 出价函数,需要加密后的盲拍价格作为参数
    function bid(bytes32 _blindedBid) public payable 
        onlyBefore(biddingEnd) {
            
        bids[msg.sender].push(
            Bid({
                blindedBid: _blindedBid,
                deposit: msg.value
                })
            );
    }
    

    // 揭晓函数,用来揭晓每次出价的"真伪", 只能在竞拍期结束之后,揭晓期结束之前
    function reveal(uint[] _values, bool[] _fake, bytes32[] _secret) public 
        onlyAfter(biddingEnd) 
        onlyBefore(revealEnd) {
        
        uint length = bids[msg.sender].length;
        
        require(_values.length == length);
        require(_fake.length == length);
        require(_secret.length == length);
        
        uint refund;
        
        for (uint i =0; i < length; i++) {
            
            Bid storage bid_ = bids[msg.sender][i];
            
            (uint value, bool fake, bytes32 secret) = (_values[i], _fake[i], _secret[i]);
            
            if (bid_.blindedBid != keccak256(abi.encodePacked( value, fake, secret))) {
                continue;
            }
            
            refund += bid_.deposit;
            
            // 声称出价  >= 实际出价
            if (!fake && bid_.deposit >= value) {
                if (placeBid(msg.sender, value)) {
                    // 出价生效了
                    refund -= value;
                }
            }
            bid_.blindedBid = bytes32(0);
        }
        
        // 退还剩余的
        msg.sender.transfer(refund);
    }
    
        // 更新当前的最高出价,内置函数,被reveal调用
    function placeBid(address bidder, uint value) internal returns(bool success) {
        if (value <= highestBid) {
            return false;
        }
        
        if (highestBidder != 0) {
            pendingReturns[highestBidder] += highestBid;
        }
        
        highestBid = value;
        highestBidder = bidder;
        return true;
    }
    
    
    // 退款函数
    function withdraw() public {
        uint amount = pendingReturns[msg.sender];
        
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            msg.sender.transfer(amount);
        }
    }
    
    // 竞拍结束后执行,将最高的出价支付给收益者
    function auctionEnd() public onlyAfter(revealEnd) {
        require(!ended);
        
        emit AuctionEnded(highestBidder, highestBid);
        
        ended = true;
        
        beneficiary.transfer(highestBid);
    }
    
}