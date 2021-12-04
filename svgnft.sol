// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "https://github.com/Brechtpd/base64/blob/main/base64.sol";

contract SVGtoNFT is ERC721URIStorage, Ownable {
    // Incremental counter of token ID
    uint256 public tokenCounter;
    event CreatedSVGNFT(uint256 indexed tokenId, string tokenURI);

    constructor() ERC721("SVG on-chain NFT", "svgNFT")
    {
        minter = msg.sender;
        tokenCounter = 0;
    }

    // Mint a new NFT with token URI
    // 1. SVG > Image URI
    // 2. Image URI > Token URI format
    // 3. Create with Token URI
    function create(string memory svg) public {
        // Only owner can mint NFTs
        require(msg.sender == owner());
        _safeMint(msg.sender, tokenCounter);
        // 1. SVG format > data:XXX
        string memory imageURI = svgToImageURI(svg);
        // 2. ERC721Metadata func to make it in token URI form
        _setTokenURI(tokenCounter, formatTokenURI(imageURI));
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
