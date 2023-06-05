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
}

active proctype auctioneer() {
  // Kanal zum derzeit hoechsten Bieter
  chan highestBidder;
  // derzeitiges Hoechstgebot 
  // (0 genau dann wenn noch kein Gebot einging)
  int highestBid = 0;
   
  int nextBid = 0;
  chan nextBidder;

  // TODO
}