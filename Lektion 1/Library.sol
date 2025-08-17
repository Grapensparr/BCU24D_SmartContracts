// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract Library {
    // Vi skapar ett struct för våra böcker, där vi kan samla information om bokens titel, författare och årtal.
    struct Book {
        string title;
        string author;
        uint16 year;
    }

    // Vi skapar en dynamisk array av Book struct. Arrayen får namnet books.
    Book[] public books;

    // Funktion för att lägga till en bok i biblioteket. 
    // Vi skickar med bokens titel, författare och årtal som parametrar/lokala variabler.
    function addBook(string memory bookTitle, string memory bookAuthor, uint16 bookYear) public {
        // Vi använder .push för att lägga till boken i vår books array.
        books.push(Book(bookTitle, bookAuthor, bookYear));
    }

    // Funktion för att läsa av hur många böcker som finns i biblioteket.
    // Funktionen returnerar längden på vår books array.
    function bookCount() public view returns(uint) {
        return books.length;
    }

    // Funktion för att ta bort en bok ur biblioteket.
    // Med delete tar vi bort informationen på detta index. 
    // Själva indexet ligger kvar i arrayen, men utan värden (tom plats).
    function removeBook(uint index) public {
        // Require används för att säkerställa att boken finns i vårt bibliotek.
        require(index < books.length, "Book does not exist");
        delete books[index];
    }

    // Funktion för att ta bort en bok ur biblioteket.
    // Vi går in i vår array och ersätter värdet på indexet som ska bort med den sista boken i arrayen.
    // Vi har nu ett duplikat av den sista boken, och använder .pop för att ta bort den sista boken.
    // Notera att vi nu har ändrat ordningen på vår array.
    function removeBookIndex(uint index) public {
        require(index < books.length, "Book does not exist");
        books[index] = books[books.length - 1];
        books.pop();
    }

    // Funktion för att ta bort en bok ur biblioteket.
    // Vi startar på indexet som ska bort. I varje loop kopieras nästa element till nuvarande plats.
    // När vi kommer till slutet har vi ett duplikat av sista boken, men ordningen är bevarad.
    // Vi använder oss av .pop för att ta bort duplikatet av den sista boken.
    function removeBookKeepOrder(uint index) public {
        require(index < books.length, "Book does not exist");
        for (uint i = index; i < books.length - 1; i++) {
            books[i] = books[i + 1];
        }

        books.pop();
    }
}