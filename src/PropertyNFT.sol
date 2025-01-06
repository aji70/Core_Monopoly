// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MonopolyPropertyNFT is ERC721URIStorage, Ownable {
    uint256 public nextTokenId;
    string[] propertyName;
    string[] colorGroup;
    uint[] price;
    uint[] rent;

    struct Property {
        string name;
        string colorGroup;
        uint256 price;
        uint256 rent;
    }

    // Mapping tokenId to Property details
    mapping(uint256 => Property) public properties;

    constructor() ERC721("MonopolyPropertyNFT", "MOPN") {
        propertyName = ["Television", "Narayi", "Highcost", "Barnawa", "Sabo"];
        colorGroup = ["blue", "pink", "Purple", "red", "Green"];
        price = [20, 50, 80, 100, 120];
        rent = [2, 5, 7, 10, 12];
    }

    /// @notice Function to mint an NFT for a Monopoly property
    /// @param _name Name of the property
    /// @param _colorGroup Color group of the property
    /// @param _price Price of the property
    /// @param _rent Rent value of the property
    /// @param _tokenURI Metadata URI for the property NFT
    function mintProperty(
        string memory _name,
        string memory _colorGroup,
        uint256 _price,
        uint256 _rent,
        string memory _tokenURI
    ) public onlyOwner {
        uint256 tokenId = nextTokenId + 1;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _tokenURI);

        properties[tokenId] = Property(_name, _colorGroup, _price, _rent);
        nextTokenId++;
    }

    /// @notice Get the details of a specific property
    /// @param tokenId The token ID of the property
    /// @return Property details
    function getPropertyDetails(
        uint256 tokenId
    ) public view returns (Property memory) {
        require(_exists(tokenId), "Property does not exist.");
        return properties[tokenId];
    }

    /// @notice Batch mint properties with predefined details
    /// @param _names Array of property names
    /// @param _colorGroups Array of property color groups
    /// @param _prices Array of property prices
    /// @param _rents Array of property rents
    /// @param _tokenURIs Array of metadata URIs
    function batchMintProperties(
        string[] memory _names,
        string[] memory _colorGroups,
        uint256[] memory _prices,
        uint256[] memory _rents,
        string[] memory _tokenURIs
    ) public onlyOwner {
        require(
            _names.length == _colorGroups.length &&
                _names.length == _prices.length &&
                _names.length == _rents.length &&
                _names.length == _tokenURIs.length,
            "Input arrays must have the same length."
        );

        for (uint256 i = 0; i < _names.length; i++) {
            mintProperty(
                _names[i],
                _colorGroups[i],
                _prices[i],
                _rents[i],
                _tokenURIs[i]
            );
        }
    }

    function startGame() external {
        batchMintProperties(
            propertyName,
            colorGroup,
            price,
            rent,
            propertyName
        );
    }
}
