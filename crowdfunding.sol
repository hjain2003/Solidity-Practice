//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract crowdfunding{

    address payable public Manager;
    address payable[] public donators;
    mapping(address=>DonatorInfo) public map;

    event DonatorEntered(address  donator, string name, uint contact);
    event DonationReceived(address  donator, uint moneyReceived);
    event DonationWithdrawn(address donator, uint moneyWithdrawn);

    constructor(){
        Manager = payable(msg.sender);
    }

    modifier onlyManager{
        require(msg.sender==Manager, "Manager only area");_;
    }

    struct DonatorInfo{
        string DonorName;
        uint DonorContact;
        uint AmtDonated;
        bool hasWithdrawn;
    }

    function EnterAsDonor(string memory name,uint contact) public payable{
        donators.push(payable(msg.sender));
        map[msg.sender] = DonatorInfo(name,contact,msg.value,false);

        emit DonatorEntered(msg.sender, name, contact);
    }

    function donate() public payable{
        Manager.transfer(address(this).balance);
        emit DonationReceived(msg.sender, msg.value);
    }

    function withdraw() public payable{
        require(map[msg.sender].AmtDonated > 0, "no money donated");
        require(!map[msg.sender].hasWithdrawn, "money already withdrawn");

        uint withdrawMoney = map[msg.sender].AmtDonated;
        payable(msg.sender).transfer(withdrawMoney);
        map[msg.sender].hasWithdrawn = true;
        map[msg.sender].AmtDonated = 0;

        emit DonationWithdrawn(msg.sender, withdrawMoney);
    }
}