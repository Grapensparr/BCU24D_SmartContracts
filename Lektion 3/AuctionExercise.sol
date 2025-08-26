// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract AuctionExercise {
    // Struct för att lagra information om en vara.
    // Varje vara har ett id, en ägare, en titel och en bool som anger om den är till salu.
    struct Item {
        uint id;
        address owner;
        string title;
        bool forSale;
    }

    // Struct för att lagra information om en auktion.
    // Innehåller id, deadline, minimumpris, högsta bud, högsta budgivare och status.
    struct Auction {
        uint auctionId;
        uint deadline;
        uint minimumPrice;
        uint highestBid;
        address highestBidder;
        bool active;
    }

    // State variabel för att hålla reda på hur många varor som har registrerats.
    uint public itemCount;

    // Mapping för att lagra varor baserat på deras id.
    mapping(uint => Item) public items;

    // Mapping för att lagra auktioner baserat på varans id.
    mapping(uint => Auction) public auctions;

    // Mapping för att hålla reda på återbetalningar till användare som blivit överbjudna.
    mapping(address => uint) public balances;

    // Funktion för att lägga till en ny vara.
    // Samma vara får inte läggas till två gånger av samma ägare.
    function addItem(string memory itemTitle) public {
        for (uint i = 0; i <= itemCount; i++) {
            Item storage item = items[i];

            // Vi använder keccak256 för att jämföra strängar (går inte med == i Solidity).
            // Här säkerställer vi att samma ägare inte kan registrera två varor med samma titel.
            require(item.owner != msg.sender || keccak256(bytes(item.title)) != keccak256(bytes(itemTitle)), "You have already added this item!");
        }

        itemCount++;

        // Den nya varan läggs till i vår items mapping.
        items[itemCount] = Item(itemCount, msg.sender, itemTitle, false);
    }
    
    // Funktion för att starta en auktion för en vara.
    // Endast ägaren kan starta auktionen, och varan måste finnas bland ägarens registrerade ägodelar.
    // Auktionen får ett minimumpris och en deadline.
    function startAuction(uint itemId, uint auctionMinPrice, uint durationInDays) public {
        Item storage item = items[itemId];

        require(item.owner == msg.sender, "Only the owner can start the auction");
        require(!item.forSale, "This item is already out for auction");

        item.forSale = true;

        auctions[itemId] = Auction( {
            auctionId: itemId,
            deadline: block.timestamp + (durationInDays * 1 days),
            minimumPrice: auctionMinPrice,
            highestBid: 0,
            highestBidder: address(0),
            active: true
        });
    }

    // Funktion för att lägga bud på en vara under en pågående auktion.
    // Ägaren får inte själv lägga ett bud, och budet måste vara högre än både minimumpris och det ledande budet.
    function placeBid(uint auctionId) public payable {
        Auction storage auction = auctions[auctionId];

        require(auction.active, "The auction is not active");
        require(items[auctionId].owner != msg.sender, "You cannot bid on your own auction");
        require(msg.value >= auction.minimumPrice, "Bid must be above minimum price. Bid higher!");
        require(msg.value > auction.highestBid, "There is already a higher bid for this auction");
        require(block.timestamp < auction.deadline, "The auction has closed");

        // Om det finns en tidigare budgivare, behöver det tidigare ledande budet kunna återbetalas.
        if (auction.highestBidder != address(0)) {
            uint amountToTransfer = auction.highestBid;
            auction.highestBid = 0;

            // Vi krediterar saldot i balances istället för att automatiskt skicka tillbaka pengarna till den tidigare budgivaren.
            // Det är möjligt att göra en direkt återföring, men det är inte att rekommendera.
            balances[auction.highestBidder] += amountToTransfer;
        }

        // Vi uppdaterar auktionen med det nya ledande budet.
        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;
    }

    // Funktion för att ta ut pengar (för de användare som har blivit överbjudna).
    function withdraw() public {
        // Vi säkerställer att användaren har ett positivt saldo att ta ut.
        require(balances[msg.sender] > 0, "You have no funds available");

        uint amountToTransfer = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amountToTransfer);
    }

    // Funktion för att avsluta auktionen.
    function endAuction(uint auctionId) public {
        Auction storage auction = auctions[auctionId];
        Item storage item = items[auctionId];

        // Endast ägaren kan avsluta sina pågående auktioner, och detta kan endast ske efter att deadline har passerat.
        require(msg.sender == item.owner, "Only the owner can end the auction");
        require(auction.active, "The auction is not active. Try ending another one.");

        // Vi har här valt att kommentera ut denna require i demosyfte, då vi inte vill vänta på att deadline ska passera för att kunna testa funktionaliteten.
        //require(block.timestamp > auction.deadline, "The deadline has not passed.");

        item.forSale = false;
        auction.active = false;

        // Om det finns en vinnare förs det ledande budet över till ägaren och ägarskapet av varan flyttas över till budgivaren.
        if(auction.highestBidder != address(0)) {
            uint amountToTransfer = auction.highestBid;
            auction.highestBid = 0;

            // Vi skickar pengarna till säljaren (ägaren).
            payable(msg.sender).transfer(amountToTransfer);

            // Ägarskapet av varan flyttas till den vinnande budgivaren.
            item.owner = auction.highestBidder;
        }
    }

    // Funktion för att hämta ledande bud och budgivare för en specifik auktion.
    function getHighestBid(uint auctionId) public view returns(uint, address) {
        Auction storage auction = auctions[auctionId];
        return(auction.highestBid, auction.highestBidder);
    }
}