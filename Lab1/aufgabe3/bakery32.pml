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

//Zählvariable, mit der gezählt wird, wie viele grade am Backen sind
int critical;

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


  //Erreicht der Prozess dieses Label, dann ist er bereit zum Empfangen der Zutaten
  ready:
  do
    :: deliveryChan ? ingredient1, ingredient2 ->
        //Erreicht der Prozess dieses Label, dann ist er am Backen
         baking:
         //Die Variable wird erhöht. So kann gezählt werden, wie viele Bäcker am Backen sind
         critical++;
         printf("Accepted ingredients: ");
         printm(ingredient1);
         printf(" ");
         printm(ingredient2);
         printf("\n");
         //Der Prozess ist mit dem Backen fertig, deshalb wird die Variable um 1 verringert
         critical--;

         releaseChan ! release
  od
}

init { 
  atomic {
    run deliveryService();

    run baker(delivery1);
    run baker(delivery2);
    run baker(delivery3);
  }
}

//Es gilt immer, dass die Anzahl der backenden Bäcker kleiner gleich 1 ist 
ltl onlyOneBaker {[](critical <= 1)}

// Wenn der Bäcker bereit ist, dann wird er irgendwann auch zum Backen kommen
ltl eventuallyBaking {[](baker@ready -> (<>(baker@baking)))}