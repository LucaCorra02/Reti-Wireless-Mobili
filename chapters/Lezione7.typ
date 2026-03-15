#import "../template.typ": *

= WiFi (802.11)

Lo standard considerato come riferimento per le reti wireless è IEEE 802.11. I requisiti generali sono: 
- Throughput maggiore possibile
- Elevato numero di nodi, gestione tramite più celle
- Connessione verso la rete cablata (*backbone*)
- Raggio di copertura tra circa 100-300 metri
- Utilizzo efficiente della batteria
- Più WLAN possono coesistere nello stesso ambiente (es. uffici, appartamenti)
- Operare nelle bande non licenziate
- Configurazione dinamica (selezione canali, autenticazione)

Solitamente si ha una rete con uno o più *Access Point* (AP): essi fungono da bridge tra la rete wireless e la rete cablata. La coordinazione della rete è gestita dai *Point Coordinator Function* (PCF), che possono essere implementati nell'AP o in stazioni dedicate.

== Point Coordination Function (PCF)

La *Point Coordination Function (PCF)* è un meccanismo di *coordinamento centralizzato* opzionale definito nello standard IEEE 802.11 per gestire l'accesso al mezzo trasmissivo. A differenza del *DCF* (Distributed Coordination Function), che è basato su CSMA/CA e quindi distribuito, il PCF implementa un approccio centralizzato basato su polling.

=== Architettura e Funzionamento

Il PCF opera attraverso un *Point Coordinator (PC)*, tipicamente implementato nell'*Access Point* (AP), che controlla l'accesso al canale wireless interrogando sequenzialmente le stazioni che hanno richiesto di operare in modalità PCF.

#nota[
Il PCF è stato progettato per supportare applicazioni time-sensitive come VoIP o streaming video, garantendo accesso deterministico al mezzo.
]

Il funzionamento del PCF si basa su due fasi cicliche:

/ *Contention-Free Period (CFP)*: Periodo controllato dal Point Coordinator dove non c'è competizione per l'accesso al mezzo. Il PC interroga le stazioni in modalità round-robin.

/ *Contention Period (CP)*: Periodo in cui le stazioni utilizzano il DCF standard (CSMA/CA) per accedere al canale.

#align(center)[
  #figure(
    cetz.canvas(length: 0.8cm, {
      import cetz.draw: *

      let w = 3.5
      let h = 1.2
      let gap = 0.3

      // CFP blocks
      rect((0, 0), (w, h), fill: rgb("#4472C4"), stroke: black)
      content((w/2, h/2), text(fill: white, weight: "bold", size: 0.9em)[CFP])

      rect((w + gap, 0), (2*w + gap, h), fill: rgb("#ED7D31"), stroke: black)
      content((1.5*w + gap, h/2), text(fill: white, weight: "bold", size: 0.9em)[CP])

      rect((2*w + 2*gap, 0), (3*w + 2*gap, h), fill: rgb("#4472C4"), stroke: black)
      content((2.5*w + 2*gap, h/2), text(fill: white, weight: "bold", size: 0.9em)[CFP])

      rect((3*w + 3*gap, 0), (4*w + 3*gap, h), fill: rgb("#ED7D31"), stroke: black)
      content((3.5*w + 3*gap, h/2), text(fill: white, weight: "bold", size: 0.9em)[CP])

      // Time arrow
      line((0, -0.8), (4*w + 3*gap, -0.8), mark: (end: ">", fill: black))
      content((2*w + 1.5*gap, -1.2), text(weight: "bold")[Tempo])

      // Labels
      content((w/2, h + 0.8), text(size: 0.8em)[Polling])
      content((1.5*w + gap, h + 0.8), text(size: 0.8em)[CSMA/CA])
    }),
    caption: [Alternanza tra Contention-Free Period e Contention Period]
  )
]

=== Interframe Spacing in PCF

Il PCF utilizza un *PIFS (PCF Interframe Space)* più corto del DIFS utilizzato dal DCF. Questo permette al Point Coordinator di ottenere priorità nell'accesso al canale rispetto alle stazioni in modalità DCF.

La gerarchia degli interframe spacing è:
$ "SIFS" < "PIFS" < "DIFS" $

dove:
- $"SIFS"$ (Short IFS): ~10 μs, usato per ACK e risposte immediate
- $"PIFS"$ (PCF IFS): ~30 μs, usato dal Point Coordinator
- $"DIFS"$ (DCF IFS): ~50 μs, usato dalle stazioni in DCF

=== Processo di Polling

Durante il CFP, il Point Coordinator:

1. Attende un tempo PIFS dopo che il canale diventa libero
2. Trasmette un frame *CF-Poll* alla stazione successiva nella polling list
3. La stazione riceve il poll e può trasmettere un frame dati entro un tempo SIFS
4. Se la stazione non ha dati da trasmettere, risponde con un *CF-Null*
5. Il processo continua fino alla fine del CFP

#align(center)[
  #figure(
    cetz.canvas(length: 0.6cm, {
      import cetz.draw: *

      let y-pc = 3
      let y-sta1 = 2
      let y-sta2 = 1
      let y-sta3 = 0

      // Entities
      content((0, y-pc), anchor: "east", text(weight: "bold")[PC (AP)])
      content((0, y-sta1), anchor: "east", text(weight: "bold")[STA 1])
      content((0, y-sta2), anchor: "east", text(weight: "bold")[STA 2])
      content((0, y-sta3), anchor: "east", text(weight: "bold")[STA 3])

      let x-start = 1
      let x-end = 16

      // Timeline lines
      line((x-start, y-pc), (x-end, y-pc), stroke: (dash: "dashed"))
      line((x-start, y-sta1), (x-end, y-sta1), stroke: (dash: "dashed"))
      line((x-start, y-sta2), (x-end, y-sta2), stroke: (dash: "dashed"))
      line((x-start, y-sta3), (x-end, y-sta3), stroke: (dash: "dashed"))

      // CF-Poll to STA1
      line((2, y-pc), (3, y-sta1), mark: (end: ">"), stroke: (paint: blue, thickness: 1.5pt))
      content((2.5, (y-pc + y-sta1)/2), anchor: "west", text(size: 0.7em, fill: blue)[CF-Poll])

      // Data from STA1
      line((4, y-sta1), (5, y-pc), mark: (end: ">"), stroke: (paint: green, thickness: 1.5pt))
      content((4.5, (y-pc + y-sta1)/2), anchor: "west", text(size: 0.7em, fill: green)[Data])

      // CF-Poll to STA2
      line((6, y-pc), (7, y-sta2), mark: (end: ">"), stroke: (paint: blue, thickness: 1.5pt))
      content((6.5, (y-pc + y-sta2)/2), anchor: "west", text(size: 0.7em, fill: blue)[CF-Poll])

      // CF-Null from STA2
      line((8, y-sta2), (9, y-pc), mark: (end: ">"), stroke: (paint: orange, thickness: 1.5pt))
      content((8.5, (y-pc + y-sta2)/2), anchor: "west", text(size: 0.7em, fill: orange)[CF-Null])

      // CF-Poll to STA3
      line((10, y-pc), (11, y-sta3), mark: (end: ">"), stroke: (paint: blue, thickness: 1.5pt))
      content((10.5, (y-pc + y-sta3)/2), anchor: "east", text(size: 0.7em, fill: blue)[CF-Poll])

      // Data from STA3
      line((12, y-sta3), (13, y-pc), mark: (end: ">"), stroke: (paint: green, thickness: 1.5pt))
      content((12.5, (y-pc + y-sta3)/2), anchor: "west", text(size: 0.7em, fill: green)[Data])

      // CF-End
      line((14, y-pc), (14.5, y-pc - 3.5), mark: (end: ">"), stroke: (paint: red, thickness: 2pt))
      content((15, y-pc - 1.5), anchor: "west", text(size: 0.8em, fill: red, weight: "bold")[CF-End])
    }),
    caption: [Sequenza di polling del Point Coordinator]
  )
]

=== Limitazioni del PCF

#attenzione[
Nonostante i vantaggi teorici, il PCF presenta diverse limitazioni che ne hanno limitato l'adozione pratica:
- La maggior parte dei dispositivi 802.11 non implementa il PCF (è opzionale)
- Difficoltà di coordinamento in presenza di stazioni DCF e PCF miste
- Overhead significativo dovuto ai frame CF-Poll
- Problemi con il "hidden node" che possono causare collisioni anche durante il CFP
]

=== Superframe Structure

Il PCF organizza il tempo in *superframe*, ciascuno composto da un CFP seguito da un CP. La durata del superframe è annunciata dal PC nei beacon frame.

La struttura temporale è:
$ "Superframe Duration" = "CFP Duration" + "CP Duration" $

Il Point Coordinator annuncia l'inizio del CFP con un frame *Beacon* che contiene:
- Timestamp
- Durata massima del CFP (*CFP Max Duration*)
- Parametri di configurazione

#nota[
Il CFP può terminare prima della durata massima se il PC ha completato il polling di tutte le stazioni. In questo caso, il PC trasmette un frame *CF-End* per terminare anticipatamente il CFP e permettere alle stazioni DCF di competere per il canale.
]

== Formato del Frame 802.11

Lo standard IEEE 802.11 definisce un formato di frame complesso e flessibile per supportare diverse funzionalità della rete wireless. Il frame generico è composto da diverse componenti principali.

=== Struttura Generale del Frame

Il frame 802.11 è composto da:
- *MAC Header*: contiene informazioni di controllo e indirizzamento
- *Frame Body*: payload contenente i dati
- *Frame Check Sequence (FCS)*: checksum CRC-32 per rilevamento errori

#align(center)[
  #figure(
    {
      set text(size: 0.75em)
      table(
        columns: (1.5fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 2fr, 1fr),
        align: center + horizon,
        fill: (col, row) => if row == 0 { rgb("#4472C4") } else { white },
        text(fill: white, weight: "bold")[Frame\ Control],
        text(fill: white, weight: "bold")[Duration/\ ID],
        text(fill: white, weight: "bold")[Address\ 1],
        text(fill: white, weight: "bold")[Address\ 2],
        text(fill: white, weight: "bold")[Address\ 3],
        text(fill: white, weight: "bold")[Sequence\ Control],
        text(fill: white, weight: "bold")[Address\ 4],
        text(fill: white, weight: "bold")[Frame\ Body],
        text(fill: white, weight: "bold")[FCS],
        [2 byte], [2 byte], [6 byte], [6 byte], [6 byte], [2 byte], [6 byte], [0-2312\ byte], [4 byte]
      )
    },
    caption: [Formato generale del frame MAC 802.11]
  )
]

=== Frame Control Field

Il campo *Frame Control* (2 byte) contiene diverse sottocampi che specificano il tipo e le caratteristiche del frame:

#align(center)[
  #figure(
    {
      set text(size: 0.7em)
      table(
        columns: (0.8fr, 0.8fr, 0.8fr, 0.8fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
        align: center + horizon,
        fill: (col, row) => if row == 0 { rgb("#70AD47") } else { white },
        text(fill: white, weight: "bold")[Proto\ Ver],
        text(fill: white, weight: "bold")[Type],
        text(fill: white, weight: "bold")[Sub\ type],
        text(fill: white, weight: "bold")[To\ DS],
        text(fill: white, weight: "bold")[From\ DS],
        text(fill: white, weight: "bold")[More\ Frag],
        text(fill: white, weight: "bold")[Retry],
        text(fill: white, weight: "bold")[Pwr\ Mgmt],
        text(fill: white, weight: "bold")[More\ Data],
        text(fill: white, weight: "bold")[WEP],
        text(fill: white, weight: "bold")[Rsvd],
        text(fill: white, weight: "bold")[Order],
        [2 bit], [2 bit], [4 bit], [1 bit], [1 bit], [1 bit], [1 bit], [1 bit], [1 bit], [1 bit], [1 bit], [1 bit]
      )
    },
    caption: [Struttura del campo Frame Control]
  )
]

I principali sottocampi sono:

/ *Protocol Version*: Versione del protocollo 802.11 (attualmente 0)
/ *Type e Subtype*: Identificano il tipo di frame (management, control, data)
/ *To DS / From DS*: Indicano la direzione del frame rispetto al Distribution System
/ *More Fragments*: Indica se seguono altri frammenti
/ *Retry*: Indica una ritrasmissione
/ *Power Management*: Indica lo stato di power saving della stazione
/ *WEP/Protected Frame*: Indica se il frame è cifrato

=== Tipi di Frame

Lo standard 802.11 definisce tre categorie principali di frame:

==== 1. Management Frames (Type = 00)

I frame di management gestiscono le operazioni di rete:

#esempio[
Esempi di management frames:
- *Beacon* (Subtype = 1000): trasmessi periodicamente dall'AP per annunciare la presenza della rete
- *Association Request/Response* (Subtype = 0000/0001): per l'associazione di una stazione all'AP
- *Probe Request/Response* (Subtype = 0100/0101): per la scoperta attiva delle reti
- *Authentication* (Subtype = 1011): per l'autenticazione delle stazioni
- *Deauthentication* (Subtype = 1100): per terminare l'autenticazione
]

==== 2. Control Frames (Type = 01)

I frame di controllo facilitano lo scambio di frame dati:

/ *RTS (Request to Send)*: Richiesta di prenotazione del canale (Subtype = 1011)
/ *CTS (Clear to Send)*: Conferma di prenotazione del canale (Subtype = 1100)
/ *ACK (Acknowledgment)*: Conferma ricezione corretta (Subtype = 1101)
/ *CF-End*: Termina il Contention-Free Period (Subtype = 1110)

==== 3. Data Frames (Type = 10)

I frame dati trasportano il payload effettivo. Possono includere anche funzionalità di polling nel caso di PCF.

=== Indirizzamento

Una caratteristica peculiare di 802.11 è l'utilizzo di fino a *quattro indirizzi MAC* per gestire diversi scenari di comunicazione:

#align(center)[
  #figure(
    {
      set text(size: 0.75em)
      table(
        columns: (1.2fr, 1fr, 1.5fr, 1.5fr, 1.5fr),
        align: center + horizon,
        fill: (col, row) => if row == 0 { rgb("#E7E6E6") } else { white },
        stroke: (x, y) => (
          left: if x > 0 { 0.5pt } else { 1pt },
          right: 1pt,
          top: if y == 0 { 1pt } else { 0.5pt },
          bottom: 1pt,
        ),
        text(weight: "bold")[To DS],
        text(weight: "bold")[From DS],
        text(weight: "bold")[Address 1],
        text(weight: "bold")[Address 2],
        text(weight: "bold")[Address 3],
        [0], [0], [DA (Dest.)], [SA (Source)], [BSSID],
        [0], [1], [DA], [BSSID], [SA],
        [1], [0], [BSSID], [SA], [DA],
        [1], [1], [RA (Receiver)], [TA (Transmit.)], [DA],
      )
    },
    caption: [Significato degli indirizzi in base a To DS e From DS]
  )
]

dove:
- *DA*: Destination Address (indirizzo di destinazione finale)
- *SA*: Source Address (indirizzo sorgente originale)
- *BSSID*: Basic Service Set Identifier (MAC dell'AP)
- *RA*: Receiver Address (ricevitore immediato, per WDS)
- *TA*: Transmitter Address (trasmettitore immediato, per WDS)

#nota[
Il caso To DS = 1 e From DS = 1 è utilizzato nella modalità *Wireless Distribution System (WDS)*, dove i frame viaggiano tra due Access Point attraverso il mezzo wireless. In questo scenario è necessario un quarto indirizzo (Address 4) per mantenere traccia sia del trasmettitore che del ricevitore intermedio.
]

=== Duration/ID Field

Il campo *Duration/ID* (2 byte) ha funzioni diverse in base al contesto:

- Nei frame *PS-Poll* (Power Save Poll): contiene l'Association ID della stazione
- Negli altri frame: specifica la durata in microsecondi per cui il mezzo sarà occupato, inclusi i tempi di:
  - Trasmissione del frame corrente
  - SIFS
  - Eventuale frame di risposta (ACK/CTS)

Questo meccanismo è utilizzato per il *NAV (Network Allocation Vector)*, che implementa il *virtual carrier sensing*: le stazioni che ricevono un frame aggiornano il loro NAV con la durata specificata e evitano di trasmettere per quel periodo.

=== Sequence Control Field

Il campo *Sequence Control* (2 byte) è diviso in:

- *Fragment Number* (4 bit): numero del frammento (0-15)
- *Sequence Number* (12 bit): numero di sequenza del frame (0-4095)

Questi valori permettono:
- Riassemblaggio dei frame frammentati
- Rilevamento e scarto di frame duplicati (ritrasmissioni)
- Riordino dei frame ricevuti fuori sequenza

=== Frame Body e FCS

/ *Frame Body*: Contiene il payload effettivo, con dimensione variabile da 0 a 2312 byte. Nel caso di frame dati, contiene tipicamente un pacchetto LLC/SNAP che incapsula il payload di livello superiore (es. IP).

/ *FCS (Frame Check Sequence)*: Checksum CRC-32 calcolato sull'intero frame (header + body) per rilevare errori di trasmissione. Se il CRC non corrisponde, il frame viene scartato silenziosamente.

#attenzione[
A differenza di Ethernet, 802.11 *non* ritrasmette automaticamente frame con errori CRC a livello MAC; il mittente attende un ACK e, se non lo riceve entro il timeout, ritrasmette il frame originale. Questo perché in un ambiente wireless gli errori sono molto più frequenti.
]