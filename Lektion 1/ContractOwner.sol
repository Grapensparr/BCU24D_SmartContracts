// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract ContractOwner {
    // State variabel av typen address.
    // Globala variabeln msg.sender används här för att sätta det initiala värdet av owner till den adress som deployar kontraktet.
    address public owner = msg.sender;

    // Vi skickar in en adress som en parameter/lokal variabel (newOwner) och uppdaterar vår state variabel (owner).
    function updateOwner(address newOwner) public {
        // Require används för att säkerställa att endast den nuvarande ägaren kan uppdatera ägarskapet.
        require(msg.sender == owner, "Only the current owner can update the ownership");

        owner = newOwner;
    }
}