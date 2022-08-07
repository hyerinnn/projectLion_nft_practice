// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Lion {

    string public name = "klayLion";
    uint256 public totalSupply = 10;
    address public owner;
    mapping (uint256 => string) public tokenURI;


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

    function setTokenUri(uint256 id, string memory uri) public {
        tokenURI[id] = uri;

    }
}