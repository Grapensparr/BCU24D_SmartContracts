// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract Wallet {
    // State variabel som håller koll på kontraktets saldo.
    uint public contractBalance;

    // Mapping för att hålla reda på varje adress individuella saldo.
    mapping(address => uint) internal _balances;

    // Bool används som ett lås för att förhindra reentrancy-attacker.
    bool private _locked; 

    // Event för insättning.    
    event DepositMade(address indexed accountAddress, uint amount);

    // Event för uttag.
    event WithdrawalMade(address indexed accountAddress, uint amount);

    // Modifier för att säkerställa skydd mot reentrancy-attacker.
    // Låset aktiveras när funktionen startar och släpps efter att funktionen har körts klart.
    modifier noReentrancy() {
        require(!_locked, "Stop making re-entracy calls. Please hold");
        _locked = true;
        _;
        _locked = false;
    }

    // Modifier som gör att vi kan kontrollera om anroparen har ett tillräckligt högt saldo för angivet uttag.
    modifier hasSufficientBalance(uint withdrawalAmount) {
        require(_balances[msg.sender] >= withdrawalAmount, "You have an insufficient balance");
        _;
    }

    // Funktion för insättning av ETH till kontraktet.
    function deposit() public payable {
        _balances[msg.sender] += msg.value;
        contractBalance += msg.value;

        // Säkerhetskontroll (assert) där vi säkerställer att kontraktets lagrade saldo matchar kontraktets faktiska saldo.
        // Den ska ALLTID vara sann, annars innebär det finns ett allvarligt fel i logiken.
        assert(contractBalance == address(this).balance);

        // Event för insättning skickas iväg.
        emit DepositMade(msg.sender, msg.value);
    }

    // Funktion för uttag av ETH.
    // Skyddad med noReentrancy och hasSufficientBalance.
    function withdrawal(uint withdrawalAmount) public noReentrancy hasSufficientBalance(withdrawalAmount){
        // Tillåter max 1 ETH per transaktion, annars sker en revert.
        if(withdrawalAmount > 1 ether) {
            revert("You cannot withdraw more than 1 ETH per transaction");
        }

        _balances[msg.sender] -= withdrawalAmount;
        contractBalance -= withdrawalAmount;
        payable(msg.sender).transfer(withdrawalAmount);

        // Säkerhetskontroll där vi återigen säkerställer att kontraktets lagrade saldo matchar kontraktets faktiska saldo.
        assert(contractBalance == address(this).balance);

        // Event för uttag skickas iväg.
        emit WithdrawalMade(msg.sender, withdrawalAmount);
    }
}