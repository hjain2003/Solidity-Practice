// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CoinFlip {
    address public manager;
    uint256 public enterAmt;
    address payable[] public players;
    mapping(address => Player) public playerInfo;

    struct Player {
        string name;
        bool isParticipated;
    }

    event CompetitionEntered(address indexed player, string name);
    event CoinFlipped(address indexed winner, string name, uint256 winnings);

    constructor() {
        manager = msg.sender;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Manager only access area");
        _;
    }

    function setEnterAmt(uint256 _enterAmt) public onlyManager {
        enterAmt = _enterAmt;
    }

    function alreadyParticipated() public view returns (bool) {
        return playerInfo[msg.sender].isParticipated;
    }

    function enterCompetition(string memory _name) public payable {
        require(msg.sender != manager, "Manager cannot enter the competition");
        require(msg.value >= enterAmt, "Incorrect transaction value");
        require(!alreadyParticipated(), "Player already entered the competition");

        players.push(payable(msg.sender));
        playerInfo[msg.sender] = Player(_name, true);

        emit CompetitionEntered(msg.sender, _name);
    }

    function flipCoin() public payable onlyManager {
        uint256 payment = address(this).balance;
        uint256 winningPlayerIndex = generateRandomNumber() % players.length;
        address payable winningPlayer = players[winningPlayerIndex];
        Player memory winningPlayerInfo = playerInfo[winningPlayer];

        delete players;

        emit CoinFlipped(winningPlayer, winningPlayerInfo.name, payment);

        winningPlayer.transfer(payment);
    }

    function generateRandomNumber() public view returns (uint256) {
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(blockhash(block.number - 1), block.timestamp)
            )
        );
        return (randomNumber % players.length);
    }
}
