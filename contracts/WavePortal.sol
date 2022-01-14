// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;
import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    uint256 id;
    uint256 private seed;

    event NewWave(uint256 id, address indexed from, uint256 timestamp, string message);

    struct Wave {
        uint256 id;    // id of the wave
        address waver; // The address of the user who waved.
        string message; // The message the user sent.
        uint256 timestamp; // The timestamp when the user waved.
    }

    Wave[] waves;
    mapping (uint256 => mapping (address => bool)) addressToPostLikedMap;
    mapping (uint256=>uint256) postToLikesCountMap;

    /*
     * This is an address => uint mapping, meaning I can associate an address with a number!
     * In this case, I'll be storing the address with the last time the user waved at us.
     */
    mapping(address => uint256) public lastWavedAt;


    constructor() payable{
        console.log("Hi, I'm the constructor");
        seed = (block.timestamp + block.difficulty) % 100;
    }
    function wave(string memory _message) public{

        /*
         * We need to make sure the current timestamp is at least 15-minutes bigger than the last timestamp we stored
         */
        require(
            lastWavedAt[msg.sender] + 5 minutes < block.timestamp,
            "Wait 5m"
        );

        /*
         * Update the current timestamp we have for the user
         */
        lastWavedAt[msg.sender] = block.timestamp;


        totalWaves++;
        console.log("%s has waved with a message %s!", msg.sender, _message);

        uint256 tempId = getID();

        waves.push(Wave(tempId, msg.sender, _message, block.timestamp));

        seed = (block.difficulty + block.timestamp + seed) % 100;
        console.log("Random # generated: %d", seed);

        /*
         * Give a 20% chance that the user wins the prize.
         */
        if (seed <= 20) {
            console.log("%s won!", msg.sender);
            uint256 prizeAmount = 0.0001 ether;

            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );

            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        emit NewWave(tempId, msg.sender, block.timestamp, _message);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves()public view returns (uint256){
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }

    function getID() private returns (uint256) {
         return ++id; 
    }

    function likePost(uint256 _id) public{
       if (addressToPostLikedMap[_id][msg.sender]){
           postToLikesCountMap[_id]--;
           addressToPostLikedMap[_id][msg.sender] = false;
       }else{
           addressToPostLikedMap[_id][msg.sender]=true;
           postToLikesCountMap[_id]++;
       }
    }

    function getLikesOfPost(uint256 _id) public view returns (uint256){
       return postToLikesCountMap[_id];
    }
}