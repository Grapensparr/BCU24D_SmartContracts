// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract Counter {
    // State variabel av typen uint.
    // Det går att ändra till int om man vill tillåta negativa tal.
    uint public count = 0;

    // Funktion för att öka värdet på count med siffran 1.
    // Funktionen innehåller tre exempel på hur man kan skriva, men resultatet blir detsamma.
    function incrementCount() public {
        // count = count + 1;
        // count++;
        count += 1;
    }

    // Funktion för att öka värdet på count med angivet tal.
    // Vi skickar in en uint som en parameter/lokal variabel (number) och uppdaterar vår state variabel (count).
    // Glöm inte att ändra parametern number till int om ni ändrar state variabeln count till int.
    // Funktionen innehåller två exempel på hur man kan skriva, men resultatet blir detsamma.
    function incrementByNumber(uint number) public {
        // count = count + number;
        count += number;
    }

    // Funktion för att minska värdet på count med siffran 1.
    // Funktionen innehåller tre exempel på hur man kan skriva, men resultatet blir detsamma.
    function decrementCount() public {
        // count = count - 1;
        count--;
        // count -= 1;
    }
}