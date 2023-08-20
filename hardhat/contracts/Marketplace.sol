// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Marketplace is ERC721URIStorage {

    address payable owner;
    uint public _tokenIds;
    uint private _itemSold;

    uint  public listingPrice=0.01 ether;

    struct TokenData{
        uint tokenId;
        address payable seller;
        address payable owner;
        uint price;
        bool sold;
    }

    mapping(uint=>TokenData) public idToTokenData;

    constructor() ERC721("NFTMarketplace", "NFTM"){
        owner=payable(msg.sender);

    }

    function updateListPrice(uint256 _listPrice) public payable {
        require(owner == msg.sender, "Only owner can update listing price");
        listingPrice=_listPrice;
    }

       function getListedTokenForId(uint256 tokenId) public view returns (TokenData memory) {
        return idToTokenData[tokenId];
    }

     function getCurrentToken() public view returns (uint256) {
        return _tokenIds;
    }


    function createToken(string memory tokenURI, uint256 price) public payable returns (uint) {
        
       uint newTokenId=_tokenIds++;
  

    _safeMint(msg.sender,newTokenId);
   
    _setTokenURI(newTokenId,tokenURI);
     createMarketToken(newTokenId,price);
     return newTokenId;


      }

      function createMarketToken(uint _tokenId,uint _price) public payable{
        require(msg.value >= listingPrice,"Listing price must be given");
        require(_price >0,"Price must not be zero");

        idToTokenData[_tokenId]=TokenData(
            _tokenId,
            payable(msg.sender),
            payable(address(this)),
            _price,
            false
        );

        _transfer(msg.sender,address(this),_tokenId);
      }



     function getAllNFTs() public view returns (TokenData[] memory) {

         uint tokenCount=_tokenIds;

         TokenData[] memory tokens=new TokenData[](tokenCount);
         
         uint currentIndex=0;
         uint currentId;

         for(uint i=0;i< tokenCount;i++)
         {
            currentId=i;
            TokenData storage token=idToTokenData[currentId];

        tokens[currentIndex]=token;
        currentIndex++;

             
         }
         return tokens;
}


function getMyNFTs() public view returns (TokenData[] memory) {

    uint tokensCount=_tokenIds;

    uint currentIndex=0;
    uint itemCount=0;

    uint currentId;

    for(uint i=0;i<tokensCount;i++)
    {
        if(idToTokenData[i].owner == msg.sender || idToTokenData[i].seller == msg.sender)
        {
            itemCount++;
        }
    }

    TokenData[] memory tokens=new TokenData[](itemCount);

    for(uint i=0;i<=itemCount;i++)
    {
        if(idToTokenData[i].owner == msg.sender || idToTokenData[i].seller == msg.sender)
        {
            currentId=i;
            TokenData storage token=idToTokenData[currentId];
            tokens[currentIndex]=token;
            currentIndex++;
        }
    }

    return tokens;
}


   function purchaseToken(uint _tokenId) public payable{

       uint price=idToTokenData[_tokenId].price;
       address seller=idToTokenData[_tokenId].seller;
       require(msg.value >= price,"Price must be greater than the token value");
       require(!idToTokenData[_tokenId].sold,"Token was already sold");

       idToTokenData[_tokenId].sold=true;
       idToTokenData[_tokenId].owner=payable(msg.sender);
       idToTokenData[_tokenId].seller=payable(address(0));

       _transfer(address(this),msg.sender,_tokenId);

        payable(seller).transfer(msg.value);

   }

}