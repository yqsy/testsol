pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";


contract StagesToken is ERC20, ERC20Detailed, ERC20Burnable {
    using SafeMath for uint;

    address public _owner;               // 项目方地址(代币发行者)
    uint256 public _targetTotalAmount;   // 项目方预计要筹集的ABS数量

    Stage[] public _stages;              // 所有期数
    uint256 public _currentStageIdx;     // 当前期数Idx


    // 每一期的时间段
    struct StageTime {
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
    function isInSale(StageTime storage stageTime, uint256 curTime) private view
    returns (bool) {
        return curTime >= stageTime.saleBeginTime && curTime <= stageTime.saleEndTime;
    }

    // 是否在冻结期
    function isInLock(StageTime storage stageTime, uint256 curTime) private view
    returns (bool) {
        return curTime >= stageTime.lockBeginTime && curTime <= stageTime.lockEndTime;
    }

    // 是否在投票期
    function isInVote(StageTime storage stageTime, uint256 curTime) private view
    returns (bool) {
        return curTime >= stageTime.voteBeginTime && curTime <= stageTime.voteEndTime;
    }

    struct Investor {
        address id;                     // 投资者地址
        uint256 investABS;              // 投资者投资的ABS数量
        uint256 ownerToken;             // 项目方Token
        bool agree;                     // 是否同意
        bool voted;                     // 是否投过票
    }

    // 寻找投资者是否存在
    function findInvestorIdx(Investor[] storage investors, address id) private view
    returns (bool, uint256){
        for (uint256 i = 0; i < investors.length; i++) {
            if (investors[i].id == id) {
                return (true, i);
            }
        }
        return (false, 0);
    }

    struct Stage {
        uint256 changeRate;             // 本期平台币兑token汇率 (每期可不固定)
        StageTime stageTime;            // 本期时间段
        Investor[] investors;           // 本期投资者数据
    }

    // 切换到下一个众筹期
    function SwitchStage() public {
        uint256 i = _currentStageIdx;
        for (; i < _stages.length; i++) {
            if (isInSale(_stages[i].stageTime, now)) {
                break;
            }
        }
        if (i != _currentStageIdx && i < _stages.length) {
            _currentStageIdx = i;
        }
    }

    // 投资者在众筹期投放ABS
    function Invest() public payable {
        require(isInSale(_stages[_currentStageIdx].stageTime, now));

        Stage storage curStage = _stages[_currentStageIdx];
        (bool exist, uint256 idx) = findInvestorIdx(curStage.investors, msg.sender);

        // 1. 增加项目方输出token记录
        uint256 ownerToken = calcNeedToken(msg.value, curStage.changeRate);
        require(ownerToken <= _balances[_owner]);

        // 2. 增加投资者投资ABS记录
        if (exist) {
            Investor storage curInvestor = curStage.investors[idx];
            curInvestor.investABS = curInvestor.investABS.add(msg.value);
            curInvestor.ownerToken = curInvestor.ownerToken.add(ownerToken);
        } else {
            Investor memory investor;
            investor.id = msg.sender;
            investor.investABS = msg.value;
            investor.ownerToken = ownerToken;
            investor.agree = false;
            investor.voted = false;
            curStage.investors.push(investor);
        }
    }

    // 投票
    function Vote(bool isAgree) public {
        require(isInVote(_stages[_currentStageIdx].stageTime, now));


    }

    // 投资者领取阶段众筹的所有应得的token
    function WithdrawToken() public {

    }

    // 项目方领取阶段众筹的所有应得的ABS
    function WithdrawABS() public {

    }

    // ABS -> token (汇率相转)
    function calcNeedToken(uint256 ABSNum, uint256 changeRate) private
    returns (uint256){
        return ABSNum.mul(changeRate);
    }

    constructor (
        string name,
        string symbol,
        uint8 decimals,
        uint256 totalSupply
    )
    ERC20Burnable()
    ERC20Detailed(name, symbol, decimals)
    ERC20()
    public {
        _totalSupply = totalSupply * (10 ** uint256(decimals));

        _owner = msg.sender;
        _balances[_owner] = _totalSupply;
    }
}
