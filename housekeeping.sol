//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Housekeeping {
    address public Manager;
    uint public HousekeepingPrice;
    address payable[] public requests;

    event HousekeepingRequested(address requester, uint amount);
    event HousekeepingRequestFulfilled(address requester, uint amount);

    constructor() {
        Manager = msg.sender;
    }

    modifier onlyManager() {
        require(msg.sender == Manager, "Manager only area");
        _;
    }

    function setHousekeepingPrice(uint price) public onlyManager {
        HousekeepingPrice = price;
    }

    function requestAlreadyMade() public view returns(bool){
        for (uint i=0; i<requests.length; i++){
            if (requests[i]==msg.sender){
                return true;
            }
        }
        return false;
    }

    function callForHousekeeping() public payable {
        require(msg.sender != Manager, "Manager cannot call for housekeeping");
        require(msg.value >= HousekeepingPrice);
        require(requestAlreadyMade() == false, "Request already made");

        requests.push(payable(msg.sender));
        emit HousekeepingRequested(msg.sender, msg.value);
    }

    function SendForHousekeeping() public payable onlyManager {
        address payable manager = payable(Manager);
        uint payment = address(this).balance;
        manager.transfer(payment);
        delete requests;
        emit HousekeepingRequestFulfilled(msg.sender, payment);
    }
}
