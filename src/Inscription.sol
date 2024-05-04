// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ERC20} from "./ERC20.sol";

contract Inscription is ERC20 {
    address _owner;

    uint256 _perMint;

    uint256 _price;

    uint _feeRatio;

    error ExceedsPerMint();

    error ExceedsTotalSupply();

    error PriceNotEnough();

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function owner() public view returns (address) {
        return _owner;
    }

    function perMint() public view returns (uint) {
        return _perMint;
    }

    function price() public view returns (uint) {
        return _price;
    }

    function feeRatio() public view returns (uint) {
        return _feeRatio;
    }

    function initialize(
        address owner,
        string memory name,
        string memory symbol,
        uint totalSupply,
        uint perMint,
        uint256 price,
        uint feeRatio
    ) public {
        _owner = owner;
        _name = name;
        _symbol = symbol;
        _totalSupply = totalSupply;
        _perMint = perMint;
        _price = price;
        _feeRatio = feeRatio;
    }

    function mint(address to, uint256 amount) public payable {
        _mint(to, amount);
    }
}
