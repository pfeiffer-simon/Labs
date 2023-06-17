// Getreidesorten
mtype = {rye, wheat, oat}
// Nachrichtentyp
mtype = {request, release}

// ghost variables
int critical = 0; // counts the number of processes in the critical section

// Kommunikationskaenale
chan requestChan = [2] of {mtype}
chan releaseChan = [0] of {mtype}

// TODO: Lieferkanaele
// delivery channel for the delivery service and all bakers
chan delivery = [0] of {mtype, mtype}

proctype deliveryService() {
  // TODO: Verhalten des Lieferunternehmens

  // first wait for a request from the bakers
  // then non-deterministically choose one of the ingredient combinations and send them to the 'backstube'
  // then wait for release message from baker to be able to send next ingredients
  do
      :: requestChan ? request; delivery ! rye, wheat; releaseChan ? release
      :: requestChan ? request; delivery ! wheat, oat; releaseChan ? release
      :: requestChan ? request; delivery ! rye, oat; releaseChan ? release
  od
}

proctype baker(chan deliveryChan) {
  // TODO: Verhalten des/der Beacker*in

  do
      :: requestChan ! request;

        //Erreicht der Prozess dieses Label, dann ist er bereit zum Empfangen der Zutaten
      ready:
      if
        // baker waits for ingredients and bakes if he gets them
        // differentiate bakers by the pid
        :: _pid % 3 == 0 -> delivery ? wheat, oat
        :: _pid % 3 == 1 -> delivery ? rye, oat
        :: _pid % 3 == 2 -> delivery ? rye, wheat
      fi;

      // Erreicht der Prozess dieses Label, dann ist er am Backen
      baking:
      // Die Variable wird erhöht. So kann gezählt werden, wie viele Bäcker am Backen sind
      critical++;
      printf("Baecker %d backt\n", _pid % 3);
      // Der Prozess ist mit dem Backen fertig, deshalb wird die Variable um 1 verringert
      critical--;

      releaseChan ! release // send release to delivery service
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

// Es gilt immer, dass die Anzahl der backenden Bäcker kleiner gleich 1 ist, safety claim, formel ist erfüllt
ltl onlyOneBaker {[](critical <= 1)}

// Wenn der Bäcker bereit ist, dann wird er irgendwann auch zum Backen kommen, liveness claim, formel ist nicht erfüllt
ltl eventuallyBaking {[](baker@ready -> (<>(baker@baking)))}
