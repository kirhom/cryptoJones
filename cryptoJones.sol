pragma solidity ^0.4.0;
contract CryptoJones {
    
    uint256 public price;
    uint128 totalMonsterCards = 10;
    uint128 totalPrizeCards = 20;
    uint128 totalCards = 30;
    int128[10] public monsterCards = [-1, -2, -3, -1, -2, -3, -1, -2, -3];
    int128[20] prizeCards;
    int128[30] public desk;
    mapping(address => bool) players;
    mapping(string => uint128) appearedCards;
    uint128 remainingCards = 30;
    
    constructor(uint256 _price) public{
        price = _price;
    }
    
    function startGame() public {
        createPrizeCards();
        //shuffle();
    }
    
    function createPrizeCards() internal {
        uint256 totalPrize = address(this).balance;
        for (uint256 i = 0; i < prizeCards.length; i++) {
            if (totalPrizeCards != 1) {
                uint256 maxPrize = totalPrize/totalPrizeCards;
                uint256 minPrize = maxPrize/2;
                //TODO create a getRandomNumber function
                uint256 randomNumber = (minPrize + uint256(keccak256(abi.encodePacked(now)))) % maxPrize + minPrize;
                prizeCards[i] = int128(randomNumber);
                totalPrizeCards--;
                totalPrize = totalPrize - randomNumber;
            } else {
                prizeCards[i] = int128(totalPrize);
            }
        }
    }
    
    function shuffle() internal {
        //TODO include the prizeCards
        uint256 initialMonsterLength = monsterCards.length;
        uint256 initialPrizeCardsLength = prizeCards.length;
        for (uint256 i = 0; i < desk.length; i++) {
            //TODO create a getRandomNumber function
            uint256 randomNumber = uint256(keccak256(abi.encodePacked(now))) % initialMonsterLength;
            desk[i] =  monsterCards[randomNumber];
            monsterCards[randomNumber] = monsterCards[initialMonsterLength - 1];
            initialMonsterLength--;
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
    
    function finishGame() private {
        
    }
    
    function drawCard() public {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(now))) % (remainingCards - 1);
        /*appearedCards[desk[randomNumber]]++;
        if (appearedCards[desk[randomNumber]] == 3) {
            finishGame();
        }
        desk[randomNumber] = desk[remainingCards-1]; 
        remainingCards--;*/
    }
    
    function totalBalance() public view returns (uint) {
        return address(this).balance;
    }
}