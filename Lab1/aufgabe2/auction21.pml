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
  highestBidder ! won, highestBid
}
