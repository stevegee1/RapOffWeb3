//SPDX-License-Identifier:MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import "./Betting.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//THIS IS THE OFFICIAL VOTING CONTRACT OF RAPOFFWEB3 : Voting, Chainlink VRF
//SEPOLIA TESTNET

contract VotingContract is Betting, VRFConsumerBaseV2 {
    //Interface necessary for chainlink VRF
    VRFCoordinatorV2Interface COORDINATOR;

    //counter logic from openzeppelin
    using Counters for Counters.Counter;
    Counters.Counter public _voterId;
    Counters.Counter public _rapperId;

    //array of addresses that voted for each Rapper
    address[] public votedForRapper;

    //Struct for Rapper
    struct Rapper {
        string name;
        uint256 rapperID;
        string image;
        string ipfs;
        address _address;
        uint256 voteCount;
        address[] rapperVotersArray;
    }

    //Struct
    //declare Rapper event
    event rapperEvent(
        uint256 indexed rapperID,
        string name,
        string image,
        string ipfs,
        address _address,
        uint256 voteCount
    );
    //create winner struct
    Rapper public Winner;

    //necessary initialization for chainlink VRF
    address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    // link_token_contract = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    bytes32 keyHash =
        0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    uint32 callbackGasLimit = 100000;

    uint16 requestConfirmations = 3;

    //requesting 10 random values from chainlink VRF to reward 10 random voters of the winner
    uint32 numWords = 3;

    // Storage parameters
    uint256[] public s_randomWords;
    uint256 public s_requestId;
    uint64 public s_subscriptionId;

    //create the array of addresses of all rappers
    address[] public rapperAddresses;

    //map the uniqueID of the rapper to its struct
    mapping(address => Rapper) public rapperMapping;

    ///////END OF RAPPER DATA/////////

    address[] public voterAddresses; //maybe separate this to different arrays so as to use it for the betting platform

    //map the address of the rapper to its struct
    mapping(address => Voter) public voterMapping;

    //STRUCT VOTERS
    struct Voter {
        string voter_name;
        uint256 voterID;
        bool voter_Voted;
        address voter_Address;
        string voter_Image;
        string voter_ipfs;
        address voter_votedFor;
    }
    event VoterEvent(
        uint256 indexed voterID,
        string voter_name,
        bool voter_Voted,
        address voter_Address,
        string voter_Image,
        string voter_ipfs,
        address voter_voteFor
    );

    //declaring the contract constructor
    constructor(uint64 subscriptionId)
        VRFConsumerBaseV2(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625)
    {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(link_token_contract);

        s_subscriptionId = subscriptionId;

        //Create a new subscription when you deploy the contract.
        //createNewSubscription();
    }

    //initialize rapper
    function setRapper(
        address _address,
        string memory _image,
        string memory _ipfs,
        string memory _name
    ) public onlyOwner {
        //using counter library
        address[] memory addr;
        _rapperId.increment();
        uint256 idNumber = _rapperId.current();

        //map rapper address to its struct
        // Rapper storage rapper= rapperMapping[_address];?

        rapperMapping[_address] = Rapper(
            _name,
            idNumber,
            _image,
            _ipfs,
            _address,
            0,
            addr
        );
        rapperAddresses.push(_address);
        votedForRapper = rapperMapping[_address].rapperVotersArray;
        emit rapperEvent(idNumber, _name, _image, _ipfs, _address, 0);
    }

    //function to return the number of rappers
    function getTheNumberOfRappers() public view returns (uint256) {
        return rapperAddresses.length;
    }

    //function to get rapper details
    function getA_RapperData(address _rapperID)
        public
        view
        returns (
            uint256,
            string memory,
            string memory,
            string memory,
            address,
            uint256
        )
    {
        Rapper storage rapper = rapperMapping[_rapperID];
        return (
            rapper.rapperID,
            rapper.name,
            rapper.image,
            rapper.ipfs,
            rapper._address,
            rapper.voteCount
        );
    }

    //making vote function a public, payable function, 3 LINK worth to vote
    function voteNow(
        address _rapperID,
        string memory _name,
        string memory _image,
        string memory _ipfs,
        uint256 amount
    ) public {
        require(amount >= 1 * 10**15, "minimum required LINK token is 3");

        //the user must approve the contract to successfully call transferFrom
        LINKTOKEN.transferFrom(msg.sender, address(this), amount);

        require(
            !voterMapping[msg.sender].voter_Voted,
            "sorry, you can only vote once"
        );

        //increment the vote for the chosen rapperID
        rapperMapping[_rapperID].voteCount += 1;
        rapperMapping[_rapperID].rapperVotersArray.push(msg.sender);
        //increment voter_ID
        _voterId.increment();
        uint256 voterIDNumber = _voterId.current();

        //mapped the voter address to its struct

        voterMapping[msg.sender] = Voter(
            _name,
            voterIDNumber,
            true,
            msg.sender,
            _image,
            _ipfs,
            _rapperID
        );
        voterAddresses.push(msg.sender);

        //emit voter event
        emit VoterEvent(
            voterIDNumber,
            _name,
            true,
            msg.sender,
            _image,
            _ipfs,
            _rapperID
        );
    }

    // Assumes the subscription is funded sufficiently.
    function requestRandomWords()
        external
        onlyOwner
        returns (uint256 requestId)
    {
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        return requestId;
    }

    //the chainlink triggers the method with an event

    function fulfillRandomWords(
        uint256, /*_requestId,*/
        uint256[] memory _randomWords
    ) internal override {
        s_randomWords = _randomWords;
        //random value returned by chainlink VRF
        uint256 randomValue;
        //the total balance of LINK in the contract
        uint256 totalLink_in_the_contract;

        //the total amount to disburse the voters will be assumed 80% of the total link in the contract
        uint256 amountTo_disburse_voters;
        totalLink_in_the_contract = LINKTOKEN.balanceOf(address(this));
        amountTo_disburse_voters =
            totalLink_in_the_contract -
            (20 * totalLink_in_the_contract) /
            100;

        for (uint256 i = 0; i < s_randomWords.length; i++) {
            randomValue = s_randomWords[i] % (Winner.voteCount);

            //divide equally among random 10 voters selected from the chainlink VRF and transfer to each
            LINKTOKEN.transfer(
                votedForRapper[randomValue],
                amountTo_disburse_voters / 10
            );
        }
    }

    // 1000000000000000000 = 1 LINK
    function withdraw(uint256 amount, address to) external onlyOwner {
        LINKTOKEN.transfer(to, amount);
    }

    //CAN I AUTOMATE THIS METHOD USING CHAINLINK TO DETERMINE THE WINNER???
    ///Determine the winner of the RAP BATTLE

    function callWinner() public onlyOwner {
        for (uint256 i = 0; i < rapperAddresses.length - 1; i++) {
            if (
                rapperMapping[rapperAddresses[i]].voteCount >=
                rapperMapping[rapperAddresses[i + 1]].voteCount
            ) {
                Winner = rapperMapping[rapperAddresses[i]];
            } else {
                Winner = rapperMapping[rapperAddresses[i + 1]];
            }
        }
        super.rapperWinFundDistribution(Winner.rapperID - 1);
    }
}
