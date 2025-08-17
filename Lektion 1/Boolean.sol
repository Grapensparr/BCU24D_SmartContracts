// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract Boolean {
    // State variabel av typen boolean.
    bool public isActive = false;

    // Vi skickar in en boolean som en parameter/lokal variabel (state) och uppdaterar vår state variabel (isActive).
    function setState(bool state) public {
        isActive = state;
    }
}