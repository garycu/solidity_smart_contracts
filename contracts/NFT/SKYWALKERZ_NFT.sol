// SPDX-License-Identifier: GPL-3.0

/*

                                                                                                                                                      
                                                                                                                                                                                                                                                                                  
                                                                                                                 
              IhKIU2X5P1  K2Ks  :5SS   i51SKXSZ        :X2P   iIKQi  uISY   U1Uu17:      iPQBd7                                 
             :BBBBBBQBQB .BBBX  QBQB   BBBBBBBB        BBBB  uBBBK  rBQBJ  .BBBBBBBB    BBBBBBBB                                
             .Yi1BBBdiv  IBQB   BBBS   BBBL:ii.        BBBj hBBB:   BBBB   2BBB.:BBBB  2BBB  QBQi                               
                :BBB     BBBB  .BBB.  :BBB             BBB:bBBQ     BBBB   BQB5  LQBB  BQBB  BBB                                
                BBBB     BBBE  bBBB   DBBB .:         vBBBBQBQ     .BBB7   BBB:  7BBB  .BBBB                                    
                BBBr    rBBBBBBBBBd   BBBBBBB         BBBBQBB      PBBQ   rBBB   BBBB    BBBQi                                  
               vBBB     BBBBBQBBBQ:  :BBBQQB:         BQBBBQB.     BBBB   BQBB   QBB2     7BBBY                                 
               BQBB     BBBI  PBBB   gBBB            iBBB BBBB     BBBY   BBQ7  rBBB  sJY  JQBB                                 
               BBQ7    iBBB   BBBQ   BBBY            RBBB :BBBr   7BBB.  :BQB   BBBB  BBB   BBB:                                
              vBBB     BBBB  :BBQ7  .BBBBBBBr        BQB5  BBBB   BBBB   BBBBIKBBBB   BBBX gBBB                                 
              BBBB    .BBBb  MBBB.  QBBBBBBB:       rBBQ:  :BBBB .BBBB   BBBBBBBBQ    LQBBBBBBv                                 
              r::.     i:i   :i::   ::::.::i        .i:i    :::7  ::i.   :.::::.        iYYv:                                   
                                                                                                                                
                                                                                                                                
                                                                                                                                
                                                                                                                                
         EBBQ   ...   BQBZ  BQBd   BBBQ     7QBB:           BQBg     LBBBBBBB     5BBB     .BBBBBZv                             
         BBBB  :QBP  gBBB. rBBBv  .BBBu     BBBB           :QBBu     BBBBBBBB    rBBBB.    MBBBBBBQB                            
         BBBP  BBB1  BBBL  QBBB   2BBQ      BBBS           5BBB      BBQ:        BBBBB.    QBB1 .BBBK                           
         BBBr IBBBr gBBB   BQBB   BBQB     :QBB.           BBBQ     :BBB        BBBBBB.    BBB   BBBQ                           
         BBB  BBBB. BQB.  .BBB7   BBBr     PBBB            BBBr     ZBBBrYU    IBQJvBQ:   vBBB   BBQE                           
         BBB.BBBBBrbQBU   KBBB   rBBB      BBBD           rBBB      BBBBBBB   .BBB vBBi   BBQM   BBBr                           
         BBQBBB BBBBBB    BBBB   BBBB     :BBBi           BBBB     :BQBj7Y.   BQB. KBBv   BQBi  rBBB.                           
         BBBBB. BBQBB.    BBBJ   BBB1     2BBB            BBBj     MBBB      2BBBs:BBBL  7BBB   BBQB                            
         BBBBP  BBBBM    vBBB.  iBBB.     BBBB           iBBB.     BBBK     .BBQBBBQBBu  BBBQ  2BBB.                            
        .BBBB   BBBB     BBBB   BBBBBBBB .BBBBBBB:       BBBBBBBQ .BBBBBBBr BBBB.::BBBP  BBBBBBBBB1                             
        :BBBi   BBBL    .BBQB   BQBBBBBv hBBBBBBB        BBQBQBBL PBBBBBBB MBBB.   QBBB 7BBBBBBBB:                                                                                                                                                                                                                                                                                                                                                   
                                                                                                                                                                                                                                                                                        

 */

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SKYWALKERZ_NFT is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string public baseURI;
  string public baseExtension = ".json";
  uint256 public cost = .01 ether;
  uint256 public maxSupply = 4060;
  // How many NFTs can be purchasable (via the minting site or directly from this smart contract)
  uint256 public maxNumberPurchasable = 2030;
  uint256 public maxMintAmountPerSession = 10;
  uint256 public nftPerAddressLimit = 30;
  // How many NFTs were bought (via the minting site or directly via this smart contract)
  uint256 public totalNftsBoughtFromContract = 0;
  bool public paused = false;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  // public
  function mint(uint256 _mintAmount) public payable {
    require(!paused, "the contract is paused");
    uint256 supply = totalSupply();
    require(_mintAmount > 0, "need to mint at least 1 NFT");
    require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

    if (msg.sender != owner()) {
        uint256 ownerTokenCount = balanceOf(msg.sender);
        require(ownerTokenCount + _mintAmount <= nftPerAddressLimit, "max NFT per address exceeded");
        require(_mintAmount <= maxMintAmountPerSession, "max mint amount per session exceeded");
        require(msg.value >= cost * _mintAmount, "insufficient funds");
        require(totalNftsBoughtFromContract + _mintAmount <= maxNumberPurchasable, "max number of purchasable NFTs exceeded");
        totalNftsBoughtFromContract = totalNftsBoughtFromContract + _mintAmount;
    }

    for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(msg.sender, supply + i);
    }
  }
  
  // onlyOwner
  function mintToAddress(address to, uint256 _mintAmount) public onlyOwner() {
    uint256 supply = totalSupply();
    require(_mintAmount > 0, "need to mint at least 1 NFT");
    require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");
    for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(to, supply + i);
    }
  }


  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }
  
  function setNftPerAddressLimit(uint256 _limit) public onlyOwner() {
    nftPerAddressLimit = _limit;
  }
  
  function setCost(uint256 _newCost) public onlyOwner() {
    cost = _newCost;
  }

  function setMaxMintAmountPerSession(uint256 _newMaxMintAmountPerSession) public onlyOwner() {
    maxMintAmountPerSession = _newMaxMintAmountPerSession;
  }

  function setMaxNumberPurchasable(uint256 _newMaxNumberPurchasable) public onlyOwner() {
    maxNumberPurchasable = _newMaxNumberPurchasable;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
 
  function withdraw() public payable onlyOwner {
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(success);
  }
}
