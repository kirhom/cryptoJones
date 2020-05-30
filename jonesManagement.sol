pragma solidity ^0.4.0;
import './cryptoJones.sol';


contract JonesManagement {
    struct cryptoJonesContract {
        address contractAddress;
        uint256 price;
    }
    uint256 public nActiveContracts = 0;
    cryptoJonesContract[] activeContracts;
    address administrator;
    
    function createGame(uint256 _price) public returns (address){
        administrator = msg.sender;
        address newGame = new CryptoJones(_price);
        cryptoJonesContract memory newContract = cryptoJonesContract(newGame, _price);
        activeContracts.push(newContract);
        nActiveContracts++;
        return newGame;
    }
    
    function getContract(uint256 index) public view returns (address contractAddress, uint256 price) {
        return (activeContracts[index].contractAddress, activeContracts[index].price);
    }
    
}
