// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/VM.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {Inscription} from "../src/Inscription.sol";
import {InscriptionFactory} from "../src/InscriptionFactory.sol";

contract InscriptionFactoryTest is Test {
    InscriptionFactory factory;
    Inscription target;
    address owner;
    address minter1;
    address minter2;

    function setUp() public {
        owner = makeAddr("owner");
        minter1 = makeAddr("minter1");
        minter2 = makeAddr("minter2");
        deal(minter1, 10 ** 20);
        deal(minter2, 10 ** 10);
        target = new Inscription("ERC20", "ERC20");
        vm.prank(owner);
        factory = new InscriptionFactory(address(target));
    }

    function testDeployInscription() public {
        // Create a Inscription token by InscriptionFactory
        address inscription = factory.deployInscription(
            "OpenSpace Inscription",
            "OSI",
            0,
            10000,
            10000,
            10,
            10000000
        );

        // Get Inscription instance by inscription address
        Inscription proxy = Inscription(inscription);

        // Inscription address should not equals ERC20 address
        assertNotEq(address(target), address(proxy));
        assertEq(proxy.symbol(), "OSI");
        assertEq(proxy.perMint(), 10000);
        assertEq(proxy.price(), 10000);
        assertEq(proxy.feeRatio(), 10);
    }

    function testMintInscription() public {
        //  Mock perMint is greater than the totalSupply
        vm.startPrank(owner);
        // Create a Inscription token by InscriptionFactory
        address inscription1 = factory.deployInscription(
            "OpenSpace Inscription",
            "OSI",
            0,
            100000000,
            10000,
            10,
            10000000
        );
        vm.stopPrank();

        vm.startPrank(minter1);
        vm.expectRevert(
            abi.encodeWithSelector(Inscription.ExceedsTotalSupply.selector)
        );
        factory.mintInscription(inscription1);
        vm.stopPrank();

        // Mock if msg.value is not engough
        vm.startPrank(owner);
        // Create a Inscription token by InscriptionFactory
        address inscription2 = factory.deployInscription(
            "OpenSpace Inscription",
            "OSI",
            0,
            100000,
            1000,
            10,
            10000000
        );
        // Get Inscription instance by inscription address
        vm.stopPrank();

        vm.startPrank(minter1);
        vm.expectRevert(
            abi.encodeWithSelector(Inscription.PriceNotEnough.selector)
        );
        factory.mintInscription{value: 100000 * 1}(inscription2);
        vm.stopPrank();

        // Mock if owner fee is right and project fee is right
        vm.startPrank(owner);
        // Create a Inscription token by InscriptionFactory
        address inscription3 = factory.deployInscription(
            "OpenSpace Inscription",
            "OSI",
            0,
            100000,
            1000,
            10,
            10000000
        );
        vm.stopPrank();

        vm.startPrank(minter1);
        console.log("Minter1 before mint balance:", minter1.balance);
        console.log("Owner balance before mint by minter1:", owner.balance);
        console.log(
            "Project party balance before mint by minter1:",
            address(factory).balance
        );
        console.log("========================================================");
        factory.mintInscription{value: 100000 * 1000}(inscription3);
        console.log("Minter1 after mint balance:", minter1.balance);
        console.log("Owner balance after mint by minter1:", owner.balance);
        console.log(
            "Project party balance after mint by minter1:",
            address(factory).balance
        );
        assertEq(minter1.balance, 99999999999900000000);
        assertEq(owner.balance, 10000000);
        assertEq(address(factory).balance, 90000000);
        vm.stopPrank();

        console.log(
            "###########################################################"
        );

        vm.startPrank(minter2);
        console.log("Minter2 before mint balance:", minter2.balance);
        console.log("Owner balance before mint by minter2:", owner.balance);
        console.log(
            "Project party balance before mint by minter2:",
            address(factory).balance
        );
        console.log("========================================================");
        factory.mintInscription{value: 100000 * 1000}(inscription3);
        console.log("Minter2 after mint balance:", minter2.balance);
        console.log("Owner balance after mint by minter2:", owner.balance);
        console.log(
            "Project party balance after mint by minter2:",
            address(factory).balance
        );
        assertEq(minter2.balance, 9900000000);
        assertEq(owner.balance, 20000000);
        assertEq(address(factory).balance, 180000000);
        vm.stopPrank();
    }
}
