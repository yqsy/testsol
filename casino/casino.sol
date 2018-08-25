pragma solidity ^0.4.20;

contract Casino {
    address public owner;
        
    // 范围
    uint8 private decimals = 18;
    uint256 public minimumBet = 1 * 10**15;         // 最小下注金额  1e15
    uint256 constant public maxAmountBets = 2;       // 最多下注人数
    
    uint256 public totalBet;                // 总下注金额
    uint256 public numberOfBets;            // 已下注人数
    
    
    uint256 public numberOfGenerated; 
    uint256 public winnerEtherAmount;
    
    struct Player {
        uint256 amountBet;     // 下注金额
        uint256 numberSelected; // 下注数字
    }
    
    mapping(address => Player) public playerInfo; // 下注列表
    address[] public players;  // 玩家列表
    
    constructor() public {
        owner = msg.sender;
    }
    
    function bet(uint8 numberSelected) public payable {
        require(!checkPlayerExists(msg.sender));              // msg.sender
        require(msg.value >= minimumBet);                     // msg.value
        require(numberSelected >= 1 && numberSelected <= 10); // numberSelected
        
        require(numberOfBets <= maxAmountBets); // 最多下注人数
        
        totalBet += msg.value; // 总下注金额
        numberOfBets++;        // 已下注人数
        
        playerInfo[msg.sender].amountBet = msg.value;           // 下注金额
        playerInfo[msg.sender].numberSelected = numberSelected; // 下注数字
        players.push(msg.sender);                               // 玩家列表
        
        if (numberOfBets >= maxAmountBets) {
            generateNumberWinner();
        }
    }
    
    
    function kill() public {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }
    
    function checkPlayerExists(address player) private constant returns(bool) {
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == player) {
                return true;
            }
        }
        return false;
    }
    
    function generateNumberWinner() private {
        numberOfGenerated = block.number % 10 + 1;
        
        distributePrizes(uint8(numberOfGenerated));
    }
    
    function distributePrizes(uint8 numberWinner) private {
        address[maxAmountBets] memory winners;
        
        bool hasWinner = false;
        
        uint256 count = 0;
        
        for (uint256 i = 0; i < players.length; i++) {
            address playerAddress = players[i];
            if (playerInfo[playerAddress].numberSelected == numberWinner) {
                winners[count] = playerAddress;
                count++;
            }
            delete playerInfo[playerAddress];
        }
        
        if (count == 0) {
            count = maxAmountBets;
        } else {
            hasWinner = true;
        }
        
        winnerEtherAmount = totalBet * 95 /100 / count;
        
        for (uint256 j = 0; j < count; j++) {
            if (hasWinner) {
                if (winners[j] != address(0)) {
                    winners[j].transfer(winnerEtherAmount);
                }
            } else {
                if (players[j] != address(0)) {
                    players[j].transfer(winnerEtherAmount);
                }
            }
        }
        
        players.length = 0;  // 玩家列表
        
        totalBet = 0;       // 总下注金额
        numberOfBets = 0;   // 已下注人数
    }
    
}
