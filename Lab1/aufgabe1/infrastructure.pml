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
byte initiator = 0;

proctype node(byte edges; byte nodeNr)  {
  mtype message;
  bool isInitiator = (nodeNr == initiator);

  // initiale Knotenfarbe ist weiss
  mtype color = white;

  // TODO: Modellieren des Algorithmus
  
  byte first_explorer = -1;
  if
    :: isInitiator && color == white -> 
      color = red;
      for (i : 1 .. N) {
        outEdge[nodeNr - 1].port[i-1] ! explorer
      }

    :: color== white && inEdge[nodeNr-1].port[0] ? explorer -> 
      first_explorer = 0;
      color=red;
      for (i : 1 .. N) {
        if
          :: i-1 != first_explorer -> outEdge[nodeNr - 1].port[i-1] ! explorer
          :: else -> skip
        fi
      }

    :: color== white && inEdge[nodeNr-1].port[1] ? message -> color=red;
      first_explorer = 1;
      color=red;
      for (i : 1 .. N) {
        if
          :: i-1 != first_explorer -> outEdge[nodeNr - 1].port[i-1] ! explorer
          :: else -> skip
        fi
      }

    :: color== white && inEdge[nodeNr-1].port[2] ? message -> color=red;
      first_explorer = 2;
      color=red;
      for (i : 1 .. N) {
        if
          :: i-1 != first_explorer -> outEdge[nodeNr - 1].port[i-1] ! explorer
          :: else -> skip
        fi
      }

    :: color== white && inEdge[nodeNr-1].port[3] ? message -> color=red;
      first_explorer = 3;
      color=red;
      for (i : 1 .. N) {
        if
          :: i-1 != first_explorer -> outEdge[nodeNr - 1].port[i-1] ! explorer
          :: else -> skip
        fi
      }

  fi
}

init {
  // TODO: Modellieren der Infrastruktur

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

  // start processes
  run node(1,1);
  run node(3,2);
  run node(2,3);
  run node(2,4);
}
