pragma solidity ^0.4.0;
contract CryptoJones {
    
    uint256 public price;
    uint256 totalMonsterCards = 10;
    uint256 totalPrizeCards = 20;
    uint256 totalCards = 30;
    int256[10] public monsterCards = [-1, -2, -3, -1, -2, -3, -1, -2, -3];
    int256[20] prizeCards;
    int256[30] public desk;
    mapping(address => bool) players;
    mapping(address => int256) playerEarnings;
    address[] activePlayers;
    uint128 numberActivePlayers = 0;
    mapping(int256 => int256) appearedCards;
    uint128 round = 0;
    bool gameStarted = false;
    
    constructor(uint256 _price) public{
        price = _price;
    }
    
    function startGame() public {
        createPrizeCards();
        shuffle();
    }
    
    function generateRandomNumber(uint256 min, uint256 max) internal view returns (uint256) {
        //TODO generate a true getRandomNumber function
        return(min + uint256(keccak256(abi.encodePacked(now)))) % max + min;
    }
    
    function createPrizeCards() internal {
        uint256 totalPrize = address(this).balance;
        for (uint256 i = 0; i < prizeCards.length; i++) {
            if (totalPrizeCards != 1) {
                uint256 maxPrize = totalPrize/totalPrizeCards;
                uint256 minPrize = maxPrize/2;
                uint256 randomNumber = generateRandomNumber(minPrize, maxPrize);
                prizeCards[i] = int128(randomNumber);
                totalPrizeCards--;
                totalPrize = totalPrize - randomNumber;
            } else {
                prizeCards[i] = int128(totalPrize);
            }
        }
    }
    
    function shuffle() internal {
        require(!gameStarted, "The game has already started");
        uint256 totalCardsLength = desk.length;
        uint256 currentPrizeCardsLength = prizeCards.length;
        uint256 currentMonsterLength = monsterCards.length;
        uint256 randomNumber;
        uint128 i = 0;
        while (i < totalCardsLength) {
            int256 randomCard;
            if ((generateRandomNumber(0, 1) == 1 && currentPrizeCardsLength > 0) || (currentMonsterLength == 0)) {
                randomNumber = generateRandomNumber(0, currentPrizeCardsLength);
                randomCard = prizeCards[randomNumber];
                currentPrizeCardsLength--;
                prizeCards[randomNumber] = prizeCards[currentPrizeCardsLength];
            } else {
                randomNumber = generateRandomNumber(0, currentMonsterLength);
                randomCard = monsterCards[randomNumber];
                currentMonsterLength--;
                monsterCards[randomNumber] = monsterCards[currentMonsterLength];
            }
            desk[i] = randomCard;
            i++;
        }
        gameStarted = true;
    }
    
    function contains(address _wallet) private view returns (bool){
        return players[_wallet];
    }
    
    function joinToGame() payable public{
        if (contains(msg.sender)) { revert("You are already in the game"); }
        if (msg.value != price) { revert("You can't pay that. Check the price and try again"); }
        players[msg.sender] = true;
        playerEarnings[msg.sender] = 0;
        activePlayers.push(msg.sender);
        numberActivePlayers++;
    }
    
    function retire() public {
        for (uint256 i = 0; i < activePlayers.length; i++) {
            if (msg.sender == activePlayers[i]){
                activePlayers[i].transfer(uint256(playerEarnings[activePlayers[i]]));
                delete activePlayers[i];
                numberActivePlayers--;
            }
        }
    }
    
    function finishGame() private {
        for (uint256 i = 0; i < activePlayers.length; i++) {
            if (activePlayers[i] != 0) {
                playerEarnings[activePlayers[i]] = 0;
            }
        }
    }
    
    function splitPrize (int256 prize) internal {
        int256 amountToTransfer = int256(prize/numberActivePlayers);
        for (uint256 i = 0; i < activePlayers.length; i++) {
            if (activePlayers[i] != 0) {
                playerEarnings[activePlayers[i]] = playerEarnings[activePlayers[i]] + amountToTransfer;
            }
        }
    }
    
    function drawCard() public returns (int256) {
        //TODO instead of create the desk randomly, extract card randomly
        int256 card = desk[round];
        if (card < 0 ){
            appearedCards[card]++;
            if (appearedCards[card] == 3) {
                finishGame();
            }
        } else {
            splitPrize(desk[round]);
        }
        round++;
        return card;
    }
    
    function totalBalance() public view returns (uint) {
        return address(this).balance;
    }
}
