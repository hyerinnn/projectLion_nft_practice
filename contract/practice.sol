// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Lion {

    string public name = "klayLion";
    //uint256 public totalSupply = 10;
    //address public owner;

    mapping (uint256 => string) public tokenURIs;
    mapping (uint256 => address) public tokenOwner;
    string public symbol = "KL";

    //소유한 토큰 리스트
    mapping (address => uint256[]) private _ownedTokens;

 /*
    constructor()  {
        owner = msg.sender;
    }

    function getTotalSupply() public view returns (uint256){

        return totalSupply + 1000000;
    }

    function setTotalSupply(uint256 newSupply) public {
        require(owner == msg.sender, 'not owner');
         totalSupply = newSupply;
    }
*/

    // to에게 tokenId를 발행하겠다.
    function mintWithTokenURI(address to, uint256 tokenId, string memory tokenURI) public returns (bool){
        tokenOwner[tokenId] = to;
        tokenURIs[tokenId] = tokenURI;

        // 소유한 토큰리스트에 추가
        _ownedTokens[to].push(tokenId);
        
        return true;
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public{
        // 보낸사람이 from 주소와 똑같아야함
        require(from == msg.sender, "from != msg.sender");
        // 보낸사람이 토큰 소유주여야 함
        require(from == tokenOwner[tokenId], "you are not the owner of the token");
        
        _removeTokenFromList(from, tokenId);
        _ownedTokens[to].push(tokenId);
        
        tokenOwner[tokenId] = to;
    
    }

    // 소유한 리스트에서 토큰 삭제
    function _removeTokenFromList(address from, uint256 tokenId) private {
            // [10, 22, 19, 20]  -> 19를 삭제하고 싶어
            // [10, 22, 20, 19]  
            // [10, 22, 20]

        uint256 lastTokenIndex = _ownedTokens[from].length - 1;

        for(uint256 i=0; i<_ownedTokens[from].length; i++){
            if(tokenId == _ownedTokens[from][i]){

                _ownedTokens[from][i] = _ownedTokens[from][lastTokenIndex];
                _ownedTokens[from][lastTokenIndex] = tokenId;
                break;
            }   
        }

        _ownedTokens[from].length -1;
    }


    function ownedTokens(address owner) public view returns (uint256[] memory){
        return _ownedTokens[owner];
    }

    function setTokenUri(uint256 id, string memory uri) public {
        tokenURIs[id] = uri;

    }
}