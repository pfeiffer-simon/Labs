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

byte numGreen = 0;

proctype node(byte edges; byte nodeNr)  {
  mtype message;
  bool isInitiator = (nodeNr == initiator);

  // initiale Knotenfarbe ist weiss
  mtype color = white;

  // TODO: Modellieren des Algorithmus
  
  byte firstExplorer = -1; // stores the node number of the first explorer message
  byte numMessages = edges; // counts the number of messages a node has received
  int i;

  do
    :: isInitiator && color == white -> 
      // initiator turns red and sends a  explorer message to all outgoing edges
      color = red;
      for (i : 1 .. N) {
        outEdge[nodeNr - 1].port[i-1] ! explorer;
      }
    :: !isInitiator && color == white ->
      // white node receives first explorer message from ingoing edge and stores the number of the first explorer edge
      if
        :: inEdge[nodeNr-1].port[0] ? explorer -> firstExplorer = 0; 
        :: inEdge[nodeNr-1].port[1] ? explorer -> firstExplorer = 1; 
        :: inEdge[nodeNr-1].port[2] ? explorer -> firstExplorer = 2; 
        :: inEdge[nodeNr-1].port[3] ? explorer -> firstExplorer = 3; 
      fi;
      numMessages = numMessages - 1;
      // edge turns red
      color = red;
      // send explorer message to all outgoing edges except the first explorer edge
      for (i : 1 .. N) {
        if
          :: i == firstExplorer -> skip
          :: else -> outEdge[nodeNr - 1].port[i-1] ! explorer;
        fi
      }
    :: color == red && numMessages != 0 ->
      // red node receives explorer and echo messages, decrease number of messages
      if
        :: inEdge[nodeNr-1].port[0] ? explorer -> skip; 
        :: inEdge[nodeNr-1].port[0] ? echo -> skip; 
        :: inEdge[nodeNr-1].port[1] ? explorer -> skip; 
        :: inEdge[nodeNr-1].port[1] ? echo -> skip; 
        :: inEdge[nodeNr-1].port[2] ? explorer -> skip; 
        :: inEdge[nodeNr-1].port[2] ? echo -> skip; 
        :: inEdge[nodeNr-1].port[3] ? explorer -> skip; 
        :: inEdge[nodeNr-1].port[3] ? echo -> skip; 
      fi;
      numMessages = numMessages - 1;
    :: numMessages == 0 ->
      // node turns green if it has received a number of messages equal to the number of ingoing edges
      numGreen = numGreen + 1
turnGreen:
      color = green;
      // a non initiator node sends an echo message to the first explorer edge
      if
        :: isInitiator -> skip
        :: else -> outEdge[nodeNr-1].port[firstExplorer] ! echo;
      fi
  od
}

init {
  // TODO: Modellieren der Infrastruktur

  // todo: inlinen ?
  // n1 - n2
	outEdge[0].port[1] = pipes[0];
	inEdge[1].port[0] = pipes[0];

	inEdge[0].port[1] = pipes[1];
	outEdge[1].port[0] = pipes[1];
  
  // initEdges(0, 1, 0);

  // n2 - n3
  outEdge[1].port[2] = pipes[2];
  inEdge[2].port[1] = pipes[2];
  inEdge[1].port[2] = pipes[3];  
  outEdge[2].port[1] = pipes[3];
  
  // initEdges(1, 2, 2);

  // n2 - n4
  outEdge[1].port[3] = pipes[4];
  inEdge[3].port[1] = pipes[4];

  inEdge[1].port[3] = pipes[5];  
  outEdge[3].port[1] = pipes[5];

  // initEdges(1, 3, 4);

  // n3 - n4
  outEdge[2].port[3] = pipes[6];
  inEdge[3].port[2] = pipes[6];

  inEdge[2].port[3] = pipes[7];  
  outEdge[3].port[2] = pipes[7];

  // initEdges(2, 3, 6);

  atomic { // todo: brauchts das?
    // start processes
    run node(1,1);
    run node(3,2);
    run node(2,3);
    run node(2,4);
  }
} 

ltl first { (node@turnGreen && isInitiator) -> (numGreen == 4) }