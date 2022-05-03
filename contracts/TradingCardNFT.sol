// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract TradingCardNFT is ERC721URIStorage, VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface public immutable i_vrfCoordinator;
    bytes32 public immutable i_gasLane;
    uint64 public immutable i_subscriptionId;
    uint32 public immutable i_callbackGasLimit;

    uint16 public constant REQUEST_CONFIRMATIONS = 3;
    uint32 public constant NUM_WORDS = 1;
    uint256 public constant MAX_CHANCE_VALUE = 100;

    mapping(uint256 => address) public s_requestIdToSender;
    string[4] public s_characterTokenUris;

    uint256 public s_tokenCounter;

    constructor(
        address vrfCoordinatorV2,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callBackGasLimit,
        string[4] memory characterTokenUris
    ) ERC721("Trading Card", "TDC") VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callBackGasLimit;
        s_tokenCounter = 0;
        s_characterTokenUris = characterTokenUris;
    }

    // mint a random card
    function requestTradingCard() public returns (uint256 requestId) {
        requestId = i_vrfCoordinator.requestRandomWords(
            // price per gas
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            // max gas amount
            i_callbackGasLimit,
            NUM_WORDS
        );
        s_requestIdToSender[requestId] = msg.sender;
    }

    // callback function
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        // owner of the trading card
        address tradingCardOwner = s_requestIdToSender[requestId];
        uint256 newTokenId = s_tokenCounter;
        s_tokenCounter = s_tokenCounter + 1;

        // get character
        // modulo to get remainder (% 100)
        uint256 moddedRng = randomWords[0] % MAX_CHANCE_VALUE;
        uint256 character = getCharacterFromModdedRng(moddedRng);
        _safeMint(tradingCardOwner, newTokenId);

        // set tokenURI
        _setTokenURI(newTokenId, s_characterTokenUris[character]);
    }

    function getChanceArray() public view returns (uint256[4] memory) {
        // randomness of characters
        // 0 - 9 = 1
        // 10 - 19 = 2
        // 20 - 99 = 3
        // 31 - 99 = 4
        return [10, 20, 30, MAX_CHANCE_VALUE];
    }

    function getCharacterFromModdedRng(uint256 moddedRng)
        public
        returns (uint256)
    {
        uint256 cumulativeSum = 0;
        uint256[4] memory chanceArray = getChanceArray();

        for (uint256 i = 0; i < chanceArray.length; i++) {
            if (
                moddedRng >= cumulativeSum &&
                moddedRng < cumulativeSum + chanceArray[i]
            ) {
                return i;
            }

            cumulativeSum = cumulativeSum + chanceArray[i];
        }
    }
}
