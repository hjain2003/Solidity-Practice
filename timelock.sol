// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC165{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint);
    function totalSupply() external view returns (uint);
    function balanceOf(address user) external view returns (uint);
}

contract Token is ERC165{
    string private Token_name;
    string private Token_symbol;
    uint256 private TotalSupply;
    uint private token_decimal;
    uint256 public tokenPrice;
    uint256 public totalTokensLeft;
    mapping(address => uint256) private balance;
    mapping(address => mapping(address => uint)) private allowances;
    mapping(address => uint256) private timelock;

    address payable public manager;

    event transferr(address from, address to, uint value);
    event approval(address owner, address spender, uint value);

    modifier onlyManager {
        require(msg.sender == manager, "Manager only area!");
        _;
    }

    modifier transferAllowed(address sender) {
        require(timelock[sender] <= block.timestamp, "Transfer is timelocked");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        uint256 _tokenPrice,
        uint _decimal
    ) {
        Token_name = _name;
        Token_symbol = _symbol;
        token_decimal = _decimal;
        TotalSupply = _totalSupply;
        tokenPrice = _tokenPrice;
        totalTokensLeft = _totalSupply;
        manager = payable(msg.sender);
        balance[msg.sender] = _totalSupply;
    }

    function name() public view returns (string memory) {
        return Token_name;
    }

    function symbol() public view returns (string memory) {
        return Token_symbol;
    }

    function decimals() public view returns (uint) {
        return token_decimal;
    }

    function totalSupply() public view returns (uint) {
        return TotalSupply;
    }

    function balanceOf(address user) public view returns (uint) {
        return balance[user];
    }

    function transfer(address receiver, uint amount) public {
        require(amount <= balance[msg.sender], "Insufficient balance");
        // require(timelock[sender] <= block.timestamp, "Transfer is timelocked");

        balance[msg.sender] -= amount;
        balance[receiver] += amount;
        emit transferr(msg.sender, receiver, amount);
    }

    function approve(address spender, uint amount) public {
        allowances[msg.sender][spender] = amount;
        emit approval(msg.sender, spender, amount);
    }

    function allowance(address owner, address spender) public view returns (uint) {
        return allowances[owner][spender];
    }

    function transferFrom(address sender, address recipient, uint amount) public payable transferAllowed(sender) {
        require(amount <= balance[sender], "Insufficient balance");
        require(amount <= allowances[sender][msg.sender], "Insufficient allowance");

        balance[sender] -= amount;
        balance[recipient] += amount;
        allowances[sender][msg.sender] -= amount;
        emit transferr(sender, recipient, amount);
    }

    

    function buyTokens(uint256 numberOfTokens) public payable {
        require(msg.sender != manager, "Cannot buy tokens as the manager");
        require(msg.value == numberOfTokens * tokenPrice, "Insufficient payment");
        require(numberOfTokens > 0, "Number of tokens must be greater than zero");
        require(balance[manager] >= numberOfTokens, "Manager does not have enough tokens");

        balance[manager] -= numberOfTokens;
        balance[msg.sender] += numberOfTokens;
        totalTokensLeft -= numberOfTokens;
        manager.transfer(msg.value);
        timelock[msg.sender] = block.timestamp + 180;

        emit transferr(manager, msg.sender, numberOfTokens);
    }

    function sellTokens(uint256 numberOfTokens) public transferAllowed(msg.sender) {
        require(balance[msg.sender] >= numberOfTokens, "Insufficient tokens");

        balance[manager] += numberOfTokens;
        balance[msg.sender] -= numberOfTokens;
        totalTokensLeft += numberOfTokens;

        emit transferr(msg.sender, manager, numberOfTokens);
    }

    function getTimestamp() public view returns (uint256) {
        return block.timestamp;
    }
}


