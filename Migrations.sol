// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// A contract that keeps track of the migrations done by a deployment tool
contract Migrations {
  // The address of the owner of this contract
  address public owner;

  // A number that represents the latest deployed contract version
  uint public last_completed_migration;

  // A modifier that restricts access to only the owner of this contract
  modifier restricted() {
    require(msg.sender == owner, "This function is restricted to the contract's owner");
    _;
  }

  // The constructor that sets the owner to the sender of the transaction
  constructor() {
    owner = msg.sender;
  }

  // A function that updates the last completed migration version
  function setCompleted(uint completed) public restricted {
    last_completed_migration = completed;
  }

}