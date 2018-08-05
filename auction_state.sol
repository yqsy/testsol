pragma solidity ^0.4.23;

contract AuctionStateMachine {
    
    enum Stages {
        AcceptingBlindedBids, // 竞拍期
        RevealBids,           // 揭晓期
        PayBeneficiary,       // 受益者收款期
        Finished              // 竞拍结束
    }
    
    // 当前状态
    Stages public stage = Stages.AcceptingBlindedBids;
    
    // 合约创建的时间戳
    uint public creationTime = now;
    
    // 拍卖受益者
    address public beneficiary;
    
    // 函数修改器,要求在指定的状态才能够执行
    modifier atStage(Stages _stage) {
        require(stage == _stage);
        _;
    }
    
    // 函数修改器,在函数执行结束后,将合约状态修改到下一状态
    modifier transitionNext() {
        _;
        
    }
    
    // 内置函数,用来更新合约的状态到下个状态
    function nextStage() internal {
        stage = Stages(uint(stage) + 1);
    }
    
    // 函数修改器,在函数执行前,根据当前时间戳升级合约状态
    modifier timedTransitions() {
        if (stage == Stages.AcceptingBlindedBids && now >= creationTime + 10 days) {
            nextStage();
        }
        
        if (stage == Stages.RevealBids && now >= creationTime + 12 days) {
            nextStage();
        }
        _;
    }
    
    
    // 1.根据时间改变状态  2.判断当前状态是否能bid
    function bid() public payable timedTransitions atStage(Stages.AcceptingBlindedBids) {
        
    }
    
    // 1.根据时间改变状态  2.判断当前状态是否能reveal
    function reveal() public timedTransitions atStage(Stages.RevealBids) {
        
    }
    
    // 1.根据时间改变状态  2.判断当前状态是否能auctionEnd
    function auctionEnd() public timedTransitions atStage(Stages.PayBeneficiary) transitionNext {
        
    }
    
}