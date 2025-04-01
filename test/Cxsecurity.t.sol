// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "../src/Cxsecurity.sol";
import "../src/HelperSecurity.sol";

contract W3CXIITest is Test {
    W3CXII public w3cxii;
    address user1 = vm.addr(1);
    address user2 = vm.addr(2);
    address attacker = vm.addr(3);

    function setUp() public {
        // Deploy with 1 ether as specified
        w3cxii = new W3CXII{value: 1 ether}();
    }

    function testInitialState() public view {
        assertEq(address(w3cxii).balance, 1 ether);
        assertEq(w3cxii.dosed(), false);
    }
    function testDeposit() public {
        vm.prank(user1);
        vm.deal(user1, 0.5 ether);
        w3cxii.deposit{value: 0.5 ether}();
        
        assertEq(w3cxii.balanceOf(user1), 0.5 ether);
        assertEq(address(w3cxii).balance, 1.5 ether);
    }
    function testDepositInvalidAmount() public {
        vm.prank(user1);
        vm.deal(user1, 0.5 ether);
        
        vm.expectRevert("InvalidAmount");
        w3cxii.deposit{value: 0.4 ether}();
    }
    // function testMaxDepositPerUser() public {
    //     // Use fresh contract to avoid deposit lock interference
    //     W3CXII freshContract = new W3CXII{value: 0.1 ether}();
        
    //     vm.prank(user1);
    //     vm.deal(user1, 1.5 ether);
    //     freshContract.deposit{value: 0.5 ether}();
    //     freshContract.deposit{value: 0.5 ether}(); // Total 1 ether for user1
        
    //     vm.expectRevert("Max deposit exceeded");
    //     freshContract.deposit{value: 0.5 ether}();
    // }
    // function testDepositLocked() public {
    //     // Use fresh contract to control initial balance
    //     W3CXII freshContract = new W3CXII{value: 0.1 ether}();
        
    //     // First deposit (0.5 ether) - Total: 0.6 ether
    //     vm.prank(user1);
    //     vm.deal(user1, 0.5 ether);
    //     freshContract.deposit{value: 0.5 ether}();
        
    //     // Second deposit (0.5 ether) - Total: 1.1 ether
    //     vm.prank(user2);
    //     vm.deal(user2, 0.5 ether);
    //     freshContract.deposit{value: 0.5 ether}();
        
    //     // Third deposit (0.5 ether) - Total: 1.6 ether
    //     vm.prank(user1);
    //     freshContract.deposit{value: 0.5 ether}();
        
    //     // Fourth deposit (0.5 ether) - Total: 2.1 ether (should lock)
    //     vm.prank(user2);
    //     freshContract.deposit{value: 0.5 ether}();
        
    //     // Verify deposit is now locked
    //     vm.prank(user1);
    //     vm.expectRevert("deposit locked");
    //     freshContract.deposit{value: 0.5 ether}();
    // }
    function testWithdraw() public {
        vm.prank(user1);
        vm.deal(user1, 0.5 ether);
        w3cxii.deposit{value: 0.5 ether}();
        
        uint initialBalance = user1.balance;
        vm.prank(user1);
        w3cxii.withdraw();
        
        assertEq(w3cxii.balanceOf(user1), 0);
        assertEq(user1.balance, initialBalance + 0.5 ether);
    }
    function testWithdrawNoDeposit() public {
        vm.prank(user1);
        vm.expectRevert("No deposit");
        w3cxii.withdraw();
    }
    function testDosedCondition() public {
        // First make a deposit
        vm.prank(user1);
        vm.deal(user1, 0.5 ether);
        w3cxii.deposit{value: 0.5 ether}();
        
        // Directly fund contract to 20 ether without triggering deposit lock
        vm.deal(address(w3cxii), 20 ether);
        
        vm.prank(user1);
        w3cxii.withdraw();
        
        assertEq(w3cxii.dosed(), true);
    }
    function testDestruct() public {
        // First set dosed to true
        vm.prank(user1);
        vm.deal(user1, 0.5 ether);
        w3cxii.deposit{value: 0.5 ether}();
        
        vm.deal(address(w3cxii), 20 ether);
        vm.prank(user1);
        w3cxii.withdraw();
        
        // Test destruct
        uint contractBalance = address(w3cxii).balance;
        uint attackerBalanceBefore = attacker.balance;
        
        vm.prank(attacker);
        w3cxii.dest();
        
        assertEq(attacker.balance, attackerBalanceBefore + contractBalance);
    }

    function testDestructNotDosed() public {
        vm.prank(attacker);
        vm.expectRevert("Not dosed");
        w3cxii.dest();
    }
}
contract DeployW3CXIITest is Test {
    W3CXII public target;
    DeployW3CXII public attacker;

    address payable user = payable(address(100)); // Mock user address

    function setUp() public {
        // Deploy W3CXII contract with 0 initial ETH
        target = new W3CXII();

        // Deploy DeployW3CXII with 20 ETH
        vm.deal(user, 20 ether); // Give user 20 ether
        vm.prank(user);
        attacker = new DeployW3CXII{value: 20 ether}();
    }

    function testForceEther() public {
        // Ensure W3CXII starts with 0 ether
        assertEq(address(target).balance, 0);

        // Send funds from DeployW3CXII to W3CXII
        vm.prank(user);
        attacker.send(payable(address(target)));

        // Verify W3CXII received 20 ether
        assertEq(address(target).balance, 20 ether);
    }
}