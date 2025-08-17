// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract Crowdfunding {
    // Kontraktets (och insamlingens) ägare.
    address public owner;

    // Målsumma för insamlingen (i wei).
    uint public goal;

    // Sista tidpunkt för att skicka in bidrag.
    uint public deadline;

    // Bool som indikerar om målet är uppnått eller inte.
    bool public goalReached;

    // Den totala summan som hittills har samltas in.
    uint public currentBalance;

    // Mapping som håller reda på hur mycket varje adress har bidragit med.
    mapping(address => uint) public donations;

    // Konstruktor, som sätter de initiala värdena vid deployment av kontraktet.
    // Vi anger målsumman och antal dagar som insamlingen ska pågå.
    constructor(uint fundingGoal, uint durationInDays) {
        owner = msg.sender;
        goal = fundingGoal;
        deadline = block.timestamp + (durationInDays * 1 days);
        goalReached = false;
        currentBalance = 0;
    }

    // Funktion för att bidra till insamlingen.
    // Vi skriver payable eftersom vi vill att denna funktion ska kunna ta emot Ether.
    function contribute() public payable {
        require(block.timestamp < deadline, "The deadline has passed!");

        // Uppdaterar vår mapping och kontots saldo utifrån givare och bidrag.
        donations[msg.sender] += msg.value;
        currentBalance += msg.value;

        // Vi sätter goalReached till true om målsumman har uppnåtts.
        if(currentBalance >= goal) {
            goalReached = true;
        }
    }

    // Funktion för att ta ut pengar från kontraktet.
    // Ägaren kan ta ut pengarna om målet är uppnått.
    // Annars kan de som bidragit ta tillbaka sina pengar efter deadline.
    function withdrawFunds() public {
        if (goalReached) {
            // Endast ägaren kan ta ut medel om målet är uppnått.
            require(msg.sender == owner, "Only the owner can withdraw the fund");
            
            // Re-entrancy skydd: Nollställ balansen innan överföring.
            // Detta förhindrar att någon försöker anropa funktionen igen innan balansen har hunnit nollställas.
            uint amountToTransfer = currentBalance;
            currentBalance = 0;

            payable(owner).transfer(amountToTransfer);
        } else {
            // Givare får tillbaka sina pengar om målet inte har uppnåtts.
            require(block.timestamp >= deadline, "The fundraising is still ongoing");

            // Re-entrancy skydd även här: Nollställ först, skicka sedan.
            uint amountToTransfer = donations[msg.sender];
            donations[msg.sender] = 0;
            currentBalance -= amountToTransfer;

            payable(msg.sender).transfer(amountToTransfer);
        }
    }
}