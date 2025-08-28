// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract Wallet {
    uint public contractBalance;
    mapping(address => uint) internal _balances;
    bool private _locked; 

    event DepositMade(address indexed accountAddress, uint amount);
    event WithdrawalMade(address indexed accountAddress, uint amount);
    event FallbackCalled(address indexed accountAddress);

    modifier noReentrancy() {
        require(!_locked, "Stop making re-entracy calls. Please hold");
        _locked = true;
        _;
        _locked = false;
    }

    modifier hasSufficientBalance(uint withdrawalAmount) {
        require(_balances[msg.sender] >= withdrawalAmount, "You have an insufficient balance");
        _;
    }

    fallback() external {
        emit FallbackCalled(msg.sender);
        revert("Fallback function called. This function does not exist. Try another one.");
    }

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        _balances[msg.sender] += msg.value;
        contractBalance += msg.value;

        assert(contractBalance == address(this).balance);

        emit DepositMade(msg.sender, msg.value);
    }

    function withdrawal(uint withdrawalAmount) public noReentrancy hasSufficientBalance(withdrawalAmount){
        if(withdrawalAmount > 1 ether) {
            revert("You cannot withdraw more than 1 ETH per transaction");
        }

        _balances[msg.sender] -= withdrawalAmount;
        contractBalance -= withdrawalAmount;
        payable(msg.sender).transfer(withdrawalAmount);

        assert(contractBalance == address(this).balance);
        emit WithdrawalMade(msg.sender, withdrawalAmount);
    }
}