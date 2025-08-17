// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract Auction {
    // Struct för att lagra information om ett bud.
    // Varje bud har en adress (bidder) och ett belopp (amount).
    struct Bid {
        address bidder;
        uint amount;
    }

    // Array för att spara alla bud.
    Bid[] public bids;

    // State variabel för lägsta giltiga bud.
    uint public minimumBid;

    // Konstruktor används här för att ange lägsta giltiga bud när kontraktet deployas.
    constructor(uint minBid) {
        minimumBid = minBid;
    }

    // Funktion för att lägga ett bud.
    // msg.value skickas med i transaktionen och anger budets storlek.
    function placeBid() public payable {
        require(msg.value > 0, "Bid amount must be above 0");

        // Här visas två olika sätt för att lägga till ett nytt bud i bids-arrayen.
        // Första sättet, där vi skriver allt i en rad.
        //bids.push(Bid(msg.sender, msg.value));

        // Andra sättet, som är mer "utfällt" med nyckelord, vilket gör det lättare att läsa.
        bids.push(Bid({
            bidder: msg.sender,
            amount: msg.value
        }));
    }

    // Funktion för att beräkna genomsnittet av alla bud som är >= minimumBid.
    function calculateAverage() public view returns(uint average) {
        uint i = 0;
        uint total = 0;
        uint count = 0;

        // Om inga bud finns returneras 0.
        if (bids.length == 0) {
            return 0;
        }

        // Do-while loop för att gå igenom alla bud.
        do {
            // Endast bud som är minst lika stora som minimumBid räknas.
            if (bids[i].amount >= minimumBid) {
                total += bids[i].amount;
                count++;
            }
            i++;
        } while (i < bids.length);

        // Genomsnittet beräknas som totalen delat på antalet giltiga bud.
        average = total / count;

        // Vi returnerar genomsnittet.
        return average;
    }
}