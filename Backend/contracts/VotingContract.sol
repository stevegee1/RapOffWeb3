//SPDX-License-Identifier:MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Betting.sol";

//THIS IS THE OFFICIAL VOTING CONTRACT OF RAPOFFWEB3 : Voting

//MANTLE TESTNET
contract VotingContract is Ownable, Betting {
    //counter logic from openzeppelin
    using Counters for Counters.Counter;
    Counters.Counter public _voterUniqueId;
    Counters.Counter public _rapperUniqueId;

    //Struct for Rapper
    struct RapperStruct {
        string name;
        uint256 rapperUniqueID;
        string image;
        string ipfs;
        address _address;
        uint256 voteCount;
        address[] rapperVotersArray;
    }

    //Struct
    //declare Rapper event
    event rapperEvent(
        uint256 indexed rapperUniqueID,
        string name,
        string image,
        string ipfs,
        address _address,
        uint256 voteCount
    );

    //create winner struct
    RapperStruct public Winner;

    //create the array of addresses of all rappers
    address[] public rapperArrayAddresses;

    //map the uniqueID of the rapper to its struct
    mapping(address => RapperStruct) public rapperAddToStructMapping;

    ///////END OF RAPPER DATA/////////

    address[] public voterArrayAddresses; //maybe separate this to different arrays so as to use it for the betting platform

    //map the address of the rapper to its struct
    mapping(address => Voter) public voterAddToStructMapping;

    //STRUCT VOTERS
    struct Voter {
        string voter_name;
        uint256 voterUniqueID;
        bool voter_Voted;
        address voter_Address;
        string voter_Image;
        string voter_ipfs;
        address voter_votedFor;
    }
    event VoterEvent(
        uint256 indexed voterUniqueID,
        string voter_name,
        bool voter_Voted,
        address voter_Address,
        string voter_Image,
        string voter_ipfs,
        address voter_voteFor
    );

    //declaring the contract constructor
    //constructor() {}

    //initialize rapper
    function setRapper(
        address _address,
        string memory _image,
        string memory _ipfs,
        string memory _name
    ) public onlyOwner {
        //using counter library
        address[] memory addr;
        _rapperUniqueId.increment();
        uint256 idNumber = _rapperUniqueId.current();

       
        rapperAddToStructMapping[_address] = RapperStruct(
            _name,
            idNumber,
            _image,
            _ipfs,
            _address,
            0,
            addr
        );
        rapperArrayAddresses.push(_address);
        emit rapperEvent(idNumber, _image, _ipfs, _name, _address, 0);
    }

    //function to return all rapper addresses
    function getRapperAddresses() public view returns (address[] memory) {
        return rapperArrayAddresses;
    }

    //function to return the number of rappers
    function getTheNumberOfRappers() public view returns (uint256) {
        return rapperArrayAddresses.length;
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
        RapperStruct storage rapper = rapperAddToStructMapping[_rapperID];
        return (
            rapper.rapperUniqueID,
            rapper.name,
            rapper.image,
            rapper.ipfs,
            rapper._address,
            rapper.voteCount
        );
    }

    //making vote function a public, payable function, 3BIT worth to vote
    function voteNow(
        address _rapperID,
        string memory _name,
        string memory _image,
        string memory _ipfs
    ) public payable {
        require(msg.value >= 3 * 10**18, "minimum required BIT token is 3");

        require(
            !voterAddToStructMapping[msg.sender].voter_Voted,
            "sorry, you can only vote once"
        );

        //increment the vote for the chosen rapperID
        rapperAddToStructMapping[_rapperID].voteCount += 1;
        rapperAddToStructMapping[_rapperID].rapperVotersArray.push(msg.sender);
        //increment voter_ID
        _voterUniqueId.increment();
        uint256 voterIDNumber = _voterUniqueId.current();

        //mapped the voter address to its struct

        voterAddToStructMapping[msg.sender] = Voter(
            _name,
            voterIDNumber,
            true,
            msg.sender,
            _image,
            _ipfs,
            _rapperID
        );
        voterArrayAddresses.push(msg.sender);

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

    //this returns the number of voters
    function getNumberOfAllVoters() public view returns (uint256) {
        return voterArrayAddresses.length;
    }

    //CAN I AUTOMATE THIS METHOD USING CHAINLINK TO DETERMINE THE WINNER???
    ///Determine the winner of the RAP BATTLE

    function callWinner() public onlyOwner {
        for (uint256 i = 0; i < rapperArrayAddresses.length - 1; i++) {
            if (
                rapperAddToStructMapping[rapperArrayAddresses[i]].voteCount >=
                rapperAddToStructMapping[rapperArrayAddresses[i++]].voteCount
            ) {
                Winner = rapperAddToStructMapping[rapperArrayAddresses[i]];
            } else {
                Winner = rapperAddToStructMapping[rapperArrayAddresses[i++]];
            }
        }
        super.rapperWinFundDistribution(Winner.rapperUniqueID - 1);
    }
}
