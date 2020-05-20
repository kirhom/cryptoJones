pragma solidity ^0.4.0;
contract CryptoJones {
    
    uint256 public price;
    uint256 currentMonsterCards = 9;
    uint256 totalPrizeCards = 20;
    uint256 remainingCards = 29;
    uint256 currentPrizeCards = 20;
    int256[9] public monsterCards = [-1, -2, -3, -1, -2, -3, -1, -2, -3];
    int256[20] prizeCards;
    int256[29] public desk;
    mapping(address => bool) players;
    mapping(address => int256) playerEarnings;
    mapping(address => uint8) playerDecision; //0 -> don't continue, 1 -> continue, 2 -> NA, 3 -> retired
    address[] activePlayers;
    uint128 numberActivePlayers = 0;
    mapping(int256 => int256) appearedCards;
    uint128 round = 0;
    bool gameStarted = false;
    address owner;
    
    modifier checkActive {
        for (uint256 i = 0; i < activePlayers.length; i++) {
            require (playerDecision[activePlayers[i]] != 2, "There are users choosing if they continue playing");
        }
        _;
    }
    
    modifier notStarted {
        require(!gameStarted, "The game has already started");
        _;
    }
    
    constructor(uint256 _price) public{
        price = _price;
        owner = msg.sender;
    }
    
    function startGame() public notStarted {
        gameStarted = true;
        createPrizeCards();
    }
    

    function generateRandomNumber(uint256 min, uint256 max) internal view returns (uint256) {
        if (max - min > 0) {
            uint256 seed = uint256(keccak256(abi.encodePacked(
                block.timestamp + block.difficulty +
                ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)) +
                block.gaslimit + 
                ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)) +
                block.number
            )));
            return min + (seed - ((seed / max) * max));
        }
        return 0;
    }
    
    function createPrizeCards() internal {
        uint256 totalPrize = address(this).balance;
        uint256 maxPrize = 0;
        uint256 minPrize = 0;
        uint256 randomNumber = 0;
        for (uint256 i = 0; i < prizeCards.length; i++) {
            if (totalPrizeCards != 1) {
                maxPrize = totalPrize/totalPrizeCards;
                minPrize = maxPrize/2;
                randomNumber = generateRandomNumber(minPrize, maxPrize);
                prizeCards[i] = int128(randomNumber);
                totalPrizeCards--;
                totalPrize = totalPrize - randomNumber;
            } else {
                prizeCards[i] = int128(totalPrize);
            }
        }
    }
    
    function contains(address _wallet) private view returns (bool){
        return players[_wallet];
    }
    
    function joinToGame() payable public notStarted{
        if (contains(msg.sender)) { revert("You are already in the game"); }
        if (msg.value != price) { revert("You can't pay that. Check the price and try again"); }
        players[msg.sender] = true;
        playerEarnings[msg.sender] = 0;
        activePlayers.push(msg.sender);
        playerDecision[msg.sender] = 1;
        numberActivePlayers++;
    }
    
    function retire() public {
        if (!contains(msg.sender)) { revert("You are not in the game"); }
        for (uint256 i = 0; i < activePlayers.length; i++) {
            if (msg.sender == activePlayers[i]){
                playerDecision[msg.sender] = 3;
                activePlayers[i].transfer(uint256(playerEarnings[activePlayers[i]]));
                delete activePlayers[i];
                numberActivePlayers--;
            }
        }
    }
    
    function keepPlaying() public {
        if (!contains(msg.sender)) { revert("You are not in the game"); }
        if (playerDecision[msg.sender] == 2) {
            playerDecision[msg.sender] = 1;
        }
    }
    
    function finishGame() private {
        for (uint256 i = 0; i < activePlayers.length; i++) {
            if (activePlayers[i] != 0) {
                playerEarnings[activePlayers[i]] = 0;
            }
        }
        owner.transfer(address(this).balance);
    }
    
    function splitPrizeAndSetDecision (int256 prize) internal {
        int256 amountToTransfer = int256(prize/numberActivePlayers);
        for (uint256 i = 0; i < activePlayers.length; i++) {
            if (activePlayers[i] != 0) {
                playerEarnings[activePlayers[i]] = playerEarnings[activePlayers[i]] + amountToTransfer;
                playerDecision[activePlayers[i]] = 2;
            }
        }
    }
    
    function resetRound () internal {
        for (uint256 i = 0; i < activePlayers.length; i++) {
            if (activePlayers[i] != 0) {
                playerDecision[activePlayers[i]] = 2;
            }
        }
    }
    
    function drawCard() public checkActive returns (int256) {
        int256 randomCard = 0;
        uint256 randomNumber = generateRandomNumber(1, 10);
        //currentMonsterCards won't be zero
            if ((randomNumber > 5 && currentPrizeCards > 0) || (currentMonsterCards == 0)) {
                randomNumber = generateRandomNumber(0, currentPrizeCards);
                randomCard = prizeCards[randomNumber];
                currentPrizeCards--;
                prizeCards[randomNumber] = prizeCards[currentPrizeCards];
                splitPrizeAndSetDecision(randomCard);
            } else {
                randomNumber = generateRandomNumber(0, currentMonsterCards);
                randomCard = monsterCards[randomNumber];
                currentMonsterCards--;
                monsterCards[randomNumber] = monsterCards[currentMonsterCards];
                appearedCards[randomCard]++;
                if (appearedCards[randomCard] == 3) {
                    finishGame();
                } else {
                    resetRound();
                }
            }
        return randomCard;
    }
    
    function totalBalance() public view returns (uint) {
        return address(this).balance;
    }
}
