pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

library Investor {
    using SafeMath for uint;

    enum State {UnVoted, Agree, Oppose}

    struct Investor_ {
        address id;             // 投资者地址
        uint256 investABSNum;   // 投资者投资ABS数量
        uint256 ownerTokenNum;  // 项目方释放Token数量
        State state;            // 状态
    }

    // 寻找投资者是否存在
    function findInIdx(Investor_[] storage investors, address id) internal view
    returns (bool, uint256) {
        for (uint256 i = 0; i < investors.length; i++) {
            if (investors[i].id == id) {
                return (true, i);
            }
        }
        return (false, 0);
    }

    // 创建新的投资者
    function newInvestor(address _id, uint256 _investABSNum, uint256 _ownerTokenNum) internal pure
    returns (Investor_) {
        Investor.Investor_ memory investor;
        investor.id = _id;
        investor.investABSNum = _investABSNum;
        investor.ownerTokenNum = _ownerTokenNum;

        investor.state = State.UnVoted;
        return investor;
    }

    function isVoted(Investor_ storage investor) internal view
    returns (bool) {
        return investor.state != State.UnVoted;
    }

    function isAgreed(Investor_ storage investor) internal view
    returns (bool) {
        return investor.state == State.Agree;
    }

    function isOppose(Investor_ storage investor) internal view
    returns (bool) {
        return investor.state == State.Oppose;
    }

    function vote(Investor_ storage investor, bool agree) internal {
        if (agree) {
            investor.state = State.Agree;
        } else {
            investor.state = State.Oppose;
        }
    }

    // 是否达到同意比例
    function isVoteAgreeAchieveTarget(Investor_[] storage investors, uint256 targetAgreeRate) internal view
    returns (bool) {
        uint256 agreeVotes = 0;
        for (uint256 i = 0; i < investors.length; i++) {
            if (isAgreed(investors[i])) {
                agreeVotes++;
            }
        }
        // 万分数
        uint256 agreeRate = agreeVotes.mul(10000).div(investors.length);
        return agreeRate >= targetAgreeRate.mul(100);
    }
}
