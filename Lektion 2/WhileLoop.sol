// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract WhileLoop {
    // Vi skapar en dynamisk array av datatypen uint, som får namnet numbers.
    uint[] public numbers;

    // Funktion för att lägga till ett nummer i vår numbers-array.
    // Vi skickar in en uint som parameter/lokal variabel och push:ar den till arrayen.
    function addNumber(uint number) public {
        numbers.push(number);
    }

    // Funktion för att summera alla nummer i vår numbers-array.
    function sumNumber() public view returns(uint) {
        // Lokal variabel där vi sparar summan.
        uint sum = 0;

        // Räknare för att hålla koll på index i arrayen.
        uint i = 0;

        // Vi använder en while-loop som körs så länge i är mindre än längden på arrayen.
        while (i < numbers.length) {
            // Under varje iteration lägger vi till värdet på nuvarande index i variabeln sum.
            sum += numbers[i];

            // Vi ökar i med 1, så att vi går vidare till nästa index i arrayen vid nästa iteration.
            i++;
        }

        // Vi returnerar summan.
        return sum;
    }
}