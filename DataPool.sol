// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DataToken.sol";

// DataPool is a smart contract that allows users to create or join data pools based on their interests or preferences
contract DataPool {

    // A struct that represents a data pool
    struct Pool {
        address owner; // The address of the pool creator
        string name; // The name of the pool
        string description; // The description of the pool
        uint256 interestRate; // The annual interest rate for participating in the pool (in percentage)
        uint256 totalData; // The total amount of data contributed by all pool members (in bytes)
        uint256 totalInterest; // The total amount of interest earned by all pool members (in wei)
        mapping(address => uint256) balances; // A mapping that stores the balance of each pool member (in bytes)
        mapping(address => uint256) interests; // A mapping that stores the interest earned by each pool member (in wei)
    }

    // An event that is emitted when a new pool is created
    event PoolCreated(address indexed owner, string name, string description, uint256 interestRate);

    // An event that is emitted when a user joins a pool
    event PoolJoined(address indexed user, address indexed pool);

    // An event that is emitted when a user puts data into a pool
    event DataPut(address indexed user, address indexed pool, uint256 amount);

    // An event that is emitted when a user gets data from a pool
    event DataGot(address indexed user, address indexed pool, uint256 amount);

    // An event that is emitted when a user withdraws interest from a pool
    event InterestWithdrawn(address indexed user, address indexed pool, uint256 amount);

    // A mapping that stores all the pools by their addresses
    mapping(address => Pool) public pools;

    // A mapping that stores all the pools that a user has joined by their addresses
    mapping(address => address[]) public userPools;

    // A modifier that checks if the caller is the owner of a pool
    modifier onlyPoolOwner(address _pool) {
        require(pools[_pool].owner == msg.sender, "Only pool owner can call this function");
        _;
    }

     // A modifier that checks if the caller is a member of a pool
    modifier onlyPoolMember(address _pool) {
        require(pools[_pool].balances[msg.sender] > 0, "Only pool member can call this function");
        _;
    }

    // A modifier that checks if the pool exists
    modifier poolExists(address _pool) {
        require(pools[_pool].owner != address(0), "Pool does not exist");
        _;
    }

    // A function that creates a new pool with a given name, description and interest rate
    function createPool(string memory _name, string memory _description, uint256 _interestRate) public {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_description).length > 0, "Description cannot be empty");
        require(_interestRate > 0 && _interestRate <= 100, "Interest rate must be between 1 and 100");

        // Create a new pool instance
        Pool memory newPool = Pool({
            owner: msg.sender,
            name: _name,
            description: _description,
            interestRate: _interestRate,
            totalData: 0,
            totalInterest: 0
        });

        // Store the pool in the mapping by its address
        pools[address(newPool)] = newPool;

        // Add the pool to the user's list of pools
        userPools[msg.sender].push(address(newPool));

        // Emit an event
        emit PoolCreated(msg.sender, _name, _description, _interestRate);
    }

    // A function that allows a user to join an existing pool by its address
    function joinPool(address _pool) public poolExists(_pool) {
        // Check if the user is already a member of the pool
        require(pools[_pool].balances[msg.sender] == 0, "User is already a member of the pool");

        // Add the user to the pool with zero balance and interest
        pools[_pool].balances[msg.sender] = 0;
        pools[_pool].interests[msg.sender] = 0;

        // Add the pool to the user's list of pools
        userPools[msg.sender].push(_pool);

        // Emit an event
        emit PoolJoined(msg.sender, _pool);
    }

    // A function that allows a user to put some data into a pool by its address and amount (in bytes)
    function putData(address _pool, uint256 _amount) public payable onlyPoolMember(_pool) {
        // Check if the amount is positive and less than or equal to the message value
        require(_amount > 0, "Amount must be positive");
        require(_amount <= msg.value, "Amount must be less than or equal to message value");

        // Update the user's balance and interest in the pool
        pools[_pool].balances[msg.sender] += _amount;
        pools[_pool].interests[msg.sender] += (_amount * pools[_pool].interestRate * 1 days) / (365 days * 100);

        // Update the pool's total data and interest
        pools[_pool].totalData += _amount;
        pools[_pool].totalInterest += (_amount * pools[_pool].interestRate * 1 days) / (365 days * 100);

        // Emit an event
        emit DataPut(msg.sender, _pool, _amount);
    }

    // A function that allows a user to get some data from a pool by its address and amount (in bytes)
    function getData(address _pool, uint256 _amount) public onlyPoolMember(_pool) {
        // Check if the amount is positive and less than or equal to the user's balance in the pool
        require(_amount > 0, "Amount must be positive");
        require(_amount <= pools[_pool].balances[msg.sender], "Amount must be less than or equal to user's balance");

        // Update the user's balance and interest in the pool
        pools[_pool].balances[msg.sender] -= _amount;
        pools[_pool].interests[msg.sender] -= (_amount * pools[_pool].interestRate * 1 days) / (365 days * 100);

        // Update the pool's total data and interest
        pools[_pool].totalData -= _amount;
        pools[_pool].totalInterest -= (_amount * pools[_pool].interestRate * 1 days) / (365 days * 100);

        // Transfer the amount of ether to the user
        payable(msg.sender).transfer(_amount);

        // Emit an event
        emit DataGot(msg.sender, _pool, _amount);
    }

    // A function that allows a user to withdraw some interest from a pool by its address and amount (in wei)
    function withdrawInterest(address _pool, uint256 _amount) public onlyPoolMember(_pool) {
        // Check if the amount is positive and less than or equal to the user's interest in the pool
        require(_amount > 0, "Amount must be positive");
        require(_amount <= pools[_pool].interests[msg.sender], "Amount must be less than or equal to user's interest");

        // Update the user's interest in the pool
        pools[_pool].interests[msg.sender] -= _amount;

        // Update the pool's total interest
        pools[_pool].totalInterest -= _amount;

        // Transfer the amount of ether to the user
        payable(msg.sender).transfer(_amount);

        // Emit an event
        emit InterestWithdrawn(msg.sender, _pool, _amount);
    }

    // A function that returns all the pools that a user has joined by their addresses
    function getUserPools() public view returns (address[] memory) {
        return userPools[msg.sender];
    }

    // A function that returns the balance and interest of a user in a pool by its address
    function getUserBalanceAndInterest(address _pool) public view onlyPoolMember(_pool) returns (uint256, uint256) {
        return (pools[_pool].balances[msg.sender], pools[_pool].interests[msg.sender]);
    }
}