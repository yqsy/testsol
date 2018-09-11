pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "./StageTime.sol";
import "./Investor.sol";

contract StagesToken is ERC20, ERC20Detailed, ERC20Burnable {
    using SafeMath for uint;

    address public _item;                // 项目方地址(代币发行者)

    Stage[] public _stages;              // 所有期数
    uint256 public _currentStageIdx;     // 当前期数Idx

    struct Stage {
        uint256 changeRate;              // 本期平台币兑token汇率 (每期可不固定), 例如: 1:1000,一个ABS兑换1000个token
        uint256 targetAgreeRate;         // 本期需要达成的agree比例, 例如:0-100
        StageTime.StageTime_ stageTime;  // 本期时间段
        Investor.Investor_[] investors;  // 本期投资者数据
    }

    modifier onlyInvestor() {
        require(msg.sender != _item);
        _;
    }

    modifier onlyItem() {
        require(msg.sender == _item);
        _;
    }

    modifier onlyInSaleTime() {
        require(StageTime.isInSale(_stages[_currentStageIdx].stageTime, now));
        _;
    }

    modifier onlyInVoteTime() {
        require(StageTime.isInVote(_stages[_currentStageIdx].stageTime, now));
        _;
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

    // 众筹期: 投资者投资ABS
    function Invest() public payable onlyInvestor onlyInSaleTime {
        Stage storage curStage = _stages[_currentStageIdx];
        (bool exist, uint256 idx) = Investor.findInIdx(curStage.investors, msg.sender);

        // 1. A. 项目方token减少 B. 合同token增加
        uint256 rateTokenNum = calcRateToken(msg.value, curStage.changeRate);
        require(rateTokenNum <= _balances[_item]);
        _balances[_item] = _balances[_item].sub(rateTokenNum);

        // 2. A. 投资者ABS减少 B. 合同ABS增加
        if (exist) {
            Investor.Investor_ storage curInvestor = curStage.investors[idx];
            Investor.appendInvest(curInvestor, msg.value, rateTokenNum);
        } else {
            Investor.Investor_ memory investor = Investor.newInvestor(msg.sender, msg.value, rateTokenNum);
            curStage.investors.push(investor);
        }
    }

    // 投票期: 投资者投票 0=不同意,其他=同意
    function Vote(uint256 isAgree) public onlyInvestor onlyInVoteTime {
        Stage storage curStage = _stages[_currentStageIdx];

        // 必须参加过众筹
        (bool exist, uint256 idx) = Investor.findInIdx(curStage.investors, msg.sender);
        require(exist);

        Investor.Investor_ storage curInvestor = curStage.investors[idx];

        // 必须没有投过票
        require(!Investor.isVoted(curInvestor));

        if (isAgree == 0) {
            Investor.vote(curInvestor, false);
        } else {
            Investor.vote(curInvestor, true);
        }
    }

    // 投资者: (投票成功) 获取token
    function InvestorWithdrawToken() public onlyInvestor {
        for (uint256 i = 0; i < _stages.length; i++) {
            if (Investor.isVoteAgreeAchieveTarget(_stages[i].investors, _stages[i].targetAgreeRate)) {
                Investor.investorWithdrawToken(_stages[i].investors, addSendersToken);
            }
        }
    }

    // 投资者: (投票失败) 获取ABS
    function InvestorWithdrawAbs() public onlyInvestor {
        for (uint256 i = 0; i < _stages.length; i++) {
            if (!Investor.isVoteAgreeAchieveTarget(_stages[i].investors, _stages[i].targetAgreeRate)) {
                Investor.investorWithdrawABS(_stages[i].investors, addSendersABS);
            }
        }
    }

    // 项目方: (投票成功) 获取ABS
    function ItemWithdrawABS() public onlyItem {
        for (uint256 i = 0; i < _stages.length; i++) {
            if (Investor.isVoteAgreeAchieveTarget(_stages[i].investors, _stages[i].targetAgreeRate)) {
                Investor.itemWithdrawABS(_stages[i].investors, addSendersABS);
            }
        }
    }

    // 项目方: (投票失败) 获取token
    function ItemWithdrawToken() public onlyItem {
        for (uint256 i = 0; i < _stages.length; i++) {
            if (!Investor.isVoteAgreeAchieveTarget(_stages[i].investors, _stages[i].targetAgreeRate)) {
                Investor.itemWithdrawToken(_stages[i].investors, addSendersToken);
            }
        }
    }

    // ABS -> token (汇率相转)
    function calcRateToken(uint256 ABSNum, uint256 changeRate) private pure
    returns (uint256){
        return ABSNum.mul(changeRate);
    }

    // 增加发送者token
    function addSendersToken(uint256 tokenNum) private {
        _balances[msg.sender] = _balances[msg.sender].add(tokenNum);
    }

    // 增加发送者ABS
    function addSendersABS(uint256 ABSNum) private {
        msg.sender.transfer(ABSNum);
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

        _item = msg.sender;
        _balances[_item] = _totalSupply;
    }
}
