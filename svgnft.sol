// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "https://github.com/Brechtpd/base64/blob/main/base64.sol";

contract SVGtoNFT is ERC721URIStorage, Ownable {
    // Incremental counter of token ID and we iterate
    uint256 public tokenCounter;
    event CreatedSVGNFT(uint256 indexed tokenId, string tokenURI);
    
    // Ad struct
    struct Ad {
	address minter; // Whoever minted this NFT
	uint256 price; // How much a sponsor is willing to pay for the ad
	uint expiryDate; // When this ad expires
    }
    // stores an `Ad` struct using tokenID as a key.
    mapping(uint => Ad) public ads;
    
    // LandOwner struct
    struct Landowner {
	uint256 landx; // x cor of land
	uint256 landy; // y cor of land
	uint256[] tokenIDs; // ID of transferred NFTs
    }
    // stores a `LandOwner` struct for each address.
    mapping(address => LandOwner) public landOwners;
    
    constructor() ERC721("SVG on-chain NFT", "svgNFT")
    {
        tokenCounter = 0;
    }

    // Mint a new NFT with token URI
    // 1. SVG > Image URI
    // 2. Image URI > Token URI format
    // 3. Create with Token URI
    function create(string memory svg, uint256 memory price) public {
        _safeMint(msg.sender, tokenCounter);
        // 1. SVG format > data:XXX
        string memory imageURI = svgToImageURI(svg);
        // 2. ERC721Metadata func to make it in token URI form
        _setTokenURI(tokenCounter, formatTokenURI(imageURI));
        
        // Add to ads and set all values
        Ad storage ad = ads[tokenCounter];
        ad.price = price;
        ad.minter = msg.sender;
        
        tokenCounter = tokenCounter + 1;
        emit CreatedSVGNFT(tokenCounter, svg);
    }
    
    // 1. SVG > Image URI
    function svgToImageURI(string memory svg) public pure returns (string memory) {
        // Prefix of Image
        string memory baseURL = "data:image/svg+xml;base64,";
    
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        string memory imageURI = abi.encodePacked(baseURL,svgBase64Encoded);
        return imageURI;
    }

    // 2. Image URI to base64 format
    function formatTokenURI(string memory imageURI) public pure returns (string memory) {
        return string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                "SVG NFT", // You can add whatever name here
                                '", "description":"Your on-chain ad", "attributes":"", "image":"',imageURI,'"}'
                            )
                        )
                    )
                )
            );
    }
}
