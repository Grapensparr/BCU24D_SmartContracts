// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

// Library som innehåller enkla matematiska funktioner.
// Ett library kan återanvändas av flera kontrakt och gör koden mer modulär.
library MathLibrary{
    // Funktion för addition.
    // Tar två uint som parametrar och returnerar summan.
    function _add(uint a, uint b) internal pure returns(uint) {
        return a + b;
    }

    // Funktion för subtraktion.
    // Tar två uint som parametrar och returnerar skillnaden.
    function _subtract(uint a, uint b) internal pure returns(uint) {
        return a - b;
    }

    // Funktion för multiplikation.
    // Tar två uint som parametrar och returnerar produkten.
    function _multiply(uint a, uint b) internal pure returns(uint) {
        return a * b;
    }
}

// Kontrakt som använder MathLibrary för att utföra beräkningar.
contract Calculator{
    // "using for" gör att vi kan anropa library-funktioner direkt på uint-värden.
    // Exempel: a._add(b) istället för MathLibrary._add(a, b).
    using MathLibrary for uint;

    // Funktion för addition.
    function add(uint a, uint b) public pure returns(uint) {
        // Två sätt att skriva: Anropa direkt via library eller via "using for".
        return MathLibrary._add(a, b);
        // return a._add(b);
    }

    function stubtract(uint a, uint b) public pure returns(uint) {
        return MathLibrary._subtract(a, b);
        // return a._subtract(b);
    }

    function multiply(uint a, uint b) public pure returns(uint) {
        return MathLibrary._multiply(a, b);
        // return a._multiply(b);
    }
}