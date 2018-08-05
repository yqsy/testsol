pragma solidity ^0.4.22;


contract SimpleAuction {
    
    // 最终受益者
    address public beneficiary;
    
    // 拍卖结束的时间戳
    uint public auctionEnd;
    
    // 当前出价最高者
    address public highestBidder;
    
    // 当前最高的出价
    uint public highestBid;
    
    // 需要退回竞拍者和其出价
    mapping(address => uint) public pendingReturns;
    
    // 竞拍是否结束的标志
    bool public ended;
    
    // 出现更高价时引发的事件(event)
    event HighestBidIncreased(address bidder, uint amount);
    
    // 竞拍结束时引发的事件
    event AuctionEnded(address winner, uint amount);
    
    // 初始化竞拍期事件和最终受益者
    constructor (uint _biddingTime, address _beneficiary) public {
        beneficiary = _beneficiary;
        
        auctionEnd = now + _biddingTime;
    }
    
    // 竞拍者出价
    function bid() public payable {
        require(
            now <= auctionEnd,
            "Auction already ended."
        );
        
        // 带价格进来
        require(
            msg.value > highestBid,
            "There already is a higher bid."
        );
        
        if (highestBid != 0) {
            // 回退之前的最高者的钱
            
            pendingReturns[highestBidder] += highestBid;
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }
    
    
    // 出价被别人超过后竞拍者可以执行撤销
    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            
            if (!msg.sender.send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        
        return true;
    }
    
    // 竞拍结束后执行,将最高的出价支付给收益者
    function auctionEnd() public{
        require(now >= auctionEnd, "Auction not yet ended.");
        
        require(!ended, "auctionEnd has already been called.");
        
        ended = true;
        
        emit AuctionEnded(highestBidder, highestBid);
        
        beneficiary.transfer(highestBid);
    }
}


