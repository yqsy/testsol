pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "./StageTime.sol";
import "./Investor.sol";

contract StagesToken is ERC20, ERC20Detailed, ERC20Burnable {
    using SafeMath for uint;

    address public _owner;               // 项目方地址(代币发行者)

    Stage[] public _stages;              // 所有期数
    uint256 public _currentStageIdx;     // 当前期数Idx

    struct Stage {
        uint256 changeRate;              // 本期平台币兑token汇率 (每期可不固定)
        StageTime.StageTime_ stageTime;  // 本期时间段
        Investor.Investor_[] investors;  // 本期投资者数据
    }

    // 切换到下一个众筹期
    function SwitchStage() public {
        uint256 i = _currentStageIdx;
        for (; i < _stages.length; i++) {
            if (StageTime.isInSale(_stages[i].stageTime, now)) {
                break;
            }
        }
        if (i != _currentStageIdx && i < _stages.length) {
            _currentStageIdx = i;
        }
    }

    // 投资者在众筹期投放ABS
    function Invest() public payable {
        require(StageTime.isInSale(_stages[_currentStageIdx].stageTime, now));

        Stage storage curStage = _stages[_currentStageIdx];
        (bool exist, uint256 idx) = Investor.findInIdx(curStage.investors, msg.sender);

        // 1. 增加项目方输出token记录
        uint256 newTokenNum = calcNeedToken(msg.value, curStage.changeRate);
        require(newTokenNum <= _balances[_owner]);
        _balances[_owner] = _balances[_owner].sub(newTokenNum);

        // 2. 增加投资者投资ABS记录
        if (exist) {
            Investor.Investor_ storage curInvestor = curStage.investors[idx];
            curInvestor.investABSNum = curInvestor.investABSNum.add(msg.value);
            curInvestor.ownerTokenNum = curInvestor.ownerTokenNum.add(newTokenNum);
        } else {
            Investor.Investor_ memory investor;
            investor.id = msg.sender;
            investor.investABSNum = msg.value;
            investor.ownerTokenNum = newTokenNum;
            investor.voted = false;
            curStage.investors.push(investor);
        }
    }

    // 投票
    function Vote(bool isAgree) public {
        require(StageTime.isInVote(_stages[_currentStageIdx].stageTime, now));

        // 必须参加过众筹
        Stage storage curStage = _stages[_currentStageIdx];
        (bool exist, uint256 idx) = Investor.findInIdx(curStage.investors, msg.sender);
        require(exist);

        Investor.Investor_ storage curInvestor = curStage.investors[idx];

        // 必须没有投过票
        require(!curInvestor.voted);
        curInvestor.voted = true;


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
