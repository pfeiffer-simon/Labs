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
  int numMessages = edges; // counts the number of messages a node has received
  int i;


  do
    :: isInitiator && color == green -> initTurnGreen: printf("Message distribution successful!\n");  break
    :: isInitiator && color == white -> 
      // initiator turns red and sends an explorer message to all outgoing edges
      color = red;
      for (i : 1 .. N) {
        chan ch = outEdge[nodeNr - 1].port[i-1];
        if
          :: ch != NONE -> ch ! explorer
          :: else -> skip
        fi
      }
    :: !isInitiator && color == white ->
      // white node receives first explorer message from ingoing edge and stores the number of the first explorer edge
      if
        :: inEdge[nodeNr - 1].port[0] ? explorer -> firstExplorer = 0;
        :: inEdge[nodeNr - 1].port[1] ? explorer -> firstExplorer = 1;
        :: inEdge[nodeNr - 1].port[2] ? explorer -> firstExplorer = 2;
        :: inEdge[nodeNr - 1].port[3] ? explorer -> firstExplorer = 3;
      fi;
      numMessages = numMessages - 1;
      // edge turns red
      color = red;
      // send explorer message to all outgoing edges except the first explorer edge
      for (i : 1 .. N) {
        if
          :: i == firstExplorer -> skip
          :: else -> 
            chan ch = outEdge[nodeNr - 1].port[i-1];
            if 
              :: ch != NONE -> ch ! explorer
              :: else -> skip
            fi
        fi
      }
    :: color == red && numMessages != 0 ->
      // red node receives explorer and echo messages, decrease number of messages
      if
        :: inEdge[nodeNr-1].port[0] ? _ -> skip; 
        :: inEdge[nodeNr-1].port[1] ? _ -> skip; 
        :: inEdge[nodeNr-1].port[2] ? _ -> skip; 
        :: inEdge[nodeNr-1].port[3] ? _ -> skip; 
      fi;
      numMessages = numMessages - 1;
    :: numMessages == 0 ->
      // node turns green if it has received a number of messages equal to the number of ingoing edges
      numGreen = numGreen + 1
      numMessages = -1;
turnGreen:
      color = green;
      // a non initiator node sends an echo message to the first explorer edge
      if
        :: isInitiator -> skip
        :: else ->
          chan ch = outEdge[nodeNr-1].port[firstExplorer];
          if 
            :: ch != NONE -> ch ! echo
            :: else -> skip
          fi
      fi
      break;
  od
}

init {
  // TODO: Modellieren der Infrastruktur
  int i, j;
  for (i : 0 .. N-1) {
    for (j : 0 .. N-1) {
      outEdge[i].port[j] = NONE;
      inEdge[i].port[j]  = NONE;
    }
  }

  // n1 - n2
	outEdge[0].port[1] = pipes[0];
	inEdge[1].port[0] = pipes[0];

	inEdge[0].port[1] = pipes[1];
	outEdge[1].port[0] = pipes[1];

  // n2 - n3
  outEdge[1].port[2] = pipes[2];
  inEdge[2].port[1] = pipes[2];
  inEdge[1].port[2] = pipes[3];  
  outEdge[2].port[1] = pipes[3];

  // n2 - n4
  outEdge[1].port[3] = pipes[4];
  inEdge[3].port[1] = pipes[4];

  inEdge[1].port[3] = pipes[5];  
  outEdge[3].port[1] = pipes[5];

  // n3 - n4
  outEdge[2].port[3] = pipes[6];
  inEdge[3].port[2] = pipes[6];

  inEdge[2].port[3] = pipes[7];  
  outEdge[3].port[2] = pipes[7];

  atomic { // todo: brauchts das?
    // start processes
    run node(1,1);
    run node(3,2);
    run node(2,3);
    run node(2,4);
  }
} 


ltl initGreenAllGreen { [](node@initTurnGreen -> (numGreen == 4)) }
