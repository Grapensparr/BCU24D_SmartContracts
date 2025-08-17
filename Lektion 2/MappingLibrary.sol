// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract MappingLibrary {
    // Vi skapar en struct för våra böcker, där vi sparar titel, årtal och en bool som anger om boken finns.
    struct Book {
        string title;
        uint16 year;
        bool exist;
    }

    // Mapping med författarens namn som första key.
    // Värdet är en andra mapping med bokens titel som key och en Book struct som value.
    mapping(string => mapping(string => Book)) public authorBooks;

    // Mapping med författarens namn som key och en array av titlar som value.
    mapping(string => string[]) internal authorBookTitles;

    // Funktion för att lägga till en bok.
    function addBook(string memory bookAuthor, string memory bookTitle, uint16 publicationYear) public {
        // Vi kräver att boken inte redan finns (exist = false) för given författare + titel.
        require(!authorBooks[bookAuthor][bookTitle].exist, "Book already exists");

        // Lägger in boken i vår dubbla mapping.
        authorBooks[bookAuthor][bookTitle] = Book(bookTitle, publicationYear, true);

        // Push:ar titeln i författarens titel-array.
        authorBookTitles[bookAuthor].push(bookTitle);
    }

    // Funktion för att hämta antal böcker för en viss författare.
    function getBookCountByAuthor(string memory bookAuthor) public view returns(uint) {
        // Returnerar längden på titel-arrayen.
        return authorBookTitles[bookAuthor].length;
    }

    // Funktion för att uppdatera en boks information.
    function updateBook(string memory bookAuthor, string memory oldTitle, string memory newTitle, uint16 newYear) public {
        require(authorBooks[bookAuthor][oldTitle].exist, "Book does not exist");
        require(!authorBooks[bookAuthor][newTitle].exist, "New title already exists");

        // Vi jämför strängar via keccak256(bytes(...)) då två strängar inte kan jämföras direkt med ==.
        if (keccak256(bytes(oldTitle)) != keccak256(bytes(newTitle))) {
            // Vi skapar en ny bok med den nya titeln och raderar den gamla (i mappingen lämnas inget "hål", eftersom den inte är indexerad).
            authorBooks[bookAuthor][newTitle] = Book(newTitle, newYear, true);
            delete authorBooks[bookAuthor][oldTitle];

            // Vi uppdaterar titeln även i vår array (behåller samma antal, uppdaterar endast värdet på platsen).
            for (uint i = 0; i < authorBookTitles[bookAuthor].length; i++) {
                if (keccak256(bytes(authorBookTitles[bookAuthor][i])) == keccak256(bytes(oldTitle))) {
                    authorBookTitles[bookAuthor][i] = newTitle;

                    // Vi använder oss av break för att avbryta loopen så fort vi utfört uppdateringen, vilket sparar gas.
                    break;
                }
            }
        } else {
            // Om titeln inte har ändras, uppdaterar vi endast årtal.
            authorBooks[bookAuthor][oldTitle].year = newYear;
        }
    }

    // Funktion för att ta bort en bok.
    function deleteBook(string memory bookAuthor, string memory bookTitle) public {
        require(authorBooks[bookAuthor][bookTitle].exist, "Book does not exist");

        // Delete tar bort värdena för nyckeln i vår mapping (i mappingen lämnas inget "hål", eftersom den inte är indexerad).
        delete authorBooks[bookAuthor][bookTitle];

        // För vår array letar vi efter titeln som ska tas bort, och ersätter den med det sista elementet och pop:ar bort det sista värdet.
        for (uint i = 0; i < authorBookTitles[bookAuthor].length; i++) {
            // Vi jämför strängar via keccak256(bytes(...)) då två strängar inte kan jämföras direkt med ==.
            if (keccak256(bytes(authorBookTitles[bookAuthor][i])) == keccak256(bytes(bookTitle))) {
                authorBookTitles[bookAuthor][i] = authorBookTitles[bookAuthor][authorBookTitles[bookAuthor].length - 1];
                authorBookTitles[bookAuthor].pop();

                // Vi använder oss av break för att avbryta loopen så fort vi utfört uppdateringen, vilket sparar gas.
                break;
            }
        }
    }

    // Funktion för att hämta alla titlar (endast titlar) för en viss författare.
    function getTitlesByAuthor(string memory bookAuthor) public view returns (string[] memory) {
        return authorBookTitles[bookAuthor];
    }

    // Funktion för att hämta både titlar och årtal för en viss författare.
    function getTitlesAndYears(string memory bookAuthor) public view returns (string[] memory bookTitles, uint[] memory publicationYears) {
        // Vi kan antingen få fram vår bookCount genom att kontrollera längden på vår array.
        //uint bookCount = authorBookTitles[bookAuthor].length;

        // Eller så kallar vi på vår getBookCountByAuthor-funktion, som i sig returnerar längden på vår array.
        uint bookCount = getBookCountByAuthor(bookAuthor);

        // Vi skapar två arrayer i önskad storlek. I funktioner skrivs storleken på arrayen i parentes.
        bookTitles = new string[](bookCount);
        publicationYears = new uint[](bookCount);

        // Vi fyller våra arrayer genom att hämta titel från authorBookTitles och årtal från authorBooks-mappningen.
        for (uint i = 0; i < bookCount; i++) {
            string memory title = authorBookTitles[bookAuthor][i];
            bookTitles[i] = title;
            publicationYears[i] = authorBooks[bookAuthor][title].year;
        }

        // Vi returnerar båda arrayerna.
        return(bookTitles, publicationYears);
    }
}