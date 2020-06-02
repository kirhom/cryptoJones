pragma solidity ^0.4.0;
import './cryptoJones.sol';


contract JonesManagement {
    struct cryptoJonesContract {
        address contractAddress;
        uint256 price;
    }
    uint256 public nActiveContracts = 0;
    cryptoJonesContract[] activeContracts;
    mapping (address => bool) contractsMap;

    address administrator;
    
    function createGame(uint256 _price) public returns (address){
        administrator = msg.sender;
        address newGame = new CryptoJones(_price, administrator);
        cryptoJonesContract memory newContract = cryptoJonesContract(newGame, _price);
        activeContracts.push(newContract);
        contractsMap[newGame] = true;
        nActiveContracts++;
        return newGame;
    }
    
    function getContract(uint256 index) public view returns (address contractAddress, uint256 price) {
        return (activeContracts[index].contractAddress, activeContracts[index].price);
    }
    
    function contains(address contractAddress) private view returns (bool){
        return contractsMap[contractAddress];
    }
    
    function removeContract(address contractAddress) public {
        require(contains(msg.sender), "You cannot do this"); 
        if (nActiveContracts > 0) {
            for (uint256 i = 0; i < nActiveContracts; i++) {
                if (activeContracts[i].contractAddress == contractAddress) {
                    nActiveContracts--;
                    activeContracts[i] = activeContracts[nActiveContracts];
                    delete activeContracts[nActiveContracts];
                    delete(contractsMap[contractAddress]);
                }
            }
        }
    }
    
}
