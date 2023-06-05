// Getreidesorten
mtype = {rye, wheat, oat}
// Nachrichtentyp
mtype = {request, release}

// Kommunikationskaenale
chan requestChan = [2] of {mtype}
chan releaseChan = [0] of {mtype}

// TODO: Lieferkanaele

proctype deliveryService() {
  // TODO: Verhalten des Lieferunternehmens
}

proctype baker(chan deliveryChan) {
  // TODO: Verhalten des/der Beacker*in
}

init { 
  // TODO
}