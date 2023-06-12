// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    address public manager;
    uint public ticketPrice;
    uint public ticketCount;
    address[] public participants;
    bool public lotteryOpen;
    uint public winningTicketIndex;

    event LotteryOpened();
    event TicketPurchased(address indexed participant);
    event LotteryClosed(uint winningTicketIndex);
    event PrizeDistributed(address indexed winner, uint amount);

    modifier restricted() {
        require(msg.sender == manager, "Restricted to manager");
        _;
    }

    constructor(){
        manager=msg.sender;
    }

    function openLottery(uint _ticketPrice) public restricted{
        require(!lotteryOpen, "Lottery is already open");
        require(_ticketPrice > 0, "Invalid ticket price");

        // manager = msg.sender;
        ticketPrice = _ticketPrice;
        lotteryOpen = true;

        emit LotteryOpened();
    }

    function purchaseTicket() public payable {
        require(lotteryOpen, "Lottery is not open");
        require(msg.value == ticketPrice, "Incorrect ticket price");

        participants.push(msg.sender);
        ticketCount++;

        emit TicketPurchased(msg.sender);
    }

    function closeLottery() public restricted {
        require(lotteryOpen, "Lottery is not open");
        require(ticketCount > 0, "No participants in the lottery");

        lotteryOpen = false;
        winningTicketIndex = generateRandomNumber() % ticketCount;

        emit LotteryClosed(winningTicketIndex);
    }

    function distributePrize() public restricted {
        require(!lotteryOpen, "Lottery is still open");
        require(winningTicketIndex < participants.length, "Invalid winning ticket index");

        address payable winner = payable(participants[winningTicketIndex]);
        uint prizeAmount = address(this).balance;

        winner.transfer(prizeAmount);

        emit PrizeDistributed(winner, prizeAmount);
    }

    function generateRandomNumber() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, participants.length)));
    }
}
