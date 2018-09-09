pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

library StageTime {
    using SafeMath for uint;

    // 每一期的时间段
    struct StageTime_ {
        // 1. 众筹期
        uint256 saleBeginTime;
        uint256 saleEndTime;

        // 2. 冻结期
        uint256 lockBeginTime;
        uint256 lockEndTime;

        // 3. 投票期
        uint256 voteBeginTime;
        uint256 voteEndTime;
    }

    // 是否在众筹期
    function isInSale(StageTime_ storage stageTime, uint256 curTime) internal view
    returns (bool) {
        return curTime >= stageTime.saleBeginTime && curTime <= stageTime.saleEndTime;
    }

    // 是否在冻结期
    function isInLock(StageTime_ storage stageTime, uint256 curTime) internal view
    returns (bool) {
        return curTime >= stageTime.lockBeginTime && curTime <= stageTime.lockEndTime;
    }

    // 是否在投票期
    function isInVote(StageTime_ storage stageTime, uint256 curTime) internal view
    returns (bool) {
        return curTime >= stageTime.voteBeginTime && curTime <= stageTime.voteEndTime;
    }

    // 本期是否结束
    function isEnd(StageTime_ storage stageTime, uint256 curTime) internel view
    returns (bool) {
        if (isInSale(stageTime, curTime) || isInLock(stageTime, curTime) || isInVote(stageTime, curTime)) {
            return false;
        } else {
            return true;
        }
    }
}
