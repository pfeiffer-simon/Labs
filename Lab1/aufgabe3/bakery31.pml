// Getreidesorten
mtype = {rye, wheat, oat}
// Nachrichtentyp
mtype = {request, release}

// Kommunikationskaenale
chan requestChan = [2] of {mtype}
chan releaseChan = [0] of {mtype}

// TODO: Lieferkanaele
// delivery channel for each baker
chan delivery1 = [0] of {mtype,mtype}
chan delivery2 = [0] of {mtype,mtype}
chan delivery3 = [0] of {mtype,mtype}

proctype deliveryService() {
  // TODO: Verhalten des Lieferunternehmens

  // non-deterministically choose one of the delivery channels and send the ingredients to the backer
  // wait for release message from baker to be able to send next ingredients
  do
    :: delivery1 ! rye, wheat; releaseChan ? release
    :: delivery2 ! oat, wheat; releaseChan ? release
    :: delivery3 ! rye, oat;   releaseChan ? release
  od
}

proctype baker(chan deliveryChan) {
  // TODO: Verhalten des/der Beacker*in
  mtype ingredient1, ingredient2;

  // baker waits for ingredients and bakes if he gets them
  do
    :: deliveryChan ? ingredient1, ingredient2 ->
        printf("Accepted ingredients: ");
        printm(ingredient1);
        printf(" ");
        printm(ingredient2);
        printf("\n");

        // send release to delivery service to indicate that next delivery can be done
        releaseChan ! release 
  od
}

init { 
  // TODO
  atomic {
    run deliveryService();

    run baker(delivery1);
    run baker(delivery2);
    run baker(delivery3);
  }
}
