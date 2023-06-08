//SPDX-License-Identifier:MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

//import "./VotingContract.sol";

//using BIT token as a means of payment

//DEPLOYED ON MANTLE TESTNET

contract Betting is Ownable {
    //how to calculate the stake in each betting
    //the user will enter the amount they wanna bet in BIT token
    //place a bet

    //Bettors struct
    struct Bettors {
        address bettor;
        uint256 amountBet;
    }
    event bettorsEvent(address indexed bettor, uint256 amount);
    bool public success;

    Bettors[] public bettorsArray;
    mapping(address => uint) public numBetsAddress;
    mapping(address => Bettors) public mapBettors;
    struct Rappers {
        string name;
        uint256 amountBetOn;
        address payable[] rapperBettors;
    }
    //array of rappers
    Rappers[] public rappersArray;

    event RappersEvent(string indexed name);

    function setRapper(string memory _name) external onlyOwner {
        address payable[] memory rap;
        rappersArray.push(Rappers(_name, 0, rap));
        emit RappersEvent(_name);
    }

    function betOnRapper(uint256 _rapperIndex, uint256 amount) public payable {
        //The amount entered from the frontend will be the msg.value in the write
        //method, when populating it with the necessary parameters
        require(msg.value >= amount * 10**18, "insufficient balance");

        bettorsArray.push(Bettors({bettor: msg.sender, amountBet: amount}));
        mapBettors[msg.sender] = Bettors({
            bettor: msg.sender,
            amountBet: amount
        });
        rappersArray[_rapperIndex].amountBetOn += amount;
        rappersArray[_rapperIndex].rapperBettors.push(payable(msg.sender));
        numBetsAddress[msg.sender]++;

        emit bettorsEvent(msg.sender, amount);
    }

    function rapperWinFundDistribution(uint _rapperIndex) internal onlyOwner {
        uint div;
        address payable bettorsAddress;
        uint256 userBet;
        uint256 winnerBet;
        uint256 loserBet;
        if (_rapperIndex == 0) {
            for (
                uint256 i = 0;
                i < rappersArray[_rapperIndex].rapperBettors.length;
                i++
            ) {
                bettorsAddress = rappersArray[_rapperIndex].rapperBettors[i];
                userBet = mapBettors[bettorsAddress].amountBet;
                winnerBet = rappersArray[_rapperIndex].amountBetOn;
                loserBet = rappersArray[1].amountBetOn;

                div =
                    (userBet * (10000 + ((loserBet * 10000) / winnerBet))) /
                    10000;
                (success, ) = bettorsAddress.call{value: div * 10**18}("");
                require(success, "transaction reverteds");
            }
        } else if (_rapperIndex == 1) {
            for (
                uint256 i = 0;
                i < rappersArray[_rapperIndex].rapperBettors.length;
                i++
            ) {
                bettorsAddress = rappersArray[_rapperIndex].rapperBettors[i];
                userBet = mapBettors[bettorsAddress].amountBet;
                winnerBet = rappersArray[1].amountBetOn;
                loserBet = rappersArray[0].amountBetOn;

                div =
                    (userBet * (10000 + ((loserBet * 10000) / winnerBet))) /
                    10000;
                (success, ) = bettorsAddress.call{value: div * 10**18}("");
                require(success, "transaction revertedss");
            }
        }

        rappersArray[0].amountBetOn = 0;
        rappersArray[1].amountBetOn = 0;
    }

    function rapping(uint _rapperIndex) public view returns (address payable) {
        return rappersArray[_rapperIndex].rapperBettors[_rapperIndex];
    }
}
