// Getreidesorten
mtype = {rye, wheat, oat}
// Nachrichtentyp
mtype = {request, release}

// Kommunikationskaenale
chan requestChan = [2] of {mtype}
chan releaseChan = [0] of {mtype}

// TODO: Lieferkanaele
chan delivery1 = [0] of {mtype,mtype}
chan delivery2 = [0] of {mtype,mtype}
chan delivery3 = [0] of {mtype,mtype}

int critical;

ltl onlyOneBaker {[](critical <= 1)}
ltl eventuallyBaking {<>(baker@baking)}

proctype deliveryService() {
  // TODO: Verhalten des Lieferunternehmens
  do
    :: delivery1 ! rye, wheat; releaseChan ? release
    :: delivery2 ! oat, wheat; releaseChan ? release
    :: delivery3 ! rye, oat;   releaseChan ? release
  od
}

proctype baker(chan deliveryChan) {
  // TODO: Verhalten des/der Beacker*in
  mtype ingredient1, ingredient2;

  do
    :: deliveryChan ? ingredient1, ingredient2 ->
         baking:
         critical++;
         printf("Accepted ingredients: ");
         printm(ingredient1);
         printf(" ");
         printm(ingredient2);
         printf("\n");
         critical--;

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
