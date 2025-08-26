// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract MappingLibrary {
    struct Book {
        string title;
        uint16 year;
        bool exist;
    }

    mapping(string => mapping(string => Book)) public authorBooks;

    mapping(string => string[]) internal authorBookTitles;

    // Custom modifier, där vi säkerställer att boken inte redan finns för given författare och titel.
    // `_;` betyder "kör den anropade funktionen här om villkoret är uppfyllt".
    modifier bookDoesNotExist(string memory bookAuthor, string memory bookTitle) {
        require(!authorBooks[bookAuthor][bookTitle].exist, "Book already exists");
        _;
    }

    // Custom modifier, där vi säkerställer att boken finns innan vi uppdaterar eller tar bort den.
    modifier bookExists(string memory bookAuthor, string memory bookTitle) {
        require(authorBooks[bookAuthor][bookTitle].exist, "Book does not exists");
        _;
    }

    // Använder bookDoesNotExist(...) för att förhindra att dubbletter läggs till.
    function addBook(string memory bookAuthor, string memory bookTitle, uint16 publicationYear) public bookDoesNotExist(bookAuthor, bookTitle) {
        authorBooks[bookAuthor][bookTitle] = Book(bookTitle, publicationYear, true);
        authorBookTitles[bookAuthor].push(bookTitle);
    }

    function getBookCountByAuthor(string memory bookAuthor) public view returns(uint) {
        return authorBookTitles[bookAuthor].length;
    }

    // Använder bookExists(...) för att säkerställa att oldTitle finns, innan funktionen kan fortsätta.
    function updateBook(string memory bookAuthor, string memory oldTitle, string memory newTitle, uint16 newYear) public bookExists(bookAuthor, oldTitle){
        require(!authorBooks[bookAuthor][newTitle].exist, "New title already exists");

        if (keccak256(bytes(oldTitle)) != keccak256(bytes(newTitle))) {
            authorBooks[bookAuthor][newTitle] = Book(newTitle, newYear, true);
            delete authorBooks[bookAuthor][oldTitle];

            for (uint i = 0; i < authorBookTitles[bookAuthor].length; i++) {
                if (keccak256(bytes(authorBookTitles[bookAuthor][i])) == keccak256(bytes(oldTitle))) {
                    authorBookTitles[bookAuthor][i] = newTitle;
                    break;
                }
            }
        } else {
            authorBooks[bookAuthor][oldTitle].year = newYear;
        }
    }

    // Använder bookExists(...) för att säkerställa att boken finns, innan funktionen kan fortsätta.
    function deleteBook(string memory bookAuthor, string memory bookTitle) public bookExists(bookAuthor, bookTitle){
        delete authorBooks[bookAuthor][bookTitle];

        for (uint i = 0; i < authorBookTitles[bookAuthor].length; i++) {
            if (keccak256(bytes(authorBookTitles[bookAuthor][i])) == keccak256(bytes(bookTitle))) {
                authorBookTitles[bookAuthor][i] = authorBookTitles[bookAuthor][authorBookTitles[bookAuthor].length - 1];
                authorBookTitles[bookAuthor].pop();
                break;
            }
        }
    }

    function getTitlesByAuthor(string memory bookAuthor) public view returns (string[] memory) {
        return authorBookTitles[bookAuthor];
    }

    function getTitlesAndYears(string memory bookAuthor) public view returns (string[] memory bookTitles, uint[] memory publicationYears) {
        uint bookCount = getBookCountByAuthor(bookAuthor);

        bookTitles = new string[](bookCount);
        publicationYears = new uint[](bookCount);

        for (uint i = 0; i < bookCount; i++) {
            string memory title = authorBookTitles[bookAuthor][i];
            bookTitles[i] = title;
            publicationYears[i] = authorBooks[bookAuthor][title].year;
        }

        return(bookTitles, publicationYears);
    }
}