// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./base64.sol";

contract SVGtoNFT is ERC721URIStorage, Ownable {
    // Incremental counter of token ID and we iterate
    uint public tokenCounter;
    
    // Emits event on NFT create()
    event CreatedSVGNFT(uint256 indexed tokenId, string tokenURI);
    // Emits event on NFT transfer
    event TransferredSVGNFT(uint256 indexed tokenId, address to);

    // Ad struct
    struct Ad {
	address minter; // Whoever minted this NFT
	address landOwner; // Currentlty where the ad is
	uint32 landx; // x cor of land
	uint32 landy; // y cor of land
	uint32 expiryDate; // When this ad expires
    }
    // stores an `Ad` struct. tokenID corresponds to the index.
    Ad[] public ads;
    
    // Setting expiry of ad
    uint expiryDuration = 1 weeks;
    
    constructor() ERC721("SVG on-chain NFT", "svgNFT")
    {
        tokenCounter = 0;
    }

    // Mint a new NFT with token URI
    // 1. SVG > Image URI
    // 2. Image URI > Token URI format
    // 3. Create with Token URI
    function create(string memory svg) public {
        _safeMint(msg.sender, tokenCounter);
        // 1. SVG format > data:XXX
        string memory imageURI = svgToImageURI(svg);
        // 2. ERC721Metadata func to make it in token URI form
        _setTokenURI(tokenCounter, formatTokenURI(imageURI));
        
	// Add an ad to array
	// Default land coordinate = 0,0
	// Expiry is set to max of uint
	ads.push(Ad(msg.sender, msg.sender, 0, 0, 4294967295));
        
        tokenCounter = tokenCounter + 1;
        emit CreatedSVGNFT(tokenCounter, svg);
    }
    
    // 1. SVG > Image URI
    function svgToImageURI(string memory svg) public pure returns (string memory) {
        // Prefix of Image
        string memory baseURL = "data:image/svg+xml;base64,";
    
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(baseURL,svgBase64Encoded));
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
    
    // Check expiry and return bool
    function _expiryCheck(Ad storage _ad) internal view returns (bool) {
      return (_ad.expiryDate <= block.timestamp);
    }
    
    // Show expiry of NFT
    function getExpiry(uint _tokenID) internal view returns (uint32) {
      return ads[_tokenID].expiryDate;
    }
    
    // Send NFT from one to another
    function sendNFT(address _to, uint _tokenID) external{
        require(msg.sender == ads[_tokenID].minter,"Only minter can transfer");
        // ERC721 function that transfers owner
	transferFrom(msg.sender, _to, _tokenID);
	// Change ads array info
        ads[_tokenID].landOwner = _to;
	    ads[_tokenID].expiryDate = uint32(block.timestamp + expiryDuration);
	
	//TBD
	//Set land coordinate
	
        emit TransferredSVGNFT(_tokenID, _to);
    }
    
    // Check expiry and send the ad back to owner
    function sendBackNFT(uint _tokenID) external{
	    require(msg.sender == ads[_tokenID].minter,"Only minter can transfer");
	    Ad storage myad = ads[_tokenID];
	    require(_expiryCheck(myad));
	    // Send back the NFT
	    transferFrom(msg.sender, msg.sender, _tokenID);
    }
    
    // Check NFts you have. Returns an array of tokenIDs 
    function getMyNFT(address _myAddress) external view returns (uint[] memory) {
    	uint[] memory result = new uint[](ads.length);
	    uint counter = 0;
    	for (uint i = 0; i < ads.length; i++) {
    		if (ads[i].landOwner == _myAddress) {
    			result[counter] = i;
			    counter++;
		    }
	    }
	return result;
    }
}
