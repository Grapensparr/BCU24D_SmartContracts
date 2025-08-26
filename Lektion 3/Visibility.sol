// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract Visibility {
    // Publika funktioner kan anropas både utifrån och inifrån kontraktet.
    function publicFunction() public pure returns(string memory) {
        return "This is a public function";
    }

    // Interna funktioner kan endast anropas inifrån kontraktet.
    // De ärvs vidare till barnkontrakt.
    function _internalFunction() internal pure returns(string memory) {
        return "This is an internal function";
    }

    // Privata funktioner kan endast anropas inifrån kontraktet.
    // De ärvs INTE vidare till barnkontrakt.
    function _privateFunction() private pure returns(string memory) {
        return "This is a private function";
    }

    // Externa funktioner kan endast anropas utifrån kontraktet.
    // De kan inte anropas internt (om vi inte använder oss av this).
    function externalFunction() external pure returns(string memory) {
        return "This is an external function";
    }

    // Exempel på hur en intern funktion kan anropas via en publik funktion.
    function callInternalFunction() external pure returns(string memory) {
        return _internalFunction();
    }

    // Exempel på hur en privat funktion kan anropas via en publik funktion.
    function callPrivateFunction() external pure returns(string memory) {
        return _privateFunction();
    }

    // Exempel på hur man kan anropa en extern funktion inifrån kontraktet.
    // Det kräver att man använder this (dvs ett externt anrop).
    function callExternalFunction() public returns(string memory) {
        return this.externalFunction();
    }

    // En funktion markerad som virtual kan skrivas över (override) i ett barnkontrakt.
    function greeting() public pure virtual returns(string memory) {
        return "Hello from your parent!";
    }
}

contract VisibilityChild is Visibility {
    // Kan anropa den interna funktionen från föräldern.
    function callInternalParentFunction() public pure returns(string memory) {
        return _internalFunction();
    }

/*  Detta går INTE eftersom privata funktioner inte ärvs.
    function callPrivateParentFunction() public pure returns(string memory) {
        return _privateFunction();
    } */

/*  Exempel på hur man kan skriva över en funktion från föräldern.
    Kräver att förälderns funktion är virtual och att denna är override.   
    function greeting() public pure override returns(string memory) {
        return "Hello from your child!";
    } */

   // Använder greeting(), kommer anropa versionen som är aktiv i kontraktet.
    function showGreeting() public pure returns(string memory) {
        return greeting();
    }
}