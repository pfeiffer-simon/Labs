// Anzahl der Knoten
#define N 4

// Nachrichtentypen
mtype = {explorer, echo}
// Knotenfarben
mtype = {white, red, green};

// Kommunikationskanaele zwischen den Knoten
chan pipes[8] = [2] of {mtype};

// der untere Kanal wird nur als Platzhalter verwendet
chan NONE = [0] of {mtype};

// Netzwerkstruktur
typedef edge {
  chan port[N];
}
edge inEdge[N];
edge outEdge[N];

// Knotennummer des Initiators
byte initiator = 3;

proctype node(byte edges; byte nodeNr)  {
  mtype message;
  bool isInitiator = (nodeNr == initiator);

  // initiale Knotenfarbe ist weiss
  mtype color = white;

  // TODO: Modellieren des Algorithmus
  
  int firstExplorer = -1; // stores the node number of the first explorer message
  int numMessages = 0;    // counts the number of received messages for this node
  int i, j;               // counter variables

  do
    :: isInitiator && color == white ->
      // initiator turns red and sends an explorer message to all outgoing edges
      color = red;
      for (i : 0 .. edges-1) {
        outEdge[nodeNr - 1].port[i] ! explorer;
      }

    :: !isInitiator && color == white ->
      // white node receives first explorer message from ingoing edge and stores the number of the first explorer edge
      for (i : 0 .. edges-1) {
        if
          :: nempty(inEdge[nodeNr - 1].port[i]) -> // if message is waiting at this port, receive the message
            inEdge[nodeNr - 1].port[i] ? explorer;
            firstExplorer = i; // store firstExplorer edge
            color = red; // edge turns red
            // send explorer message to all outgoing edges except the first explorer edge
            for (j : 0 .. edges-1) {
              if 
                :: j == firstExplorer -> skip
                :: else               -> outEdge[nodeNr - 1].port[j] ! explorer
              fi
            }

            numMessages = 1; // set the number of messages to one
            break; // break in order to receive only one message at this point
          :: empty(inEdge[nodeNr - 1].port[i]) -> skip // if no message is at this port, skip
        fi
      }

    :: color == red && numMessages != edges ->
      // red node receives explorer and echo messages, and increase number of messages
      for (i : 0 .. edges-1) {
        if
          :: nempty(inEdge[nodeNr - 1].port[i]) -> inEdge[nodeNr-1].port[i] ? _; numMessages = numMessages + 1;
          :: empty(inEdge[nodeNr - 1].port[i])  -> skip
        fi
      }

    :: color == red && numMessages == edges ->
      // if the number of received messages equals the number of edges, turn the node green

      // send echo message to first explorer if the node is not the initiator
      if
        :: isInitiator -> color = green; // use label to mark the point when the initiator turns green
        :: else -> color = green; outEdge[nodeNr - 1].port[firstExplorer] ! echo
      fi

    :: color == green ->
      // end loop if node has turned green
      if 
        :: isInitiator -> printf("Message distribution successful!\n")
        :: else        -> skip
      fi
      break

  od
}

init {
  // TODO: Modellieren der Infrastruktur

  // initialize all port with the NONE channel

  int i, j;
  for (i : 0 .. N-1) {
    for (j : 0 .. N-1) {
      outEdge[i].port[j] = NONE;
      inEdge[i].port[j]  = NONE;
    }
  }

  // model the infrastructure by setting the appropriate channels, start filling the port arrays at the lowest indizes

  // node 1
  outEdge[0].port[0] = pipes[0]; // n1 -> n2
  inEdge[0].port[0]  = pipes[1]; // n1 <- n2

  // node 2
  outEdge[1].port[0] = pipes[1]; // n2 -> n1
  outEdge[1].port[1] = pipes[2]; // n2 -> n3
  outEdge[1].port[2] = pipes[3]; // n2 -> n4
  inEdge[1].port[0]  = pipes[0]; // n2 <- n1
  inEdge[1].port[1]  = pipes[4]; // n2 <- n3
  inEdge[1].port[2]  = pipes[5]; // n2 <- n4

  // node 3
  outEdge[2].port[0] = pipes[4]; // n3 -> n2
  outEdge[2].port[1] = pipes[6]; // n3 -> n4
  inEdge[2].port[0]  = pipes[2]; // n3 <- n2
  inEdge[2].port[1]  = pipes[7]; // n3 <- n4

  // node 4
  outEdge[3].port[0] = pipes[5]; // n4 -> n2
  outEdge[3].port[1] = pipes[7]; // n4 -> n3
  inEdge[3].port[0]  = pipes[3]; // n4 <- n2
  inEdge[3].port[1]  = pipes[6]; // n4 <- n3

  atomic { // todo: brauchts das?
    // start processes
    run node(1,1);
    run node(3,2);
    run node(2,3);
    run node(2,4);
  }
}
