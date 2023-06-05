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
  bool isInitiator = (nodeNr == initiator);

  // initiale Knotenfarbe ist weiss
  mtype color = white;
  
  // TODO: Modellieren des Algorithmus
}

init {
  // TODO: Modellieren der Infrastruktur
}
