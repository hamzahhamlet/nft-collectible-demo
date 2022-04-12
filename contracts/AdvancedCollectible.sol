// SPDX-License-Identifier: minutes
pragma solidity ^0.6.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract AdvancedCollectible is ERC721, VRFConsumerBase {
    uint256 public tokenCounter;
    bytes32 public keyhash;
    uint256 public fee;

    enum Breed {
        PUG,
        SHIBA_INU,
        ST_BERNARD
    }

    mapping(uint256 => Breed) private tokenIdToBreed;
    mapping(uint256 => address) private requestIdToSender;

    event RequestCollectible(bytes32 indexed requestId, address requester);
    event BreedAssigned(uint256 indexed tokenId, Breed breed);

    constructor(
        address _vrfCoordinator,
        address _linkToken,
        bytes32 _keyhash,
        uint256 _fee
    )
        public
        ERC721("Doggie", "DOG")
        VRFConsumerBase(_vrfCoordinator, _linkToken)
    {
        tokenCounter = 0;
        keyhash = _keyhash;
        fee = _fee;
    }

    function createCollectible() public returns (bytes32) {
        bytes32 requestId = requestRandomness(keyhash, fee);
        requestIdToSender[uint256(requestId)] = msg.sender;
        emit RequestCollectible(requestId, msg.sender);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomNumber)
        internal
        override
    {
        Breed breed = Breed(randomNumber % 3);
        uint256 newTokenId = tokenCounter;
        tokenCounter = tokenCounter + 1;
        tokenIdToBreed[newTokenId] = breed;
        emit BreedAssigned(newTokenId, breed);
        address owner = requestIdToSender[uint256(requestId)];
        _safeMint(owner, newTokenId);
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not owner or approved."
        );
        _setTokenURI(tokenId, _tokenURI);
    }
}
