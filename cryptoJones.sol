pragma solidity ^0.4.0;
contract CryptoJones {
    
    uint256 public price;
    string[9] public cards = ["skeleton", "mummy", "vampire", "skeleton", "mummy", "vampire", "skeleton", "mummy", "vampire"];
    mapping(address => bool) players;
    mapping(string => uint128) appearedCards;
    string[9] public desk;
    string selectedCard;
    uint128 remainingCards = 9;
    
    constructor(uint256 _price) public{
        price = _price;
        shuffle();
    }
    
    function shuffle() internal {
        uint256 initialLength = cards.length;
        for (uint256 i = 0; i < desk.length; i++) {
            uint256 randomNumber = uint256(keccak256(abi.encodePacked(now))) % initialLength;
            desk[i] =  cards[randomNumber];
            cards[randomNumber] = cards[initialLength - 1];
            initialLength--;
        }
    }
    
    function contains(address _wallet) private view returns (bool){
        return players[_wallet];
    }
    
    function joinToGame() payable public{
        if (contains(msg.sender)) { revert("You are already in the game"); }
        if (msg.value != price) { revert("You can't pay that. Check the price and try again"); }
        players[msg.sender] = true;
    }
    
    function drawCard() public {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(now))) % (remainingCards - 1);
        selectedCard = desk[randomNumber];
        appearedCards[desk[randomNumber]]++;
        desk[randomNumber] = desk[remainingCards-1]; 
        remainingCards--;
        //TODO comprobar si el juego ha terminado
    }
    
    function totalBalance() public view returns (uint) {
        return address(this).balance;
    }
}