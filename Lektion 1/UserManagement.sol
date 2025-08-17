// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract UserManagement {
    // Vi skapar ett struct för våra användare, där vi kan samla information om användarens namn och ålder.
    struct User {
        string name;
        uint8 age;
    }

    // Vi skapar en mapping där key är användarens adress och värdet är en User struct. Mappingen får namnet users.
    mapping(address => User) public users;

    // Funktion för att registrera en användares namn och ålder
    function setUserProfile(string memory userName, uint8 userAge) public {
        // För vår key (adressen som anropar funktionen, msg.sender) sparar vi värdena från parametrarna i vår mapping users.
        users[msg.sender] = User(userName, userAge);
    }
}