// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.24 <=0.5.6;

contract NFTSimple {

    string public name = "klayLion";
    //uint256 public totalSupply = 10;
    //address public owner;

    mapping (uint256 => string) public tokenURIs;
    mapping (uint256 => address) public tokenOwner;
    string public symbol = "KL";

    //소유한 토큰 리스트
    mapping (address => uint256[]) private _ownedTokens;
    bytes4 private constant _KIP17_RECEIVED = 0x6745782b;

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

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public{
        // 보낸사람이 from 주소와 똑같아야함
        require(from == msg.sender, "from != msg.sender");
        // 보낸사람이 토큰 소유주여야 함
        require(from == tokenOwner[tokenId], "you are not the owner of the token");
        
        _removeTokenFromList(from, tokenId);
        _ownedTokens[to].push(tokenId);
        
        tokenOwner[tokenId] = to;

        // 만약에 받는 쪽이 실행할 코드가 있는 스마트 컨트랙트이면 코드를 실행할것
        require(
            _checkOnKIP17Received(from, to, tokenId, _data),
            "KIP17: transfer to non KIP17Receiver implementer"
        );

    }

    function _checkOnKIP17Received( address from, address to, uint256 tokenId, bytes memory _data) internal returns (bool) {
        bool success;
        bytes memory returndata;

        if (!isContract(to)) {
            return true;
        }

        (success, returndata) = to.call(
            abi.encodeWithSelector(
                _KIP17_RECEIVED,
                msg.sender,
                from,
                tokenId,
                _data
            )
        );
        if (
            returndata.length != 0 &&
            abi.decode(returndata, (bytes4)) == _KIP17_RECEIVED
        ) {
            return true;
        }

        return false;
    }

    // address에 코드가 있는지 없는지를 판별해서 스마트 컨트랙트인지 판별
    function isContract(address account) internal view returns (bool) {


        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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


// 발행한 토큰을 이 컨트랙트로 보낼수 있음. 
contract NFTMarket {

    // 토큰 판매자
    mapping(uint256  => address) public seller;

    // 토큰 구매
    function buyNFT(uint256 tokenId, address NFT) public  returns(bool) {
        //판매한 사람한테 0.01클레이 전송
        // payable을 붙어야만 돈을 보낼 수 있음
        address payable receiver = address(uint160(seller[tokenId]));

        // 10  **  18peb = 1 klay
        // 10  **  16peb = 0.01klay
        receiver.transfer(10 ** 16);


        NFTSimple(NFT).safeTransferFrom(address(this), msg.sender , tokenId,  "0x00");

        return true;
    }

    // 마켓이 토큰을 받았을 때  판매자가 누구인지 기록해야함
    function onKIP17Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4) {

        seller[tokenId] = from;

        return bytes4(keccak256("onKIP17Received(address,address,uint256,bytes)"));

    }

}