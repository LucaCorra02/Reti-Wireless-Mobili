#import "../template.typ": *

= WiFi (802.11)

== Point Coordination Function (PCF)

La *Point Coordination Function (PCF)* è un meccanismo di coordinamento centralizzato opzionale definito nello standard IEEE 802.11 per gestire l'accesso al mezzo trasmissivo. A differenza del DCF (Distributed Coordination Function), che è basato su CSMA/CA e quindi distribuito, il PCF implementa un approccio centralizzato basato su polling.

=== Architettura e Funzionamento

Il PCF opera attraverso un *Point Coordinator (PC)*, tipicamente implementato nell'Access Point (AP), che controlla l'accesso al canale wireless interrogando sequenzialmente le stazioni che hanno richiesto di operare in modalità PCF.

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

== Orthogonal Frequency Division Multiple Access (OFDMA)

L'*OFDMA (Orthogonal Frequency Division Multiple Access)* è una tecnologia di accesso multiplo introdotta con lo standard IEEE 802.11ax (WiFi 6) che rappresenta un'evoluzione significativa rispetto alle precedenti tecniche di modulazione utilizzate in WiFi.

=== Dal OFDM all'OFDMA

Lo standard 802.11a/g aveva introdotto *OFDM (Orthogonal Frequency Division Multiplexing)*, una tecnica di modulazione che divide il canale in multiple sottoportanti ortogonali. Tuttavia, in OFDM tradizionale, tutte le sottoportanti sono assegnate a un singolo utente per ogni trasmissione.

/*
#align(center)[
  #figure(
    cetz.canvas(length: 0.7cm, {
      import cetz.draw: *

      let w = 12
      let h-user = 1.2
      let gap = 0.5

      // OFDM tradizionale
      content((w/2, 5), text(weight: "bold", size: 1em)[OFDM tradizionale])
      
      for i in range(4) {
        let col = if i == 0 { rgb("#4472C4") } else if i == 1 { rgb("#70AD47") } else if i == 2 { rgb("#FFC000") } else { rgb("#C55A11") }
        rect((0, 3.5 - i*h-user - i*gap), (w, 3.5 - i*h-user - i*gap + h-user), fill: col, stroke: black)
        content((w/2, 3.5 - i*h-user - i*gap + h-user/2), text(fill: white, weight: "bold", size: 0.85em)[User #(i+1)])
      }

      line((w + 1, 2), (w + 2, 2), mark: (end: ">"), stroke: (thickness: 2pt))
      content((w + 1.5, 1.2), text(weight: "bold")[Tempo])

      // OFDMA
      let x-offset = w + 4
      content((x-offset + w/2, 5), text(weight: "bold", size: 1em)[OFDMA])

      let subcarrier-width = w / 4
      for i in range(4) {
        let col = if i == 0 { rgb("#4472C4") } else if i == 1 { rgb("#70AD47") } else if i == 2 { rgb("#FFC000") } else { rgb("#C55A11") }
        rect((x-offset + i*subcarrier-width, 0), (x-offset + (i+1)*subcarrier-width, 3.5), fill: col, stroke: black)
        content((x-offset + i*subcarrier-width + subcarrier-width/2, 1.75), 
                text(fill: white, weight: "bold", size: 0.85em, angle: 90deg))[User #(i+1)])
      }

      line((x-offset + w + 1, 2), (x-offset + w + 2, 2), mark: (end: ">"), stroke: (thickness: 2pt))
      content((x-offset + w + 1.5, 1.2), text(weight: "bold")[Tempo])

      // Frequency axis
      line((x-offset, -0.5), (x-offset, -1.5), mark: (end: ">"), stroke: (thickness: 2pt))
      content((x-offset - 1, -1), text(weight: "bold")[Frequenza])
    }),
    caption: [Confronto tra OFDM tradizionale e OFDMA]
  )
]
*/

L'*OFDMA* estende questo concetto permettendo di assegnare *gruppi di sottoportanti a utenti diversi simultaneamente*, migliorando drasticamente l'efficienza spettrale e riducendo la latenza.

=== Resource Unit (RU)

In OFDMA, il canale è diviso in *Resource Units (RU)*, che sono gruppi di sottoportanti consecutive assegnabili a singoli utenti. WiFi 6 definisce diverse dimensioni di RU:

#align(center)[
  #figure(
    {
      set text(size: 0.8em)
      table(
        columns: (2fr, 2fr, 2fr),
        align: center + horizon,
        fill: (col, row) => if row == 0 { rgb("#4472C4") } else if calc.rem(row, 2) == 1 { rgb("#D9E2F3") } else { white },
        text(fill: white, weight: "bold")[Dimensione RU], 
        text(fill: white, weight: "bold")[Numero sottoportanti], 
        text(fill: white, weight: "bold")[Max utenti (20 MHz)],
        [26-tone RU], [26], [9],
        [52-tone RU], [52], [4],
        [106-tone RU], [106], [2],
        [242-tone RU], [242], [1],
        [484-tone RU], [484], [1 (40 MHz)],
        [996-tone RU], [996], [1 (80 MHz)],
      )
    },
    caption: [Dimensioni delle Resource Units in WiFi 6]
  )
]

#nota[
L'Access Point può allocare dinamicamente le RU in base alle esigenze degli utenti. Ad esempio, un utente con traffico pesante può ricevere una RU da 242 toni, mentre utenti con traffico leggero (IoT) possono condividere RU più piccole da 26 toni ciascuno.
]

=== Vantaggi dell'OFDMA

L'introduzione di OFDMA porta diversi benefici significativi:

/ *Riduzione della latenza*: Più utenti possono trasmettere simultaneamente senza attendere il loro turno, riducendo il tempo di attesa medio.

/ *Maggiore efficienza*: Eliminazione del overhead temporale dovuto al CSMA/CA per ogni singola trasmissione. In OFDM tradizionale, anche un pacchetto piccolo occupa l'intero canale per la durata minima.

/ *Migliore utilizzo dello spettro*: Le risorse vengono allocate in base alle effettive necessità di ogni utente, evitando sprechi.

/ *Scalabilità*: Supporto efficiente per scenari ad alta densità (es. stadi, conferenze) con molti dispositivi connessi.

#esempio[
Scenario pratico: In un ambiente con 8 dispositivi IoT che trasmettono piccoli pacchetti periodici:
- *Con OFDM (WiFi 5)*: Ogni dispositivo deve attendere il proprio turno, con overhead CSMA/CA ad ogni trasmissione → alta latenza
- *Con OFDMA (WiFi 6)*: L'AP alloca 8 RU da 26 toni simultanee, tutti i dispositivi trasmettono nello stesso slot temporale → latenza ridotta dell'80%
]

=== Uplink e Downlink OFDMA

OFDMA opera sia in downlink che in uplink:

/ *Downlink OFDMA*: L'Access Point trasmette simultaneamente a più stazioni, allocando diverse RU a ciascuna. Questo è relativamente semplice da implementare poiché l'AP controlla completamente lo scheduling.

/ *Uplink OFDMA*: Multiple stazioni trasmettono simultaneamente all'AP su RU diverse. Questo richiede un meccanismo di *trigger frame* inviato dall'AP per sincronizzare le trasmissioni e specificare quale RU usa ogni stazione.

#align(center)[
  #figure(
    cetz.canvas(length: 0.55cm, {
      import cetz.draw: *

      let y-ap = 4
      let y-sta1 = 3
      let y-sta2 = 2
      let y-sta3 = 1

      // Entities
      content((0, y-ap), anchor: "east", text(weight: "bold", size: 0.9em)[AP])
      content((0, y-sta1), anchor: "east", text(weight: "bold", size: 0.9em)[STA 1])
      content((0, y-sta2), anchor: "east", text(weight: "bold", size: 0.9em)[STA 2])
      content((0, y-sta3), anchor: "east", text(weight: "bold", size: 0.9em)[STA 3])

      let x-start = 1
      let x-end = 20

      // Timeline
      line((x-start, y-ap), (x-end, y-ap), stroke: (dash: "dashed"))
      line((x-start, y-sta1), (x-end, y-sta1), stroke: (dash: "dashed"))
      line((x-start, y-sta2), (x-end, y-sta2), stroke: (dash: "dashed"))
      line((x-start, y-sta3), (x-end, y-sta3), stroke: (dash: "dashed"))

      // Trigger Frame
      line((2, y-ap), (2.5, y-ap - 3.5), mark: (end: ">"), stroke: (paint: purple, thickness: 2pt))
      content((3.5, y-ap - 1.5), anchor: "west", text(size: 0.75em, fill: purple, weight: "bold")[Trigger Frame])

      // Simultaneous UL transmissions
      let x-start-tx = 5
      let tx-len = 4

      // STA1 transmission
      rect((x-start-tx, y-sta1 - 0.25), (x-start-tx + tx-len, y-sta1 + 0.25), fill: rgb("#4472C4"), stroke: black)
      line((x-start-tx + tx-len, y-sta1), (x-start-tx + tx-len + 2, y-ap), mark: (end: ">"), stroke: (paint: rgb("#4472C4"), thickness: 1.5pt))

      // STA2 transmission
      rect((x-start-tx, y-sta2 - 0.25), (x-start-tx + tx-len, y-sta2 + 0.25), fill: rgb("#70AD47"), stroke: black)
      line((x-start-tx + tx-len, y-sta2), (x-start-tx + tx-len + 2, y-ap), mark: (end: ">"), stroke: (paint: rgb("#70AD47"), thickness: 1.5pt))

      // STA3 transmission
      rect((x-start-tx, y-sta3 - 0.25), (x-start-tx + tx-len, y-sta3 + 0.25), fill: rgb("#FFC000"), stroke: black)
      line((x-start-tx + tx-len, y-sta3), (x-start-tx + tx-len + 2, y-ap), mark: (end: ">"), stroke: (paint: rgb("#FFC000"), thickness: 1.5pt))

      content((x-start-tx + tx-len/2, y-sta1), text(fill: white, size: 0.65em, weight: "bold")[RU 1])
      content((x-start-tx + tx-len/2, y-sta2), text(fill: white, size: 0.65em, weight: "bold")[RU 2])
      content((x-start-tx + tx-len/2, y-sta3), text(fill: white, size: 0.65em, weight: "bold")[RU 3])

      // Multi-STA ACK
      line((x-start-tx + tx-len + 3, y-ap), (x-start-tx + tx-len + 3.5, y-ap - 3.5), mark: (end: ">"), stroke: (paint: red, thickness: 2pt))
      content((x-start-tx + tx-len + 5, y-ap - 1.5), anchor: "west", text(size: 0.75em, fill: red, weight: "bold")[Multi-STA ACK])
    }),
    caption: [Uplink OFDMA con trigger frame]
  )
]

Il *Trigger Frame* inviato dall'AP contiene:
- Allocazione delle RU per ogni stazione
- Parametri di modulazione e codifica (MCS)
- Informazioni di sincronizzazione temporale e di potenza

=== Target Wake Time (TWT) e OFDMA

OFDMA si integra con altre funzionalità di WiFi 6 come il *Target Wake Time (TWT)*, che permette ai dispositivi di negoziare quando "svegliarsi" per trasmettere/ricevere dati. Questa combinazione è particolarmente efficace per dispositivi IoT a batteria:

1. Il dispositivo negozia un TWT con l'AP (es. ogni 30 secondi)
2. Al momento stabilito, l'AP alloca una piccola RU al dispositivo
3. Il dispositivo trasmette rapidamente i suoi dati e torna in sleep mode

Questo approccio può aumentare la durata della batteria fino al 700% rispetto a WiFi 5.

== Sicurezza IEEE 802.11 - IEEE 802.11i

La sicurezza nelle reti WiFi è stata una preoccupazione critica fin dall'introduzione dello standard. L'evoluzione dei meccanismi di sicurezza ha visto il passaggio da protocolli deboli a soluzioni robuste.

=== Evoluzione della Sicurezza WiFi

==== WEP (Wired Equivalent Privacy) - Obsoleto

Il primo tentativo di proteggere le reti WiFi fu *WEP*, definito nello standard originale 802.11 del 1997. WEP utilizzava:

- Cifratura *RC4* con chiavi da 40 o 104 bit
- Vettore di inizializzazione (IV) da 24 bit
- Checksum CRC-32 per l'integrità

#attenzione[
WEP è considerato completamente insicuro e *non deve mai essere utilizzato*. Può essere violato in pochi minuti con strumenti automatizzati. Le principali vulnerabilità includono:
- IV troppo corto (24 bit) che causa riutilizzo delle chiavi
- Mancanza di gestione delle chiavi
- CRC-32 non è crittograficamente sicuro
- Vulnerabilità agli attacchi di replay e injection
]

==== WPA (WiFi Protected Access) - Transizione

WPA fu introdotto nel 2003 come soluzione temporanea in attesa di 802.11i. Miglioramenti rispetto a WEP:

- *TKIP (Temporal Key Integrity Protocol)*: rotazione dinamica delle chiavi
- IV esteso a 48 bit
- *MIC (Message Integrity Check)* con algoritmo Michael
- Gestione delle chiavi migliorata

Tuttavia, WPA mantiene RC4 per compatibilità hardware con dispositivi WEP esistenti, e presenta ancora alcune vulnerabilità.

=== IEEE 802.11i (WPA2)

Lo standard *IEEE 802.11i*, ratificato nel 2004 e commercializzato come *WPA2*, rappresenta un riprogettazione completa della sicurezza WiFi.

==== Architettura di Sicurezza

L'architettura 802.11i si basa su diversi componenti chiave:

#align(center)[
  #figure(
    cetz.canvas(length: 0.8cm, {
      import cetz.draw: *

      let box-style = (stroke: black, radius: 0.3)
      let w = 4
      let h = 1.5

      // Layer structure
      rect((0, 4), (w, 4 + h), ..box-style, fill: rgb("#4472C4"))
      content((w/2, 4 + h/2), text(fill: white, weight: "bold")[802.1X/EAP\ Authentication])

      rect((0, 2.2), (w, 2.2 + h), ..box-style, fill: rgb("#70AD47"))
      content((w/2, 2.2 + h/2), text(fill: white, weight: "bold")[Key Management\ (4-Way Handshake)])

      rect((0, 0.4), (w, 0.4 + h), ..box-style, fill: rgb("#FFC000"))
      content((w/2, 0.4 + h/2), text(fill: white, weight: "bold")[Data Encryption\ (CCMP/AES)])

      // Arrows
      line((w/2, 4), (w/2, 3.7), mark: (end: ">"), stroke: (thickness: 1.5pt))
      line((w/2, 2.2), (w/2, 1.9), mark: (end: ">"), stroke: (thickness: 1.5pt))

      // Labels
      content((w + 2.5, 4 + h/2), anchor: "west", text(size: 0.85em)[Chi sei?])
      content((w + 2.5, 2.2 + h/2), anchor: "west", text(size: 0.85em)[Scambio chiavi])
      content((w + 2.5, 0.4 + h/2), anchor: "west", text(size: 0.85em)[Protezione dati])
    }),
    caption: [Architettura di sicurezza IEEE 802.11i]
  )
]

==== CCMP (Counter Mode with CBC-MAC Protocol)

Il protocollo di cifratura principale di 802.11i è *CCMP*, che sostituisce completamente RC4/TKIP:

/ *Algoritmo*: *AES (Advanced Encryption Standard)* con chiavi a 128 bit

/ *Modalità di cifratura*: *CCM (Counter Mode)* per la confidenzialità

/ *Integrità*: *CBC-MAC* per autenticazione e integrità del messaggio

/ *Packet Number*: 48 bit, prevenendo attacchi di replay

La struttura di un frame cifrato CCMP è:

#align(center)[
  #figure(
    {
      set text(size: 0.75em)
      table(
        columns: (1.5fr, 1fr, 2fr, 1fr, 1fr),
        align: center + horizon,
        fill: (col, row) => if row == 0 { rgb("#70AD47") } else { white },
        text(fill: white, weight: "bold")[MAC\ Header],
        text(fill: white, weight: "bold")[CCMP\ Header],
        text(fill: white, weight: "bold")[Encrypted Data\ + MIC],
        text(fill: white, weight: "bold")[MIC],
        text(fill: white, weight: "bold")[FCS],
        [], [8 byte], [variabile], [8 byte], [4 byte]
      )
    },
    caption: [Formato frame con CCMP]
  )
]

Il *CCMP Header* contiene:
- Packet Number (PN) di 48 bit diviso in 6 byte
- Key ID (identifica quale chiave usare)
- Reserved bits

#nota[
AES-CCMP è considerato crittograficamente sicuro e resiste agli attacchi noti. L'utilizzo di AES con hardware dedicato permette anche prestazioni elevate senza impatto significativo sul throughput.
]

==== Modalità di Autenticazione

802.11i supporta due modalità operative:

===== 1. WPA2-Personal (Pre-Shared Key - PSK)

Utilizzata in ambienti domestici e piccole reti:

- *Passphrase*: 8-63 caratteri ASCII o 256 bit esadecimali
- La *PSK* viene derivata dalla passphrase usando *PBKDF2*:
  $ "PSK" = "PBKDF2"("passphrase", "SSID", 4096, 256) $

- *PMK (Pairwise Master Key)* = PSK
- Stessa chiave condivisa tra tutte le stazioni e l'AP

#attenzione[
In modalità PSK, se la passphrase viene compromessa, l'intera rete è vulnerabile. È fondamentale usare passphrase complesse (≥ 20 caratteri casuali) e cambiarle periodicamente.
]

===== 2. WPA2-Enterprise (802.1X/EAP)

Utilizzata in ambienti aziendali e istituzioni:

- Richiede un *Authentication Server* (tipicamente RADIUS)
- Ogni utente ha credenziali individuali
- Supporta diversi metodi EAP (EAP-TLS, PEAP, EAP-TTLS, EAP-SIM, ecc.)
- Gestione centralizzata delle credenziali e delle policy

#align(center)[
  #figure(
    cetz.canvas(length: 0.6cm, {
      import cetz.draw: *

      let y-client = 3
      let y-ap = 2
      let y-radius = 1

      // Entities
      content((0, y-client), anchor: "east", text(weight: "bold", size: 0.9em)[Client\ (Supplicant)])
      content((0, y-ap), anchor: "east", text(weight: "bold", size: 0.9em)[AP\ (Authenticator)])
      content((0, y-radius), anchor: "east", text(weight: "bold", size: 0.9em)[RADIUS\ (Auth Server)])

      let x-start = 1
      let x-end = 18

      // Timelines
      line((x-start, y-client), (x-end, y-client), stroke: (dash: "dashed"))
      line((x-start, y-ap), (x-end, y-ap), stroke: (dash: "dashed"))
      line((x-start, y-radius), (x-end, y-radius), stroke: (dash: "dashed"))

      // Association
      line((2, y-client), (3, y-ap), mark: (end: ">"), stroke: (paint: blue, thickness: 1.2pt))
      content((2.5, (y-client + y-ap)/2), anchor: "west", text(size: 0.7em, fill: blue)[Association])

      // EAP Start
      line((4, y-client), (5, y-ap), mark: (end: ">"), stroke: (paint: green, thickness: 1.2pt))
      content((4.5, (y-client + y-ap)/2), anchor: "west", text(size: 0.7em, fill: green)[EAP Start])

      // EAP Request Identity
      line((6, y-ap), (7, y-client), mark: (end: ">"), stroke: (paint: orange, thickness: 1.2pt))
      content((6.5, (y-client + y-ap)/2), anchor: "west", text(size: 0.7em, fill: orange)[EAP Req Identity])

      // EAP Response Identity
      line((8, y-client), (9, y-ap), mark: (end: ">"), stroke: (paint: purple, thickness: 1.2pt))
      line((9, y-ap), (10, y-radius), mark: (end: ">"), stroke: (paint: purple, thickness: 1.2pt))
      content((8.5, (y-client + y-ap)/2), anchor: "east", text(size: 0.7em, fill: purple)[EAP Resp])

      // Authentication Exchange (bidirectional)
      line((11, y-radius), (12, y-ap), mark: (end: ">"), stroke: (paint: maroon, thickness: 1.2pt))
      line((12, y-ap), (13, y-client), mark: (end: ">"), stroke: (paint: maroon, thickness: 1.2pt))
      content((11.5, y-ap + 0.7), text(size: 0.7em, fill: maroon)[EAP Auth])

      // Success
      line((14, y-radius), (15, y-ap), mark: (end: ">"), stroke: (paint: rgb("#70AD47"), thickness: 1.5pt))
      line((15, y-ap), (16, y-client), mark: (end: ">"), stroke: (paint: rgb("#70AD47"), thickness: 1.5pt))
      content((14.5, (y-radius + y-ap)/2), anchor: "west", text(size: 0.7em, fill: rgb("#70AD47"), weight: "bold")[EAP Success + PMK])
    }),
    caption: [Flusso di autenticazione 802.1X/EAP]
  )
]

==== 4-Way Handshake

Dopo l'autenticazione, il *4-Way Handshake* deriva le chiavi di sessione dalla PMK:

1. *AP → Client*: Nonce dell'AP (ANonce)
2. *Client → AP*: Nonce del client (SNonce) + MIC
3. *AP → Client*: GTK (Group Temporal Key) + MIC
4. *Client → AP*: ACK + MIC

Durante questo processo vengono derivate:

/ *PTK (Pairwise Transient Key)*: Chiave unicast specifica per la sessione tra AP e client, derivata da:
  $ "PTK" = "PRF"("PMK", "ANonce", "SNonce", "MAC"_"AP", "MAC"_"Client") $

/ *GTK (Group Temporal Key)*: Chiave per il traffico broadcast/multicast, generata dall'AP e distribuita a tutti i client.

#esempio[
Il 4-Way Handshake garantisce:
- *Mutua autenticazione*: entrambe le parti dimostrano il possesso della PMK
- *Freshness*: i nonce prevengono attacchi replay
- *Derivazione di chiavi di sessione*: chiavi temporanee diverse per ogni associazione
- *Sincronizzazione*: conferma che entrambe le parti sono pronte a iniziare la cifratura
]

=== WPA3 (dal 2018)

WPA3 introduce ulteriori miglioramenti:

/ *SAE (Simultaneous Authentication of Equals)*: Sostituisce il PSK nelle reti Personal con un protocollo più sicuro basato su Dragonfly key exchange, resistente ad attacchi dizionario offline.

/ *Forward Secrecy*: Anche se la passphrase viene compromessa in futuro, il traffico precedentemente catturato rimane protetto.

/ *Protected Management Frames (PMF)*: Obbligatorio, protegge i frame di management da spoofing e manipolazione.

/ *192-bit Security Suite*: Disponibile in WPA3-Enterprise per ambienti ad alta sicurezza (governo, difesa).

/ *Easy Connect*: Semplifica l'onboarding di dispositivi IoT senza display tramite QR code.

#nota[
WPA3 è retrocompatibile con WPA2 attraverso la modalità *Transition Mode*, permettendo la coesistenza di dispositivi WPA2 e WPA3 sulla stessa rete durante la fase di migrazione.
]

=== Vulnerabilità Note e Mitigazioni

Anche 802.11i/WPA2 ha avuto vulnerabilità scoperte nel tempo:

==== KRACK (Key Reinstallation Attack) - 2017

Attacco al 4-Way Handshake che forza la reinstallazione della PTK, permettendo il replay di pacchetti e, in alcuni casi, la decifrazione del traffico.

*Mitigazione*: Aggiornamenti firmware che prevengono la reinstallazione delle chiavi.

==== Attacchi a WPS (WiFi Protected Setup)

WPS, un meccanismo per semplificare la configurazione, presenta gravi vulnerabilità nel metodo PIN che permettono di recuperare la passphrase WPA2.

*Mitigazione*: Disabilitare completamente WPS nelle configurazioni di produzione.

#attenzione[
Best practices per la sicurezza WiFi:
1. Utilizzare WPA3 dove possibile, altrimenti WPA2 con AES-CCMP
2. Disabilitare WPS completamente
3. Usare passphrase complesse (≥20 caratteri) in modalità Personal
4. Implementare 802.1X/EAP in ambienti enterprise
5. Abilitare Protected Management Frames (PMF/802.11w)
6. Mantenere firmware di AP e client aggiornati
7. Nascondere SSID solo come misura di security-by-obscurity aggiuntiva, non primaria
8. Implementare segmentazione della rete (VLAN)
]

== WiFi 6 (802.11ax) - Approfondimento

Lo standard *IEEE 802.11ax*, commercialmente noto come *WiFi 6* (e WiFi 6E per la banda 6 GHz), rappresenta un'evoluzione significativa rispetto a WiFi 5 (802.11ac), focalizzandosi non solo su prestazioni peak più elevate, ma soprattutto su *efficienza* e *performance in ambienti densi*.

=== Obiettivi di Progettazione

WiFi 6 è stato progettato per rispondere a scenari d'uso moderni:

- *Alta densità*: Stadi, aeroporti, conference center con centinaia di dispositivi
- *IoT*: Miliardi di dispositivi connessi con requisiti di potenza e banda variabili
- *Latency-sensitive applications*: Gaming, AR/VR, controllo industriale
- *Efficienza energetica*: Prolungare la durata della batteria dei dispositivi mobili

#nota[
Mentre WiFi 5 (802.11ac) raggiungeva velocità teoriche di 6.9 Gbps, WiFi 6 arriva fino a *9.6 Gbps*. Ma la vera innovazione è nel throughput aggregato in scenari multi-utente, che può essere *4 volte superiore* rispetto a WiFi 5.
]

=== Tecnologie Chiave

==== 1. OFDMA (già trattato)

Come discusso nella sezione precedente, OFDMA permette di suddividere il canale in Resource Units allocabili a utenti diversi simultaneamente.

==== 2. MU-MIMO Migliorato

WiFi 5 introduceva *MU-MIMO (Multi-User Multiple Input Multiple Output)* solo in downlink. WiFi 6 estende MU-MIMO anche all'*uplink*:

- Supporto fino a *8 stream simultanei* (vs 4 in WiFi 5)
- *Uplink MU-MIMO*: multiple stazioni trasmettono contemporaneamente all'AP
- Maggiore capacità totale della rete

#align(center)[
  #figure(
    {
      set text(size: 0.75em)
      table(
        columns: (2.5fr, 1.5fr, 1.5fr),
        align: center + horizon,
        fill: (col, row) => if row == 0 { rgb("#4472C4") } else if calc.rem(row, 2) == 1 { rgb("#D9E2F3") } else { white },
        text(fill: white, weight: "bold")[Caratteristica],
        text(fill: white, weight: "bold")[WiFi 5\ (802.11ac)],
        text(fill: white, weight: "bold")[WiFi 6\ (802.11ax)],
        [MU-MIMO Downlink], [✓ (4 stream)], [✓ (8 stream)],
        [MU-MIMO Uplink], [✗], [✓ (8 stream)],
        [OFDMA], [✗], [✓],
        [Max Stream per utente], [4], [8],
        [Modulazione max], [256-QAM], [1024-QAM],
      )
    },
    caption: [Confronto MU-MIMO tra WiFi 5 e WiFi 6]
  )
]

==== 3. 1024-QAM

WiFi 6 introduce la modulazione *1024-QAM (Quadrature Amplitude Modulation)*, che permette di codificare 10 bit per simbolo invece di 8 (256-QAM):

$ "Bit per simbolo": 256"-QAM" = 8, quad 1024"-QAM" = 10 $

Questo porta a un aumento teorico del throughput del *25%* in condizioni di segnale ottimali (SNR elevato).

#attenzione[
1024-QAM richiede un SNR (Signal-to-Noise Ratio) molto elevato e funziona efficacemente solo a distanze ridotte con segnale forte. In condizioni reali, spesso si ricade su modulazioni inferiori (64-QAM, 16-QAM) per mantenere l'affidabilità.
]

==== 4. Target Wake Time (TWT)

Il *Target Wake Time* è una funzionalità fondamentale per dispositivi IoT e mobile:

- Il dispositivo negozia con l'AP *quando* attivarsi per trasmettere/ricevere
- Durante i periodi inattivi, la radio può essere completamente spenta
- Riduzione del consumo energetico fino al *70%*

#esempio[
Un sensore IoT che invia dati ogni 5 minuti:
1. Negozia con l'AP un TWT ogni 5 minuti
2. Il sensore va in deep sleep per 4 minuti e 59 secondi
3. Si riattiva al momento concordato, trasmette i dati
4. Riceve eventuali comandi dall'AP
5. Torna in sleep

Rispetto a WiFi 5, dove il dispositivo dovrebbe svegliarsi ad ogni beacon (~100ms) per controllare se ci sono dati, il risparmio energetico è drammatico.
]

==== 5. BSS Coloring

Il *BSS (Basic Service Set) Coloring* è una tecnica per migliorare l'efficienza spettrale in ambienti con multiple reti sovrapposte:

- Ogni BSS (rete WiFi) viene marcato con un "colore" (identificatore di 6 bit: 0-63)
- Il colore viene incluso nel preambolo di ogni frame
- Le stazioni possono distinguere frame della propria BSS da quelli di BSS vicine
- Se un frame appartiene a un BSS diverso e il segnale è sufficientemente basso, la stazione può trasmettere comunque (*Spatial Reuse*)

#align(center)[
  #figure(
    cetz.canvas(length: 0.7cm, {
      import cetz.draw: *

      // AP positions
      let ap1 = (2, 3)
      let ap2 = (8, 3)

      // Draw APs
      circle(ap1, radius: 0.4, fill: rgb("#4472C4"), stroke: black)
      content(ap1, text(fill: white, weight: "bold", size: 0.8em)[AP1])
      content((ap1.at(0), ap1.at(1) - 1), text(weight: "bold", fill: rgb("#4472C4"))[Color: 10])

      circle(ap2, radius: 0.4, fill: rgb("#ED7D31"), stroke: black)
      content(ap2, text(fill: white, weight: "bold", size: 0.8em)[AP2])
      content((ap2.at(0), ap2.at(1) - 1), text(weight: "bold", fill: rgb("#ED7D31"))[Color: 25])

      // Coverage areas (overlapping)
      circle(ap1, radius: 3, stroke: (paint: rgb("#4472C4"), thickness: 2pt, dash: "dashed"), fill: none)
      circle(ap2, radius: 3, stroke: (paint: rgb("#ED7D31"), thickness: 2pt, dash: "dashed"), fill: none)

      // Client stations
      let sta1 = (2, 1)
      let sta2 = (5, 2)
      let sta3 = (8, 1)

      rect((sta1.at(0) - 0.3, sta1.at(1) - 0.25), (sta1.at(0) + 0.3, sta1.at(1) + 0.25), fill: rgb("#4472C4"), stroke: black)
      content((sta1.at(0), sta1.at(1) - 0.7), text(size: 0.75em)[STA A])

      rect((sta2.at(0) - 0.3, sta2.at(1) - 0.25), (sta2.at(0) + 0.3, sta2.at(1) + 0.25), fill: white, stroke: black)
      content((sta2.at(0), sta2.at(1) - 0.7), text(size: 0.75em)[STA B])

      rect((sta3.at(0) - 0.3, sta3.at(1) - 0.25), (sta3.at(0) + 0.3, sta3.at(1) + 0.25), fill: rgb("#ED7D31"), stroke: black)
      content((sta3.at(0), sta3.at(1) - 0.7), text(size: 0.75em)[STA C])

      // Legend
      content((5, 6.5), text(weight: "bold")[Zona di overlap])
      content((5, 6), text(size: 0.8em)[STA B rileva frame di entrambi i BSS])
      content((5, 5.5), text(size: 0.8em)[Con BSS Coloring può riusare il canale])
    }),
    caption: [BSS Coloring e Spatial Reuse]
  )
]

Senza BSS Coloring, la STA B in zona di overlap dovrebbe attendere che entrambi i canali siano liberi. Con BSS Coloring, se rileva un frame con colore diverso dal proprio e il RSSI è sotto una soglia configurabile, può comunque trasmettere.

==== 6. Extended Range

WiFi 6 migliora la portata attraverso diverse ottimizzazioni:

- *OFDM Symbol Duration* raddoppiato: da 3.2 μs a 6.4 μs (default)
  - Maggiore robustezza al multipath delay spread
  - Migliore performance in ambienti outdoor e grandi spazi

- *Guard Interval* più lungo opzionale: fino a 3.2 μs
  - Ulteriore protezione contro interferenza inter-simbolo

=== WiFi 6E - Banda 6 GHz

Nel 2020, molti paesi hanno aperto la banda *6 GHz (5.925-7.125 GHz)* per uso WiFi non licenziato, dando vita a *WiFi 6E*:

/ *1200 MHz di spettro aggiuntivo*: Più di quanto disponibile in 2.4 GHz e 5 GHz combinati

/ *Canali ultra-wide*: Fino a *7 canali da 160 MHz* o *3 canali da 320 MHz* (con WiFi 7)

/ *Nessuna interferenza legacy*: Solo dispositivi WiFi 6E/7, nessun 802.11a/n/ac

/ *Prestazioni ottimali*: Latenza ridotta e throughput elevato garantiti

#align(center)[
  #figure(
    {
      set text(size: 0.75em)
      table(
        columns: (2fr, 1.5fr, 1.5fr, 1.5fr),
        align: center + horizon,
        fill: (col, row) => if row == 0 { rgb("#70AD47") } else if calc.rem(row, 2) == 1 { rgb("#E2EFD9") } else { white },
        text(fill: white, weight: "bold")[Banda],
        text(fill: white, weight: "bold")[Spettro],
        text(fill: white, weight: "bold")[Canali 80 MHz],
        text(fill: white, weight: "bold")[Canali 160 MHz],
        [2.4 GHz], [~80 MHz], [0], [0],
        [5 GHz], [~500 MHz], [6], [2],
        [6 GHz], [~1200 MHz], [14], [7],
      )
    },
    caption: [Disponibilità spettrale WiFi 6E]
  )
]

#nota[
WiFi 6E è ideale per:
- *Streaming 4K/8K* senza compressione
- *VR/AR wireless* con latenza ultra-bassa
- *Enterprise high-density* con centinaia di client
- *Backhaul wireless* per mesh network
]

=== Benefici Pratici

In sintesi, WiFi 6 porta miglioramenti concreti:

/ *Throughput in ambienti densi*: 4x rispetto a WiFi 5 in scenari tipici (aeroporti, stadi)

/ *Latenza ridotta*: Fino a 75% in meno, critico per gaming e applicazioni real-time

/ *Durata batteria*: Aumento fino a 7x per dispositivi IoT grazie a TWT

/ *Capacità*: Supporto di 4x più dispositivi simultanei per AP

/ *Efficienza spettrale*: Migliore utilizzo dello spettro disponibile tramite OFDMA e Spatial Reuse

== IEEE 802.11p - WiFi Veicolare (WAVE)

Lo standard *IEEE 802.11p* è una modifica di 802.11a progettata specificamente per le comunicazioni *V2X (Vehicle-to-Everything)* in ambienti veicolari. Viene anche chiamato *WAVE (Wireless Access in Vehicular Environments)*.

=== Motivazione e Scenari d'Uso

Le comunicazioni veicolari presentano requisiti unici:

- *Alta mobilità relativa*: Veicoli che si muovono a velocità elevate (fino a 200+ km/h relativi)
- *Latenza critica*: Messaggi di sicurezza devono essere consegnati in millisecondi
- *Connessioni brevi*: Veicoli entrano ed escono rapidamente dal raggio di comunicazione
- *Nessuna infrastruttura*: Comunicazione diretta V2V (Vehicle-to-Vehicle)

#esempio[
Scenari applicativi di 802.11p:
1. *Collision Warning*: Un veicolo frena bruscamente e avvisa immediatamente i veicoli dietro
2. *Intersection Collision Avoidance*: Veicoli comunicano la loro posizione e velocità agli incroci
3. *Emergency Vehicle Approaching*: Ambulanze/pompieri segnalano la loro presenza
4. *Road Hazard Warning*: Segnalazione di buche, ghiaccio, ostacoli sulla strada
5. *Cooperative Adaptive Cruise Control*: Platooning di veicoli con controllo coordinato
]

=== Caratteristiche Tecniche

==== Banda di Frequenza

802.11p opera nella banda *5.9 GHz (5.850-5.925 GHz)*, specificamente allocata per ITS (Intelligent Transportation Systems) in molti paesi:

- *Stati Uniti/Canada*: 75 MHz (5.850-5.925 GHz) - DSRC
- *Europa*: 70 MHz (5.875-5.905 GHz) - ITS-G5
- *Giappone*: 80 MHz allocati similmente

#align(center)[
  #figure(
    {
      set text(size: 0.7em)
      table(
        columns: (1.5fr, 1fr, 1fr, 2fr),
        align: center + horizon,
        stroke: (x, y) => (
          left: 0.5pt,
          right: 0.5pt,
          top: if y == 0 { 1pt } else { 0.5pt },
          bottom: 1pt,
        ),
        fill: (col, row) => if row == 0 { rgb("#4472C4") } else if calc.rem(row, 2) == 1 { rgb("#D9E2F3") } else { white },
        text(fill: white, weight: "bold")[Canale],
        text(fill: white, weight: "bold")[Frequenza\ (MHz)],
        text(fill: white, weight: "bold")[Banda\ (MHz)],
        text(fill: white, weight: "bold")[Utilizzo],
        [172], [5860], [10], [Sicurezza critica],
        [174], [5870], [10], [Sicurezza],
        [176], [5880], [10], [Sicurezza],
        [178], [5890], [10], [Servizi pubblici],
        [180], [5900], [10], [Servizi privati],
        [182], [5910], [10], [Applicazioni future],
      )
    },
    caption: [Allocazione canali 802.11p (esempio US DSRC)]
  )
]

==== Modifiche Rispetto a 802.11a

802.11p introduce diverse modifiche rispetto allo standard 802.11a di base:

/ *Larghezza di banda dimezzata*: 10 MHz invece di 20 MHz
  - Riduce l'effetto Doppler dovuto all'alta velocità relativa
  - Raddoppia la durata del simbolo OFDM (da 4 μs a 8 μs)
  - Migliora la robustezza al delay spread in ambiente urbano

/ *Nessuna associazione*: Eliminazione della fase di associazione/autenticazione
  - I frame vengono scambiati immediatamente senza handshake preliminare
  - Latenze ridotte a < 50 ms dalla ricezione del segnale

/ *Outside Context of BSS (OCB)*: Modalità di operazione ad-hoc migliorata
  - Non richiede formazione di una BSS
  - Comunicazione peer-to-peer diretta

#nota[
La riduzione della larghezza di banda a 10 MHz dimezza il data rate rispetto a 802.11a (da 54 Mbps a 27 Mbps massimi), ma questo è accettabile dato che i messaggi veicolari sono tipicamente piccoli (centinaia di byte) e la robustezza è prioritaria rispetto al throughput.
]

=== Architettura WAVE

L'architettura completa WAVE include diversi standard complementari:

#align(center)[
  #figure(
    cetz.canvas(length: 0.7cm, {
      import cetz.draw: *

      let box-style = (stroke: black, radius: 0.2)
      let w = 5
      let h = 1

      // Stack layers
      rect((0, 4), (w, 4 + h), ..box-style, fill: rgb("#C55A11"))
      content((w/2, 4 + h/2), text(fill: white, weight: "bold", size: 0.85em)[Applications\ (Safety, Traffic, Infotainment)])

      rect((0, 3), (w, 3 + h), ..box-style, fill: rgb("#4472C4"))
      content((w/2, 3 + h/2), text(fill: white, weight: "bold", size: 0.85em)[IEEE 1609.3\ (Networking)])

      rect((0, 2), (w, 2 + h), ..box-style, fill: rgb("#70AD47"))
      content((w/2, 2 + h/2), text(fill: white, weight: "bold", size: 0.85em)[IEEE 1609.4\ (Multi-Channel)])

      rect((0, 0.5), (w/2- 0.1, 0.5 + 1.3), ..box-style, fill: rgb("#FFC000"))
      content((w/4, 0.5 + 0.65), text(fill: white, weight: "bold", size: 0.8em)[IEEE 802.11p\ MAC])

      rect((w/2 + 0.1, 0.5), (w, 0.5 + 1.3), ..box-style, fill: rgb("#FFC000"))
      content((3*w/4, 0.5 + 0.65), text(fill: white, weight: "bold", size: 0.8em)[IEEE 802.11p\ PHY])

      // Labels
      content((w + 2, 4 + h/2), anchor: "west", text(size: 0.75em)[SAE J2735])
      content((w + 2, 3 + h/2), anchor: "west", text(size: 0.75em)[WSMP])
      content((w + 2, 2 + h/2), anchor: "west", text(size: 0.75em)[Channel Coord.])
      content((w + 2, 1.15), anchor: "west", text(size: 0.75em)[DSRC/ITS-G5])
    }),
    caption: [Stack protocollare WAVE]
  )
]

/ *IEEE 1609.4*: Gestisce l'operazione multi-canale, alternando tra Control Channel (CCH) e Service Channels (SCH)

/ *IEEE 1609.3*: WAVE Short Message Protocol (WSMP) per messaggistica efficiente, alternativa a IPv6 per messaggi safety-critical

/ *SAE J2735*: Definisce i messaggi standard (BSM - Basic Safety Message, MAP, SPAT, ecc.)

=== Basic Safety Message (BSM)

Il *BSM* è il messaggio fondamentale in WAVE, trasmesso periodicamente (10 Hz tipicamente) da ogni veicolo:

Contenuto di un BSM Part 1 (base):
- Posizione GPS (latitudine, longitudine)
- Velocità e heading
- Accelerazione
- Stato dei freni
- Dimensioni del veicolo
- Timestamp

BSM Part 2 (opzionale) può includere:
- Stato delle luci (frecce, freni, emergenza)
- Informazioni su eventi (airbag attivati, ABS attivo)
- Percorso previsto

#attenzione[
La dimensione tipica di un BSM è ~200-300 byte. Trasmesso a 10 Hz, ogni veicolo genera ~20-30 Kbps di traffico. In scenari ad alta densità (100+ veicoli nel raggio), la congestione del canale diventa critica.
]

=== Gestione Multi-Canale

802.11p definisce 7 canali da 10 MHz. Il funzionamento tipico prevede:

- *CCH (Control Channel)*: Canale 178 (5890 MHz)
  - Utilizzato per messaggi safety-critical (BSM)
  - Sempre accessibile durante gli intervalli CCH

- *SCH (Service Channels)*: Canali 172, 174, 176, 180, 182, 184
  - Utilizzati per applicazioni non-safety (infotainment, aggiornamenti mappe)

Il protocollo IEEE 1609.4 definisce l'alternanza temporale:

#align(center)[
  #figure(
    cetz.canvas(length: 0.7cm, {
      import cetz.draw: *

      let w = 4
      let h = 1.2

      // CCH intervals
      for i in range(4) {
        let x = i * 2 * (w + 0.3)
        rect((x, 0), (x + w, h), fill: rgb("#E74C3C"), stroke: black)
        content((x + w/2, h/2), text(fill: white, weight: "bold")[CCH])
        content((x + w/2, h + 0.6), text(size: 0.75em)[50 ms])
      }

      // SCH intervals
      for i in range(4) {
        let x = i * 2 * (w + 0.3) + w + 0.3
        if i < 3 {
          rect((x, 0), (x + w, h), fill: rgb("#3498DB"), stroke: black)
          content((x + w/2, h/2), text(fill: white, weight: "bold")[SCH])
          content((x + w/2, h + 0.6), text(size: 0.75em)[50 ms])
        }
      }

      // Time axis
      line((0, -0.8), (3 * 2 * (w + 0.3), -0.8), mark: (end: ">"))
      content((1.5 * 2 * (w + 0.3), -1.2), text(weight: "bold")[Tempo])

      content((w, -2), text(size: 0.8em)[Sync Interval = 100 ms])
    }),
    caption: [Alternanza tra CCH e SCH in 802.11p]
  )
]

Ogni *Sync Interval* dura 100 ms:
- 50 ms sul CCH (safety messages)
- 50 ms su SCH (applicazioni)

=== Sicurezza e Privacy

Le comunicazioni V2X sollevano importanti questioni di sicurezza e privacy:

/ *Autenticazione dei messaggi*: Utilizzo di certificati digitali per firmare i BSM
  - Previene injection di messaggi falsi (attacchi Sybil)
  - Standard IEEE 1609.2 per sicurezza

/ *Privacy*: Cambio frequente di pseudonimi
  - I certificati vengono cambiati ogni pochi minuti
  - Previene il tracking dei veicoli

/ *Gestione delle credenziali*: PKI (Public Key Infrastructure) gerarchica
  - Root CA gestito da autorità governative
  - Enrollment CA per registrazione veicoli
  - Authorization CA per emissione certificati

#nota[
Ogni veicolo è dotato di un pool di certificati pseudonimi (tipicamente 20-30) che vengono ruotati per bilanciare autenticità e privacy. Il cambio avviene in momenti strategici (es. quando non ci sono altri veicoli visibili) per evitare correlazione.
]

=== Sfide e Limitazioni

802.11p affronta diverse sfide:

/ *Congestione del canale*: In scenari ad alta densità, il CCH può saturarsi
  - Tecniche di congestion control (adattamento rate BSM)
  - Potenza di trasmissione adattiva

/ *Interferenze*: Banda 5.9 GHz può avere interferenze da radar militari (in alcuni paesi)

/ *Adozione limitata*: Costi di deployment e mancanza di massa critica
  - Richiede equipaggiamento sia veicolare (OBU) che infrastrutturale (RSU)

/ *Competizione con C-V2X*: Tecnologia alternativa basata su LTE/5G promossa principalmente da Qualcomm e industria telecomunicazioni

=== Evoluzione: C-V2X e 5G NR-V2X

Negli ultimi anni, *C-V2X (Cellular V2X)* basato su 3GPP Release 14/15/16 ha emergeds come alternativa:

#align(center)[
  #figure(
    {
      set text(size: 0.75em)
      table(
        columns: (2fr, 1.5fr, 1.5fr),
        align: center + horizon,
        fill: (col, row) => if row == 0 { rgb("#4472C4") } else if calc.rem(row, 2) == 1 { rgb("#D9E2F3") } else { white },
        text(fill: white, weight: "bold")[Caratteristica],
        text(fill: white, weight: "bold")[802.11p\ (DSRC)],
        text(fill: white, weight: "bold")[C-V2X\ (PC5)],
        [Latenza], [< 50 ms], [< 20 ms],
        [Range tipico], [300-500 m], [500-1000 m],
        [Mobilità], [Fino a 250 km/h], [Fino a 500 km/h],
        [Infrastruttura], [Non necessaria], [Opzionale],
        [Evoluzione], [IEEE 802.11bd (NGV)], [5G NR-V2X],
        [Deployment], [USA (parziale), EU, JP], [Cina, alcuni paesi EU],
      )
    },
    caption: [Confronto tra 802.11p e C-V2X]
  )
]

La standardizzazione *IEEE 802.11bd* (Next Generation V2X) sta evolvendo 802.11p con:
- Raddoppio del throughput
- Migliore robustezza con MCS aggiuntivi
- Supporto per MIMO 2x2
- Retrocompatibilità con 802.11p

#nota[
Il dibattito tra 802.11p e C-V2X continua, con diverse regioni che adottano approcci differenti. L'Europa sta considerando un approccio ibrido, mentre la Cina ha standardizzato su C-V2X. Gli Stati Uniti hanno recentemente ridotto la banda allocata a DSRC (da 75 MHz a 30 MHz) a favore di WiFi 6E, creando incertezza sul futuro di 802.11p.
]

=== Conclusioni

802.11p/WAVE rappresenta un'applicazione specializzata di WiFi per un dominio critico: la sicurezza stradale. Le sue caratteristiche uniche (nessuna associazione, robustezza ad alta velocità, latenza ultra-bassa) lo rendono adatto per comunicazioni veicolari safety-critical.

Tuttavia, l'adozione limitata e la competizione con C-V2X indicano che il futuro delle comunicazioni V2X potrebbe essere dual-mode o evolversi verso soluzioni 5G-based, mantenendo comunque i principi di comunicazione diretta (sidelink) e priorità alla sicurezza sviluppati con 802.11p.

