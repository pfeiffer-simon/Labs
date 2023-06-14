// Ghost variables for individual bids
bool bidSent[3];
byte numOfBids;

ltl winnerVerification {[](numOfBids == 1 -> <>auctioneer@WinnerDetermined)}
ltl bidsFromEachSent {<> (bidSent[0] && bidSent[1] && bidSent[2])}

mtype = {reject, won}
chan bids = [2] of {int, chan}
short winner = -1;

active [3] proctype bidder() {
  // Antwortkanal
  chan response = [0] of {mtype, int};

  int bid;  
  int highestBid;
  mtype status;
  int next;

  // TODO
  select( bid: 1 .. 5);
  bids ! bid, response;
  // Update of the ghost variable upon bidding
  bidSent[_pid] = true;
  do
  :: response ? won, eval(bid) -> winner = _pid; break
  :: response ? reject, highestBid ->
    if
      :: highestBid < 5 -> 
        if
          :: bids ! bid+1, response
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
  WinnerDetermined:
  highestBidder ! won, highestBid
}