pragma solidity ^0.4.24;

library Investor {

    enum State {UnVoted, Agree, Oppose}

    struct Investor_ {
        address id;             // 投资者地址
        uint256 investABSNum;   // 投资者投资的ABS数量
        uint256 ownerTokenNum;  // 项目方Token数量
        State state;            // 状态
        bool voted;             // 是否投过票
    }

    // 寻找投资者是否存在
    function findInIdx(Investor_[] storage investors, address id) internal view
    returns (bool, uint256){
        for (uint256 i = 0; i < investors.length; i++) {
            if (investors[i].id == id) {
                return (true, i);
            }
        }
        return (false, 0);
    }

    function newInvestor() internal returns (Investor_){
        Investor.Investor_ memory investor;


        return investor;
    }
}
