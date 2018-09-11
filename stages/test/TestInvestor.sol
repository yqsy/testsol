pragma solidity ^0.4.24;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/Investor.sol";

contract TestInvestor {

    Investor.Investor_[] investors;

    function testInvestorAgree() public {
        // TODO
//        investors = new Investor.Investor_[](0);
//
//
//        Investor.Investor_ memory investor = Investor.newInvestor(msg.sender, 100, 1000);
//
//        for (uint256 k = 0; k < 10; k++) {
//            investors.push(investor);
//        }
//
//        for (uint256 j = 0; j < 6; j++) {
//            Investor.vote(investors[j], true);
//        }
//
//        Assert.equal(Investor.isVoteAgreeAchieveTarget(investors, 59), true, "");
//        Assert.equal(Investor.isVoteAgreeAchieveTarget(investors, 60), true, "");
    }

}
