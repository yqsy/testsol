pragma solidity ^0.4.0;

contract Ballot {
    
    // 投票者
    struct Voter {
        uint weight;      // 该投票者投票所占的权重
        bool voted;       // 是否已经投过票
        uint vote;        // 投票对应的提案编号(Index)
        address delegate; // 该投票者投票权的委托对象
    }
    
    // 提案Proposal的数据结构
    struct Proposal {
        bytes32 name;     // 提案的名称
        uint voteCount;   // 该提案目前的票数
    }
    
    // 投票主持人
    address public chairPerson;
    
    // 投票者地址和状态(投票者?)的对应关系
    mapping(address => Voter) public voters;
    
    // 提案的列表
    Proposal[] public proposals;
    
    // 初始化合约,给定提案的列表
    constructor(bytes32[] proposalNames) public {
        // 合约的创建者作为投票主持人
        chairPerson = msg.sender;
        
        voters[chairPerson].weight = 1;
        
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(
                Proposal({
                        name: proposalNames[i],
                        voteCount: 0
                    })
                );
        }
    }
    
    // 只有投票主持人才有给投票者权重的权利 || 没投票 || 权重为0
    // 设置权重为0
    function giveRightToVote(address voter) public {
        require((msg.sender == chairPerson) && !voters[voter].voted && (voters[voter].weight == 0));
        
        
        voters[voter].weight = 1;
    }
    
    function delegate(address to) public {
        // 投票者数据结构
        Voter storage sender = voters[msg.sender];
        
        // 没有投票过
        require(!sender.voted);
        
        
        // 不能把授权给自己
        require(to != msg.sender);
        
        // 将to执行到最终委托人
        while(voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            
            // 单向,无环
            require(to != msg.sender);
        }
        
        // 把委托者的代理委托人改为最终委托人
        sender.voted = true;
        sender.delegate = to;
        
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {
            // 最终代理人已经投票了,直接增加该提案的投票次数
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            // 最终代理人没有投票,给最终代理人加上权重
            delegate_.weight += sender.weight;
        }
    }
    
    
    // 根据提案列表编号进行投票
    function vote(uint proposal) public {
        // 投票者数据结构
        Voter storage sender = voters[msg.sender];
        
        require(!sender.voted);
        
        sender.voted = true;
        
        // 投票者投票项
        sender.vote = proposal;
        
        // 增加该提案的投票次数
        proposals[proposal].voteCount += sender.weight;
    }
    
    // 根据proposals里的票数统计计算出票数最多的提案编号
    function winningProposal() public view  returns (uint winningProposal_) {
        uint winningVoteCount = 0;
        
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                
                // 最多的编号
                winningProposal_ = p;
            }
        }
    }
    
    // 票数最多的名称
    function winnerName() public view returns (bytes32 winnerName_) {
        winnerName_ = proposals[winningProposal()].name;
    }
    
}
