//SPDX-License-Identifier:MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//THIS IS THE OFFICIAL VOTING CONTRACT OF RAPOFFWEB3 : Voting

//MANTLE TESTNET
contract VotingContract is Ownable {
    //counter logic from openzeppelin
    using Counters for Counters.Counter;
    Counters.Counter public _voterId;
    Counters.Counter public _rapperId;

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
    constructor() {}

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
        emit rapperEvent(idNumber, _name, _image, _ipfs, _address, 0);
    }

    //function to return all rapper addresses
    function getRapperAddresses() public view returns (address[] memory) {
        return rapperAddresses;
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
    ) public payable {
        require(amount >= 3 * 10**18, "minimum required LINK token is 3");

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

    //this returns the number of voters
    function getNumberOfAllVoters() public view returns (uint256) {
        return voterAddresses.length;
    }

    // 1000000000000000000 = 1 LINK
    function withdraw(uint256 amount, address to) external onlyOwner {
        //LINKTOKEN.transfer(to, amount);
    }

    //CAN I AUTOMATE THIS METHOD USING CHAINLINK TO DETERMINE THE WINNER???
    ///Determine the winner of the RAP BATTLE

    function callWinner() public onlyOwner {
        for (uint256 i = 0; i < rapperAddresses.length - 1; i++) {
            if (
                rapperMapping[rapperAddresses[i]].voteCount >=
                rapperMapping[rapperAddresses[i++]].voteCount
            ) {
                Winner = rapperMapping[rapperAddresses[i]];
            } else {
                Winner = rapperMapping[rapperAddresses[i++]];
            }
        }
    }
}
