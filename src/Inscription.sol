// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ERC20} from "./ERC20.sol";

contract Inscription is ERC20 {
    address _owner;

    uint256 _perMint;

    uint256 _price;

    uint _feeRatio;

    uint256 _maxSupply;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function owner() public view returns (address) {
        return _owner;
    }

    function perMint() public view returns (uint256) {
        return _perMint;
    }

    function price() public view returns (uint256) {
        return _price;
    }

    function feeRatio() public view returns (uint) {
        return _feeRatio;
    }
    
    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }

    function initialize(
        address owner,
        string memory name,
        string memory symbol,
        uint totalSupply,
        uint perMint,
        uint256 price,
        uint feeRatio,
        uint256 maxSupply
    ) public {
        _owner = owner;
        _name = name;
        _symbol = symbol;
        _totalSupply = totalSupply;
        _perMint = perMint;
        _price = price;
        _feeRatio = feeRatio;
        _maxSupply = maxSupply;
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
