// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract LibraryLimit {
    // Vi skapar ett struct för våra böcker, där vi kan samla information om bokens titel, författare och årtal.
    struct Book {
        string title;
        string author;
        uint16 year;
    }

    // State variabel av typen uint, där vi håller koll på hur många böcker som har lagts till.
    uint public bookCount = 0;

    // Vi skapar en fast array av Book struct som kan innehålla max 5 böcker.
    Book[5] public books;

    // Funktion för att lägga till en bok i biblioteket.
    // Vi skickar in titel, författare och årtal som parametrar/lokala variabler.
    // När 5 böcker har lagts till går det inte längre att lägga till en ny bok.
    function addBook(string memory bookTitle, string memory bookAuthor, uint16 bookYear) public {
        // Vi använder oss av .push för att lägga till boken till vår books array.
        // Vi placerar boken på platsen bookCount i vår books array.
        books[bookCount] = Book(bookTitle, bookAuthor, bookYear);
        // Vi ökar bookCount med 1, så att nästa bok hamnar på rätt index i vår array.
        bookCount++;
    }
}