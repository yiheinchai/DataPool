// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// DataToken is a ERC20 token that represents different types of data
contract DataToken is ERC20 {
    // The symbol of the token (e.g. DTPI for Data Token Personal Information)
    string public symbol;

    // The name of the token (e.g. Data Token Personal Information)
    string public name;

    // The decimals of the token (e.g. 18)
    uint8 public decimals;

    // The total supply of the token
    uint256 public totalSupply;

    // A mapping from account addresses to their balances
    mapping(address => uint256) public balanceOf;

    // A mapping from account addresses to a mapping of spender addresses to their allowances
    mapping(address => mapping(address => uint256)) public allowance;

    // An event that is emitted when tokens are transferred
    event Transfer(address indexed from, address indexed to, uint256 value);

    // An event that is emitted when an allowance is approved
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // A modifier that checks if the sender has enough balance to transfer tokens
    modifier hasEnoughBalance(address sender, uint256 value) {
        require(balanceOf[sender] >= value, "Insufficient balance");
        _;
    }

    // A modifier that checks if the sender has enough allowance to transfer tokens on behalf of another account
    modifier hasEnoughAllowance(address sender, address owner, uint256 value) {
        require(allowance[owner][sender] >= value, "Insufficient allowance");
        _;
    }

   // A constructor that sets the initial values for the token attributes
   constructor(string memory _symbol, string memory _name, uint8 _decimals) {
       symbol = _symbol;
       name = _name;
       decimals = _decimals;
       totalSupply = 0; // Initially there is no supply until tokens are minted
   }

   // A function that mints new tokens and assigns them to an account
   function mint(address account, uint256 value) external returns (bool) {
       require(account != address(0), "Invalid account"); // Check if the account is valid

       totalSupply += value; // Increase the total supply by the minted amount
       balanceOf[account] += value; // Increase the balance of the account by the minted amount

       emit Transfer(address(0), account, value); // Emit a transfer event from the zero address to the account

       return true; // Return true to indicate success
   }

   // A function that burns existing tokens from an account
   function burn(address account, uint256 value) external returns (bool) {
       require(account != address(0), "Invalid account"); // Check if the account is valid

       hasEnoughBalance(account, value); // Check if the account has enough balance to burn

       totalSupply -= value; // Decrease the total supply by the burned amount

       // Decrease the total supply by the burned amount
       balanceOf[account] -= value; // Decrease the balance of the account by the burned amount

       emit Transfer(account, address(0), value); // Emit a transfer event from the account to the zero address

       return true; // Return true to indicate success
   }

   // A function that transfers tokens from one account to another
   function transfer(address to, uint256 value) external returns (bool) {
       require(to != address(0), "Invalid recipient"); // Check if the recipient is valid

       hasEnoughBalance(msg.sender, value); // Check if the sender has enough balance to transfer

       balanceOf[msg.sender] -= value; // Decrease the balance of the sender by the transferred amount
       balanceOf[to] += value; // Increase the balance of the recipient by the transferred amount

       emit Transfer(msg.sender, to, value); // Emit a transfer event from the sender to the recipient

       return true; // Return true to indicate success
   }

   // A function that transfers tokens from one account to another on behalf of another account
   function transferFrom(address from, address to, uint256 value) external returns (bool) {
       require(to != address(0), "Invalid recipient"); // Check if the recipient is valid

       hasEnoughBalance(from, value); // Check if the owner has enough balance to transfer
       hasEnoughAllowance(msg.sender, from, value); // Check if the sender has enough allowance to transfer on behalf of the owner

       balanceOf[from] -= value; // Decrease the balance of the owner by the transferred amount

    // Decrease the balance of the owner by the transferred amount
       balanceOf[to] += value; // Increase the balance of the recipient by the transferred amount

       allowance[from][msg.sender] -= value; // Decrease the allowance of the sender by the transferred amount

       emit Transfer(from, to, value); // Emit a transfer event from the owner to the recipient

       return true; // Return true to indicate success
   }

   // A function that approves an allowance for another account to transfer tokens on behalf of the caller
   function approve(address spender, uint256 value) external returns (bool) {
       require(spender != address(0), "Invalid spender"); // Check if the spender is valid

       allowance[msg.sender][spender] = value; // Set the allowance of the spender to the specified value

       emit Approval(msg.sender, spender, value); // Emit an approval event from the caller to the spender

       return true; // Return true to indicate success
   }
}