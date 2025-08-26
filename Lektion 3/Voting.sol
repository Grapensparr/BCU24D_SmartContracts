// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract Voting {
    // Enum som beskriver röstningens status: ej startad, pågående eller avslutad.
    enum VotingState { NotStarted, Ongoing, Ended }

    // Struct för att lagra kandidatens namn och antal röster.
    struct Candidate {
        string name;
        uint voteCount;
    }

    // Array som innehåller alla kandidater.
    Candidate[] public candidates;

    // State variabel för röstningens nuvarande status.
    VotingState public votingState;

    // Namnet på vinnaren (sätts när röstningen avslutas).
    string public winner;

    // Mapping som håller koll på om en adress redan har röstat.
    mapping(address => bool) public hasVoted;

    // Konstruktor, tar emot en lista med röstningsalternativ och skapar kandidaterna.
    constructor(string[] memory votingOptions) {
        for (uint i = 0; i < votingOptions.length; i++) {
            candidates.push(Candidate({
                name: votingOptions[i],
                voteCount: 0
            }));
        }

        // Röstningen startar i läget NotStarted.
        votingState = VotingState.NotStarted;
    }

    // Modifier som säkerställer att en funktion bara kan köras i ett visst röstningsläge.
    // `_;` betyder "kör funktionen efter att kravet ovan är uppfyllt".
    modifier inState(VotingState state) {
        require(votingState == state, "Invalid state. Action cannot be performed");
        _;
    }

    // Funktion för att starta omröstningen.
    // Kan endast köras när läget är NotStarted.
    function startVoting() public inState(VotingState.NotStarted) {
        votingState = VotingState.Ongoing;
    }

    // Funktion för att användaren ska kunna rösta på ett alternativ medan omröstningen pågår.
    // Varje adress får bara rösta en gång.
    function vote(string memory votingOption) public inState(VotingState.Ongoing) {
        require(!hasVoted[msg.sender], "You have already voted. You can only vote once!");

        bool found = false;

        // Loopar igenom kandidaterna för att hitta matchande namn (strängjämförelse via keccak256).
        for(uint i = 0; i < candidates.length; i++) {
            if(keccak256(bytes(candidates[i].name)) == keccak256(bytes(votingOption))) {
                candidates[i].voteCount += 1;
                found = true;

                // Enkel vinstregel, om en kandidat får 5 röster avslutas omröstningen och vinnaren sätts.
                if(candidates[i].voteCount == 5) {
                    votingState = VotingState.Ended;
                    winner = candidates[i].name;
                }
                break;
            }
        }

        // Om vi inte hittade en matchande kandidat sker en revert.
        require(found, "Candidate not found. Please try again!");

        // Om allt har gått som det ska och en röst har lagts till, vill vi markera att avsändaren har röstat (så att den inte kan rösta igen).
        hasVoted[msg.sender] = true;
    }
}