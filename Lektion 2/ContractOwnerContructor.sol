// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract ContractOwnerConstructor {
    // State variabel av typen address, som håller koll på vem som äger kontraktet.
    address public owner;

    // Konstruktor, som anropas vid deployment och som i detta fall anger vem som ska vara kontraktets ägare.
    constructor(address contractOwner) {
        // Vi kan välja mellan två olika alternativ för att sätta kontraktets ägare.
        // Alternativ 1, där msg.sender (dvs den som deployar kontraktet) blir ägare. Vi behöver då ingen parameter/lokal variabel.
        //owner = msg.sender;

        // Alternativ två, där vi skickar in adressen på den vi vill ska vara ägare av kontraktet. Vi behöver här vår parameter/lokala variabel.
        owner = contractOwner;
    }

    // Funktion för att uppdatera kontraktets ägare.
    function updateOwner(address newOwner) public {
        // Endast den nuvarande ägaren får tillåtelse att byta ägarskap.
        require(msg.sender == owner, "Only the current owner can update the ownership");

        owner = newOwner;
    }
}