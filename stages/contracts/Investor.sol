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

    // 追加投资
    function appendInvestor(Investor_ storage investor, uint256 investABSNum, uint256 itemTokenNum) internal {
        investor.investABSNum = investor.investABSNum.add(investABSNum);
        investor.itemTokenNum = investor.itemTokenNum.add(itemTokenNum);
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

    // (投票成功): 投资者领取众筹阶段的所有应得到的token,并减去合同记录
    function investorWithdrawToken(Investor_[] storage investors, function (address/*id*/, uint256/*tokenNum*/) addInvestorBalance) internal  {
        for (uint256 i = 0; i < investors.length; i++) {
            addInvestorBalance(investors[i].id, investors[i].itemTokenNum);
            investors[i].itemTokenNum = 0;
        }
    }

    // (投票成功): 项目方领取众筹阶段的所有应得的ABS,并减去合同记录
    function itemWithdrawABS(Investor_[] storage investors, function (uint256/*ABSNum*/) addItemABS) internal  {
        for (uint256 i = 0; i < investors.length; i++) {
            addItemABS(investors[i].investABSNum);
            investors[i].investABSNum = 0;
        }
    }

    // (投票失败): 投资者领取众筹阶段付出的ABS,并减去合同记录
    function investorWithdrawABS(Investor_[] storage investors, function (uint256/*ABSNum*/) addInvestorABS) internal {
        for (uint256 i = 0; i < investors.length; i++) {
            addInvestorABS(investors[i].investABSNum);
            investors[i].investABSNum = 0;
        }
    }

    // (投票失败): 项目方领取众筹阶段付出的token,并减去合同记录
    function itemWithdrawToken(Investor_[] storage investors, function (uint256/*tokenNum*/) addItemBalance) internal {
        for (uint256 i = 0; i < investors.length; i++) {
            addItemBalance(investors[i].itemTokenNum);
            investors[i].itemTokenNum = 0;
        }
    }
}
