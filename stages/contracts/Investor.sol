pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

library Investor {
    using SafeMath for uint;

    enum State {UnVoted, Agree, Oppose}

    struct Investor_ {
        address id;             // 投资者地址
        uint256 investABSNum;   // 投资者投资ABS数量
        uint256 itemTokenNum;   // 项目方释放Token数量
        State state;            // 状态
    }

    // 创建新投资者
    function newInvestor(address _id, uint256 _investABSNum, uint256 _itemTokenNum) internal pure
    returns (Investor_) {
        Investor.Investor_ memory investor;
        investor.id = _id;
        investor.investABSNum = _investABSNum;
        investor.itemTokenNum = _itemTokenNum;
        investor.state = State.UnVoted;
        return investor;
    }

    // 追加投资
    function appendInvest(Investor_ storage investor, uint256 investABSNum, uint256 itemTokenNum) internal {
        investor.investABSNum = investor.investABSNum.add(investABSNum);
        investor.itemTokenNum = investor.itemTokenNum.add(itemTokenNum);
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

    // 是否已投票
    function isVoted(Investor_ storage investor) internal view
    returns (bool) {
        return investor.state != State.UnVoted;
    }

    // 是否同意
    function isAgreed(Investor_ storage investor) internal view
    returns (bool) {
        return investor.state == State.Agree;
    }

    // 投票
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

    // 投资者: (投票成功) 获取token
    function investorWithdrawToken(Investor_[] storage investors, address id, function (uint256) addSendersToken) internal {
        for (uint256 i = 0; i < investors.length; i++) {
            if (investors[i].id == id) {
                addSendersToken(investors[i].itemTokenNum);
                investors[i].itemTokenNum = 0;
            }
        }
    }

    // 投资者: (投票失败) 获取ABS
    function investorWithdrawABS(Investor_[] storage investors, address id, function (uint256) addSendersABS) internal {
        for (uint256 i = 0; i < investors.length; i++) {
            if (investors[i].id == id) {
                addSendersABS(investors[i].investABSNum);
                investors[i].investABSNum = 0;
            }
        }
    }

    // 项目方: (投票成功) 获取ABS
    function itemWithdrawABS(Investor_[] storage investors, function (uint256) addSendersABS) internal {
        for (uint256 i = 0; i < investors.length; i++) {
            addSendersABS(investors[i].investABSNum);
            investors[i].investABSNum = 0;
        }
    }

    // 项目方: (投票失败) 获取token
    function itemWithdrawToken(Investor_[] storage investors, function (uint256) addSendersToken) internal {
        for (uint256 i = 0; i < investors.length; i++) {
            addSendersToken(investors[i].itemTokenNum);
            investors[i].itemTokenNum = 0;
        }
    }
}
