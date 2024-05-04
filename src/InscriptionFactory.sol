// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import "./Inscription.sol";

contract InscriptionFactory {
    using Clones for address;

    address target;

    address public immutable owner;

    error DuplicatedAddressDeploy();

    constructor(address erc20) {
        target = erc20;
        owner = msg.sender;
    }

    function deployInscription(
        string memory name,
        string memory symbol,
        uint totalSupply,
        uint perMint,
        uint256 price,
        uint feeRatio,
        uint256 maxSupply
    ) public returns (address) {
        // clone the ERC2O token by clone method
        address proxy = target.clone();

        // Initialize cloned inscription
        Inscription(proxy).initialize(
            owner,
            name,
            symbol,
            totalSupply,
            perMint,
            price,
            feeRatio,
            maxSupply
        );

        return proxy;
    }

    error ExceedsPerMint();

    error ExceedsTotalSupply();

    error PriceNotEnough();

    function mintInscription(address tokenAddr) external payable {
        Inscription proxy = Inscription(tokenAddr);
        if (proxy.totalSupply() + proxy.perMint() > proxy.maxSupply()) revert ExceedsTotalSupply();

        // Mint user must pay the total eth, else revert FeeNotEnough error
        uint256 totalPrice = proxy.perMint() * proxy.price();
        if (msg.value < totalPrice) revert PriceNotEnough();
        
        // Calculate the fee by the fee ratio
        uint256 fee = totalPrice * proxy.feeRatio() / 100;
        require(fee > 0, "Fee is must greater than 0");

        // Project part shuold transfer the fee to token owner, that means project part totol price = totalPrice - fee
        (bool success, ) = proxy.owner().call{value: fee}("");
        require(success, "Failed to transfer fee to owner");
        proxy.mint(msg.sender, proxy.perMint());
    }
}
