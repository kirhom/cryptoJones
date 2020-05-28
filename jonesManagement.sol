pragma solidity ^0.4.0;
import './cryptoJones.sol';

contract JonesManagement {
    mapping(address => uint256) public activeContracts;
    address administrator;
    
    function createGame(uint256 _price) public returns (address){
        administrator = msg.sender;
        address newGame = new CryptoJones(_price);
        activeContracts[newGame] = _price;
        return newGame;
    }
    
}
