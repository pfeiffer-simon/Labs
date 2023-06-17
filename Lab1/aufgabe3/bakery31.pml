// Getreidesorten
mtype = {rye, wheat, oat}
// Nachrichtentyp
mtype = {request, release}

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

      if
        // baker waits for ingredients and bakes if he gets them
        // differentiate bakers by the pid
        :: _pid % 3 == 0 -> delivery ? wheat, oat
        :: _pid % 3 == 1 -> delivery ? rye, oat
        :: _pid % 3 == 2 -> delivery ? rye, wheat
      fi;

      printf("Baecker %d backt\n", _pid % 3);

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
