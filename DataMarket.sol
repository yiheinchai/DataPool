// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// A contract that represents a marketplace for data
contract DataMarket is Ownable {

   // A struct that represents a data provider
   struct Provider {
       address account; // The address of the provider
       string name; // The name of the provider
       string description; // The description of the provider
       uint256 price; // The price per data request in tokens
       uint256 requests; // The number of data requests received by the provider
   }

   // A struct that represents a data request
   struct Request {
       address requester; // The address of the requester
       address provider; // The address of the provider
       bytes32 dataHash; // The hash of the requested data
       bool fulfilled; // Whether the request has been fulfilled or not
   }

   // A mapping from provider addresses to providers
   mapping(address => Provider) public providers;

   // A mapping from request IDs to requests
   mapping(uint256 => Request) public requests;

   // A counter for generating request IDs
   uint256 public requestCounter;

   // An event that is emitted when a new provider is registered
   event ProviderRegistered(address indexed account, string name, string description, uint256 price);

   // An event that is emitted when a new request is created
   event RequestCreated(uint256 indexed requestId, address indexed requester, address indexed provider, bytes32 dataHash);

   // An event that is emitted when a request is fulfilled by a provider
   event RequestFulfilled(uint256 indexed requestId, address indexed provider, bytes32 dataHash);

   // The token that is used as the payment currency in the marketplace
   ERC20 public token;

   // The constructor that takes the address of the token contract
   constructor(address _token) {
       require(_token != address(0), "Invalid token address"); // Check if the token address is valid
       token = ERC20(_token); // Set the token contract
   }

   // A modifier that checks if the caller is a registered provider
   modifier onlyProvider() {
       require(providers[msg.sender].account != address(0), "Not a registered provider"); // Check if the caller is a registered provider
       _;
   }

   // A function that registers a new provider in the marketplace
   function registerProvider(string calldata _name, string calldata _description, uint256 _price) external {
       require(providers[msg.sender].account == address(0), "Already a registered provider"); // Check if the caller is not already a registered provider
       require(bytes(_name).length > 0, "Name cannot be empty"); // Check if the name is not empty
       require(bytes(_description).length > 0, "Description cannot be empty"); // Check if the description is not empty
       require(_price > 0, "Price cannot be zero"); // Check if the price is positive

       providers[msg.sender] = Provider(msg.sender, _name, _description, _price, 0); // Create a new provider and store it in the mapping

       emit ProviderRegistered(msg.sender, _name, _description, _price); // Emit a ProviderRegistered event with the provider details
   }

   // A function that creates a new data request in the marketplace
   function createRequest(address _provider, bytes32 _dataHash) external {
       require(_provider != address(0), "Invalid provider address"); // Check if the provider address is valid
       require(providers[_provider].account != address(0), "Provider not registered"); // Check if the provider is registered
       require(_dataHash != 0, "Invalid data hash"); // Check if the data hash is valid

       uint256 requestId = requestCounter; // Get the current request ID
       requestCounter++; // Increment the request counter

       requests[requestId] = Request(msg.sender, _provider, _dataHash, false); // Create a new request and store it in the mapping

       token.transferFrom(msg.sender, address(this), providers[_provider].price); // Transfer the tokens from the requester to this contract

       emit RequestCreated(requestId, msg.sender, _provider, _dataHash); // Emit a RequestCreated event with the request details
   }

   // A function that fulfills a data request in the marketplace
   function fulfillRequest(uint256 _requestId) external onlyProvider {
       require(requests[_requestId].provider == msg.sender, "Not the requested provider"); // Check if the caller is the requested provider
       require(!requests[_requestId].fulfilled, "Request already fulfilled"); // Check if the request has not been fulfilled yet

       requests[_requestId].fulfilled = true; // Mark the request as fulfilled

       token.transfer(msg.sender, providers[msg.sender].price); // Transfer the tokens from this contract to the provider

       emit RequestFulfilled(_requestId, msg.sender, requests[_requestId].dataHash); // Emit a RequestFulfilled event with the request details
   }
}