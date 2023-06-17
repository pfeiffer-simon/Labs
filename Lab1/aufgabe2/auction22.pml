// Ghost variables
byte numOfBids;      // counts how many bids the auctioneer has received
byte firstBidCount;  // counts how many bidders have sent their first bid

// safety claim, formel ist erfüllt, if one bid has been received, the auction eventually reaches the WinnerDetermined label
ltl winnerVerification {[] (numOfBids == 1 -> <>auctioneer@WinnerDetermined)}
// liveness claim, formel ist erfüllt, sometimes all have bidder sent their first bid
ltl bidsFromEachSent { <> (firstBidCount == 3) }

mtype = {reject, won}
chan bids = [2] of {int, chan}
short winner = -1;

active [3] proctype bidder() {
  // Antwortkanal
  chan response = [0] of {mtype, int};

  int bid;  
  int highestBid;

  // TODO
  select(bid: 1 .. 5);
  bids ! bid, response;
  // Update of the ghost variable upon bidding
  firstBidCount = firstBidCount + 1; // wir nehmen an, dass ein gebot abgegeben wurde, falls es in den bids-channel gesendet werden konnte
  do
  :: response ? won, eval(bid) -> winner = _pid; break
  :: response ? reject, highestBid ->
    if
      :: highestBid < 5 ->
        if
          :: bids ! highestBid + 1, response
          :: break
        fi
      :: else -> break;
    fi 
  od
}

active proctype auctioneer() {
  // Kanal zum derzeit hoechsten Bieter
  chan highestBidder;
  // derzeitiges Hoechstgebot 
  // (0 genau dann wenn noch kein Gebot einging)
  int highestBid;
  int nextBid;
  chan nextBidder;

  // TODO
  do
  :: bids ? nextBid, nextBidder; 
      numOfBids++;
      if
        :: nextBid > highestBid -> 
          if
            :: highestBid != 0 -> highestBidder ! reject, nextBid; highestBid = nextBid; highestBidder = nextBidder
            :: else -> highestBid = nextBid; highestBidder = nextBidder
          fi
        :: else -> nextBidder ! reject, highestBid
      fi
  :: highestBid != 0 -> break
  od;
  WinnerDetermined:  // label indicates that the auction has been finished and a winner has been determined
  highestBidder ! won, highestBid
}
