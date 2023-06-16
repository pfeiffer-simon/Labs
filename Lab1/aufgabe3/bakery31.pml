// Getreidesorten
mtype = {rye, wheat, oat}
// Nachrichtentyp
mtype = {request, release}

// Kommunikationskaenale
chan requestChan = [2] of {mtype}
chan releaseChan = [0] of {mtype}

// TODO: Lieferkanaele
// delivery channel for each baker
//chan delivery1 = [0] of {mtype,mtype}
//chan delivery2 = [0] of {mtype,mtype}
//chan delivery3 = [0] of {mtype,mtype}
chan delivery = [0] of {mtype, mtype}

proctype deliveryService() {
  // TODO: Verhalten des Lieferunternehmens

  // non-deterministically choose one of the delivery channels and send the ingredients to the backer
  // wait for release message from baker to be able to send next ingredients
  do
      :: requestChan ? request; delivery ! rye, wheat; releaseChan ? release
      :: requestChan ? request; delivery ! wheat, oat; releaseChan ? release
      :: requestChan ? request; delivery ! rye, oat; releaseChan ? release
  od
}

proctype baker(chan deliveryChan) {
  // TODO: Verhalten des/der Beacker*in

  // baker waits for ingredients and bakes if he gets them
  do
      :: requestChan ! request;
      if
        :: _pid % 3 == 0 -> delivery ? wheat, oat
        :: _pid % 3 == 1 -> delivery ? rye, oat
        :: _pid % 3 == 2 -> delivery ? rye, wheat
      fi;
      printf("Baecker %d backt\n", _pid % 3);
      releaseChan ! release
  od
}

init { 
  // TODO
  atomic {
    run deliveryService();

    run baker(delivery);
    run baker(delivery);
    run baker(delivery);
  }
}

/*    :: deliveryChan ? ingredient1, ingredient2 ->
        printf("Accepted ingredients: ");
        printm(ingredient1);
        printf(" ");
        printm(ingredient2);
        printf("\n");

        // send release to delivery service to indicate that next delivery can be done
        releaseChan ! release 
        */
