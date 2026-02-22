#import "../template.typ": *

= QoS in WiFi e Reti Veicolari

== IEEE 802.11e - EDCA (Enhanced Distributed Channel Access)

Lo standard *IEEE 802.11e* introduce meccanismi di *Quality of Service (QoS)* nelle reti WiFi attraverso l'*EDCA (Enhanced Distributed Channel Access)*, un'evoluzione del DCF che permette di differenziare il traffico in base alla priorità.

=== Access Categories (AC)

EDCA definisce *quattro categorie di accesso* (Access Categories) che mappano diversi tipi di traffico a livelli di priorità differenti. Ogni categoria è caratterizzata da quattro parametri principali che ne determinano il comportamento nell'accesso al canale.

#align(center)[
  #figure(
    table(
      columns: (2fr, 1fr, 1fr, 1fr, 1.5fr, 2fr),
      align: center + horizon,
      [*Access Category*], [*CW_min*], [*CW_max*], [*AIFSN*], [*TXOP Limit*], [*Tipo di Traffico*],
      [AC_VO (Voice)], [3], [7], [2], [1.5 ms], [VoIP, telefonia],
      [AC_VI (Video)], [7], [15], [2], [3.0 ms], [Streaming video],
      [AC_BE (Best Effort)], [15], [1023], [3], [0], [Web, email],
      [AC_BK (Background)], [15], [1023], [7], [0], [Trasferimenti file],
    ),
    caption: [Parametri EDCA per le quattro Access Categories]
  )
]

I quattro parametri che definiscono il comportamento di ciascuna *Access Category* sono:

/ *CW_min (Contention Window Minimum)*: Valore minimo della finestra di contesa. Determina il *limite inferiore* del *random backoff*. Valori più bassi significano tempi di attesa minori e quindi maggiore priorità.

/ *CW_max (Contention Window Maximum)*: Valore massimo della finestra di contesa dopo collisioni multiple. Ad ogni collisione, la CW viene raddoppiata fino a raggiungere CW_max. 

/ *AIFSN (Arbitration Inter-Frame Space Number)*: Numero di slot time da attendere dopo SIFS prima di poter accedere al canale. La formula è:
  $ "AIFSN" = "SIFS" + "N" "SlotTime" $
  *Valori* più *alti* di AIFSN significano *priorità più bassa*.

/ *TXOP Limit (Transmission Opportunity)*: Tempo massimo (in microsecondi) per cui una stazione può mantenere il *controllo del canale* dopo averlo ottenuto. Un valore di 0 significa che si può trasmettere un solo frame.

#esempio[
*Traffico Voice (AC_VO)*: 
- CW_min = $3$, CW_max = $7$: finestre molto piccole per accesso rapido
- AIFSN = $2$: attesa minima dopo SIFS
- TXOP = $1.5 "ms"$: può trasmettere più frame voce consecutivi

*Traffico Background (AC_BK)*:
- CW_min = $15$, CW_max = $1023$: finestre grandi, attesa più lunga
- AIFSN = $7$: deve attendere più a lungo prima di tentare l'accesso
- TXOP = $0$: trasmette un solo frame alla volta
]

=== Meccanismo di Contesa Interno ed Esterno

Quando una stazione ha traffico appartenente a diverse Access Categories, EDCA implementa un *doppio meccanismo di contesa*:

#align(center)[
  #figure(
    cetz.canvas(length: 0.7cm, {
      import cetz.draw: *

      let box-style = (stroke: black, radius: 0.2)
      let w = 2.5
      let h = 1
      let gap-y = 0.3

      // Four AC queues
      rect((0, 3.5), (w, 3.5 + h), ..box-style, fill: rgb("#C00000"))
      content((w/2, 3.5 + h/2), text(fill: white, weight: "bold", size: 0.8em)[AC_VO])

      rect((0, 2.5 - gap-y), (w, 2.5 - gap-y + h), ..box-style, fill: rgb("#FFC000"))
      content((w/2, 2.5 - gap-y + h/2), text(fill: white, weight: "bold", size: 0.8em)[AC_VI])

      rect((0, 1.5 - 2*gap-y), (w, 1.5 - 2*gap-y + h), ..box-style, fill: rgb("#70AD47"))
      content((w/2, 1.5 - 2*gap-y + h/2), text(fill: white, weight: "bold", size: 0.8em)[AC_BE])

      rect((0, 0.5 - 3*gap-y), (w, 0.5 - 3*gap-y + h), ..box-style, fill: rgb("#A6A6A6"))
      content((w/2, 0.5 - 3*gap-y + h/2), text(fill: white, weight: "bold", size: 0.8em)[AC_BK])

      // Internal contention
      let x-int = w + 1.5
      rect((x-int, 1.5), (x-int + 2, 2.5), ..box-style, fill: rgb("#D9E2F3"))
      content((x-int + 1, 2), text(weight: "bold", size: 0.8em)[Contesa\ Interna])

      // Arrows to internal contention
      for i in range(4) {
        let y-from = 3.5 - i * (1 + gap-y) + h/2
        line((w, y-from), (x-int, 2), mark: (end: ">"), stroke: (thickness: 1pt))
      }

      // Winner to external contention
      let x-ext = x-int + 3.5
      rect((x-ext, 1.5), (x-ext + 2, 2.5), ..box-style, fill: rgb("#E7E6E6"))
      content((x-ext + 1, 2), text(weight: "bold", size: 0.8em)[Contesa\ Esterna])

      line((x-int + 2, 2), (x-ext, 2), mark: (end: ">"), stroke: (thickness: 1.5pt))
      content((x-int + 2.70, 2.7), text(size: 0.7em)[Vincitore])

      // To channel
      let x-ch = x-ext + 3
      rect((x-ch, 1.5), (x-ch + 2, 2.5), ..box-style, fill: rgb("#4472C4"))
      content((x-ch + 1, 2), text(fill: white, weight: "bold", size: 0.8em)[Canale\ Fisico])

      line((x-ext + 2, 2), (x-ch, 2), mark: (end: ">"), stroke: (thickness: 1.5pt))

      // Labels
      content((x-int + 1, 0.5), text(size: 0.7em)[AIFSN e CW\ per AC])
      content((x-ext + 1, 0.5), text(size: 0.7em)[CSMA/CA\ Standard])
    }),
    caption: [Meccanismo di contesa in EDCA]
  )
]

1. *Contesa Interna* (Contesa intra-stazione): All'interno della stazione, le diverse AC competono tra loro utilizzando i rispettivi parametri _EDCA_ (AIFSN, CW_min, CW_max). La *AC con priorità più alta* (_AIFSN_ più basso) vince tipicamente la contesa interna.

2. *Contesa Esterna* (Contesa tra stazioni): La AC vincente della contesa interna compete poi con le trasmissioni di altre stazioni sul *canale fisico* utilizzando CSMA/CA standard.

#nota[
  In caso di collisione interna (due AC pronte simultaneamente), vince sempre la AC (acces category) con priorità più alta. La AC con priorità più bassa deve comportarsi come se avesse subito una collisione esterna (raddoppia la *CW*).
]

La combinazione intelligente dei parametri EDCA permette una *differenziazione efficace* del traffico, garantendo certi livelli di QoS:

#align(center)[
  #figure(
    cetz.canvas(length: 0.6cm, {
      import cetz.draw: *

      let time-scale = 0.8
      let y-base = 0
      
      // Timeline
      line((0, y-base), (20, y-base), mark: (end: ">"), stroke: (thickness: 1.5pt))
      content((20.5, y-base), anchor: "west", text(weight: "bold")[Tempo])

      // SIFS
      rect((0, y-base), (1*time-scale, y-base + 0.6), fill: rgb("#E74C3C"), stroke: black)
      content((0.5*time-scale, y-base + 0.3), text(fill: white, size: 0.7em, weight: "bold")[SIFS])

      // AIFS for different ACs
      let aifs-vo = 2
      let aifs-vi = 2
      let aifs-be = 3
      let aifs-bk = 7

      // AC_VO
      rect((1*time-scale, y-base + 2.5), (1*time-scale + aifs-vo*time-scale, y-base + 2.5 + 0.5), fill: rgb("#C00000"), stroke: black)
      content((1*time-scale + aifs-vo*time-scale/2, y-base + 2.75), text(fill: white, size: 0.65em)[AIFS[VO]])
      
      // Backoff VO
      rect((1*time-scale + aifs-vo*time-scale, y-base + 2.5), (1*time-scale + aifs-vo*time-scale + 1.5*time-scale, y-base + 2.5 + 0.5), fill: rgb("#FFB6C1"), stroke: (dash: "dashed"))
      content((1*time-scale + aifs-vo*time-scale + 0.75*time-scale, y-base + 2.75), text(size: 0.6em)[BO])

      // AC_VI
      rect((1*time-scale, y-base + 1.8), (1*time-scale + aifs-vi*time-scale, y-base + 1.8 + 0.5), fill: rgb("#FFC000"), stroke: black)
      content((1*time-scale + aifs-vi*time-scale/2, y-base + 2.05), text(fill: white, size: 0.65em)[AIFS[VI]])
      
      rect((1*time-scale + aifs-vi*time-scale, y-base + 1.8), (1*time-scale + aifs-vi*time-scale + 2.5*time-scale, y-base + 1.8 + 0.5), fill: rgb("#FFE6B3"), stroke: (dash: "dashed"))
      content((1*time-scale + aifs-vi*time-scale + 1.25*time-scale, y-base + 2.05), text(size: 0.6em)[Backoff])

      // AC_BE
      rect((1*time-scale, y-base + 1.1), (1*time-scale + aifs-be*time-scale, y-base + 1.1 + 0.5), fill: rgb("#70AD47"), stroke: black)
      content((1*time-scale + aifs-be*time-scale/2, y-base + 1.35), text(fill: white, size: 0.65em)[AIFS[BE]])
      
      rect((1*time-scale + aifs-be*time-scale, y-base + 1.1), (1*time-scale + aifs-be*time-scale + 4*time-scale, y-base + 1.1 + 0.5), fill: rgb("#D4E6C4"), stroke: (dash: "dashed"))
      content((1*time-scale + aifs-be*time-scale + 2*time-scale, y-base + 1.35), text(size: 0.6em)[Backoff])

      // AC_BK
      rect((1*time-scale, y-base + 0.4), (1*time-scale + aifs-bk*time-scale, y-base + 0.4 + 0.5), fill: rgb("#A6A6A6"), stroke: black)
      content((1*time-scale + aifs-bk*time-scale/2, y-base + 0.65), text(fill: white, size: 0.65em)[AIFS[BK]])
      
      rect((1*time-scale + aifs-bk*time-scale, y-base + 0.4), (1*time-scale + aifs-bk*time-scale + 5*time-scale, y-base + 0.4 + 0.5), fill: rgb("#E6E6E6"), stroke: (dash: "dashed"))
      content((1*time-scale + aifs-bk*time-scale + 2.5*time-scale, y-base + 0.65), text(size: 0.6em)[Backoff])

      // Labels
      content((-1.5, y-base + 2.75), anchor: "east", text(size: 0.7em, weight: "bold")[Voice])
      content((-1.5, y-base + 2.05), anchor: "east", text(size: 0.7em, weight: "bold")[Video])
      content((-1.5, y-base + 1.35), anchor: "east", text(size: 0.7em, weight: "bold")[Best Effort])
      content((-1.5, y-base + 0.65), anchor: "east", text(size: 0.7em, weight: "bold")[Background])
    }),
    caption: [Temporizzazione EDCA: AC con priorità più alta accedono prima al canale]
  )
]

#attenzione[
  Il sistema EDCA garantisce che *non* ci sia *starvation*: anche il traffico _Background_ (AC_BK) prima o poi accederà al canale. Tuttavia, in condizioni di carico elevato, le AC a bassa priorità subiranno ritardi significativi, per garantire QoS ai servizi real-time.
]

=== Configurazione a Livello MAC

I servizi QoS vengono richiesti a *livello MAC* in base alla configurazione dell'applicazione. Il mapping tipico è:

- *VoIP/Telefonia* → AC_VO (massima priorità)
- *Video streaming* → AC_VI (alta priorità)
- *Navigazione web, email* → AC_BE (priorità normale)
- *Download, backup* → AC_BK (priorità minima)

#attenzione[
  La configurazione EDCA deve essere coordinata tra Access Point e stazioni. L'AP comunica i parametri EDCA nei beacon frame. Configurazioni errate o aggressive (es. tutti i client che usano AC_VO) possono degradare le performance  complessive della rete.
]

== Applicazioni Veicolari con 802.11p (Non in esame)

*IEEE 802.11p* è progettato per comunicazioni veicolari *V2V* (Vehicle-to-Vehicle) e *V2I* (Vehicle-to-Infrastructure). Le caratteristiche operative principali sono:

- *Assenza di Access Point*: Le reti sono completamente ad-hoc, i *veicoli comunicano direttamente*
- *Topologia dinamica*: I vicini cambiano continuamente (velocità relativa fino a 200+ km/h)
- *Nessuna associazione*: Eliminato il processo di beacon/associazione per ridurre la latenza
- *Comunicazione asincrona*: *Eventi imprevedibili* richiedono radio sempre in ascolto
- *Messaggi di notifica*: Focus su BSM (Basic Safety Messages) periodici piuttosto che flussi dati continui

#attenzione[
In 802.11p *non* vengono *utilizzati ACK* per i messaggi broadcast (BSM). Questo riduce l'overhead ma richiede ripetizione periodica dei messaggi (tipicamente 10 Hz) per garantire la consegna.
]

=== Gestione Multi-Canale in 802.11p

IEEE 1609.4 definisce la gestione dei canali in ambiente WAVE, alternando tra:

- *CCH (Control Channel)*: Canale 178 (5890 MHz) per messaggi safety-critical
- *SCH (Service Channels)*: Canali 172, 174, 176, 180, 182, 184 per applicazioni non-safety

Ogni stazione implementa *contesa EDCA* sia per il CCH che per gli SCH, con code di priorità interne:

#align(center)[
  #figure(
    cetz.canvas(length: 0.65cm, {
      import cetz.draw: *

      let box-style = (stroke: black, radius: 0.15)
      let w = 2
      let h = 0.8
      
      // Left side - Internal queuing
      content((1, 5.8), text(weight: "bold", size: 0.9em)[Code Interne])
      
      rect((0, 4.5), (w, 4.5 + h), ..box-style, fill: rgb("#C00000"))
      content((w/2, 4.5 + h/2), text(fill: white, size: 0.75em, weight: "bold")[Safety])
      
      rect((0, 3.5), (w, 3.5 + h), ..box-style, fill: rgb("#FFC000"))
      content((w/2, 3.5 + h/2), text(size: 0.75em, weight: "bold")[Event])
      
      rect((0, 2.5), (w, 2.5 + h), ..box-style, fill: rgb("#70AD47"))
      content((w/2, 2.5 + h/2), text(fill: white, size: 0.75em, weight: "bold")[Service])
      
      rect((0, 1.5), (w, 1.5 + h), ..box-style, fill: rgb("#A6A6A6"))
      content((w/2, 1.5 + h/2), text(fill: white, size: 0.75em, weight: "bold")[Background])

      // Internal contention
      let x-cont = 3.5
      rect((x-cont, 3), (x-cont + 1.8, 4.2), ..box-style, fill: rgb("#D9E2F3"))
      content((x-cont + 0.9, 3.6), text(size: 0.75em, weight: "bold")[Contesa\ Interna])

      for i in range(4) {
        let y-from = 4.5 - i + h/2
        line((w, y-from), (x-cont, 3.6), mark: (end: ">"), stroke: (thickness: 0.8pt))
      }

      // Channel selection
      let x-sel = x-cont + 3
      rect((x-sel, 4.5), (x-sel + 1.5, 5 + h), ..box-style, fill: rgb("#E74C3C"))
      content((x-sel + 0.75, 4.7 + h/2), text(fill: white, size: 0.75em, weight: "bold")[CCH\ (178)])
      
      rect((x-sel, 2.5), (x-sel + 1.5, 3.2 + h), ..box-style, fill: rgb("#3498DB"))
      content((x-sel + 0.7, 2.9 + h/2), text(fill: white, size: 0.75em, weight: "bold")[SCH])

      line((x-cont + 1.8, 3.6), (x-sel, 4.9), mark: (end: ">"), stroke: (thickness: 1pt), fill: rgb("#df1212"))
      content((x-cont + 1.8, 4.6), anchor: "south", text(size: 0.65em)[Alta\ priorità])
      
      line((x-cont + 1.8, 3.6), (x-sel, 2.9), mark: (end: ">"), stroke: (thickness: 1pt), fill: rgb("#473ce7"))
      content((x-cont + 2.0, 2.7), anchor: "north", text(size: 0.65em)[Bassa\ priorità])

      // External contention
      let x-ext = x-sel + 2.5
      rect((x-ext, 2), (x-ext + 2.2, 5.2), ..box-style, fill: rgb("#E7E6E6"))
      content((x-ext + 1.1, 3.6), text(size: 0.70em, weight: "bold")[Contesa\ Esterna\ CSMA/CA])

      line((x-sel + 1.5, 4.9), (x-ext, 3.6), mark: (end: ">"), stroke: (thickness: 1pt))
      line((x-sel + 1.5, 2.9), (x-ext, 3.6), mark: (end: ">"), stroke: (thickness: 1pt))

      // Physical channel
      let x-phy = x-ext + 3
      rect((x-phy, 2.5), (x-phy + 1.8, 4.5), ..box-style, fill: rgb("#4472C4"))
      content((x-phy + 0.95, 3.6), text(fill: white, size: 0.75em, weight: "bold")[Canale\ Wireless])

      line((x-ext + 2, 3.6), (x-phy, 3.6), mark: (end: ">"), stroke: (thickness: 1.2pt))
    }),
    caption: [Architettura EDCA multi-canale in 802.11p/WAVE]
  )
]

#nota[
I messaggi safety-critical (BSM) hanno priorità massima e vengono trasmessi sul CCH. I servizi applicativi (infotainment, aggiornamenti mappe) utilizzano gli SCH con priorità inferiore.
]

=== Platooning

L'obbiettivo principlae è favorire il *platooning*. Tecnica di guida cooperativa dove multipli veicoli viaggiano in formazione ravvicinata, coordinando accelerazione e frenata per ridurre il consumo di carburante e migliorare la sicurezza. Obiettivi principali:

/ *Riduzione consumi*: Diminuzione della resistenza aerodinamica per i veicoli seguenti (fino al 15-20% di risparmio)

/ *Aumento capacità stradale*: Distanze inter-veicolari ridotte permettono maggiore densità di traffico

/ *Sicurezza*: Coordinamento automatizzato riduce i rischi di collisione a catena

/ *Comfort*: Guida semi-automatica riduce lo stress del conducente


= AODV - Ad hoc On-Demand Distance Vector Routing

Il protocollo *AODV* (RFC 3561) è un protocollo di routing reattivo progettato per *reti wireless ad-hoc*, dove ogni nodo può agire come router senza infrastruttura centralizzata. 
Principali caratteristiche:
/ *Reti ad-hoc*: Ogni nodo può instradare pacchetti per altri nodi (non sono presenti router dedicati o Access Point), creando una *topologia mesh* dinamica. I nodi vicini sono quelli situati entro raggio di trasmissione wireless. Inoltre, i nodi possono essere mobili, causando frequenti *cambiamenti nella topologia di rete*.

/ *On-demand (Reattivo)*: Le rotte vengono create solo quando necessario, riducendo l'overhead in reti con traffico sporadico

/ *Stateless*: Lo stato delle rotte è effimero. Esso viene mantenuto solo finché necessario (con timeout)

/ *Distance Vector*: Ogni nodo mantiene tabelle di routing indicando la direzione (next hop) e la distanza (hop count) verso le destinazioni

== Obiettivi di Progettazione

- *Gestire la dinamicità*: Adattarsi a topologie che cambiano frequentemente
- *Auto-inizializzazione*: Nessuna configurazione manuale, scoperta automatica delle rotte
- *Loop-free*: Prevenire cicli di routing attraverso numeri di sequenza
- *Convergenza rapida*: Creare rotte velocemente quando richiesto
- *Robustezza*: Rilevare e reagire rapidamente a rotture di link

== Architettura e Messaggi di Controllo

AODV definisce tre tipi principali di *messaggi di controllo*, trasmessi come pacchetti *UDP* sulla porta 654:

/ *RREQ (Route Request)*: Trasmesso in *broadcast* (_controllato_, per evitare loop) quando un nodo cerca un percorso verso una destinazione. Ogni nodo intermedio registra il *percorso inverso* per permettere la risposta.

/ *RREP (Route Reply)*: Trasmesso in *unicast* dalla destinazione (o da un nodo intermedio con informazioni _fresche_) verso l'originator, sfruttando il percorso inverso creato dalla RREQ.

/ *RERR (Route Error)*: Trasmesso quando un *link* si *guasta*, invalidando le rotte che lo utilizzano.

#nota[
  I *messaggi di controllo* AODV viaggiano a livello Trasporto come pacchetti *UDP* porta 654.
  
  I pacchetti dati invece seguono il normale stack protocollare dell'applicazione. Entrambi utilizzano come base i pacchetti IP con indirizzi sorgente e destinazione.
]

== Tabella di Routing

Ogni nodo AODV mantiene una *tabella di routing* con le seguenti informazioni per ogni destinazione:

#align(center)[
  #figure(
    table(
      columns: (2.5fr, 4fr),
      align: (left, left),
      [*Campo*], [*Descrizione*],
      [_Destination IP_], [Indirizzo IP della destinazione],
      [_Destination Sequence_ \#], [Numero di sequenza della destinazione (freschezza)],
      [_Valid Dest Seq Flag_], [Indica se il sequence number è valido],
      [_Route Status_], [Valido, Invalido, Sospeso (in riparazione)],
      [_Network Interface_], [Interfaccia di rete da utilizzare],
      [_Hop Count_], [Numero di hop verso la destinazione],
      [_Next Hop_], [Prossimo nodo nel percorso],
      [_Lifetime_], [Tempo di scadenza della entry (timeout)],
      [_Precursor List_], [Lista di vicini che utilizzano questo nodo come next hop per raggiungere la destinazione],
    ),
    caption: [Struttura della entry nella tabella di routing AODV]
  )
]

== Sequence Number

Il *Sequence Number* è il meccanismo fondamentale di AODV per *garantire loop-freedom* e _freschezza_ della entry:

/ *Incremento*: Il sequence number di un nodo viene *incrementato solo dal nodo stesso* in due casi:
  1. Quando inizia una nuova ricerca di percorso (RREQ)
  2. Quando risponde a una RREQ come destinazione (RREP)

  #nota[
    L'incremento del Sequence Number prima di eseguire una RREQ serve per prevenire conflitti con i percorsi inversi, stabiliti dalla RREQ precedente.
  ]

/ *Aggiornamento*: Un nodo può aggiornare il sequence number di una entry nella sua tabella solo se:
  - Riceve *informazioni più fresche* (SN maggiore) per quella destinazione
  - È il *nodo stesso* (aggiorna la propria entry nella sua tabella di routing e offre un nuovo percorso per sé stesso)
  - La entry scade (*timeout*)

#attenzione[
  L'*incremento* avviene trattando il sequence number come un *unsigned integer* a $32 "bit"$, quindi dopo $2^32-1$ ritorna a $0$. 

  Il *confronto* tra sequence number avviene come se fossero *unsigned* (per gestire overflow $2^31$), quindi se:
  $
    "entry_SN" - "altro_SN" > 0 -> "entry_SN è l'informazione più fresca" 
  $
  #esempio[
    - Se $"entry_SN" = 10$ e $"altro_SN" = 5$, allora $"entry_SN"$ è più fresco.

    - Se $"entry_SN" = 2$ e $"altro_SN" = 2^31$, allora si verifica un underflow:  $2 - (2^32-1) = 3 > 0$, quindi anche in questo caso "entry_SN" è più fresco.
  ]
]

Quando si confrontano due rotte per la stessa destinazione, se:
  $ "SN"_1 > "SN"_2 => "Route"_1 "è più fresca" $
  $ "SN"_1 = "SN"_2 => "confronta hop count" ("minore è meglio") $

#nota[
  Il sequence number *cresce monotonicamente* e garantisce che non si formino loop, poiché solo informazioni più fresche (SN maggiore) vengono accettate.
]

== Formato RREQ (Route Request)

Il messaggio RREQ contiene i seguenti campi principali:

#align(center)[
  #figure(
    table(
      columns: (2fr, 1fr, 4fr),
      align: center + horizon,
      [*Campo*], [*Bit*], [*Significato*],
      [_Type_], [8], [Tipo di messaggio (1 = RREQ)],
      [_Flags_], [5], [J, R, G, D, U],
      [_Reserved_], [11], [Riservato],
      [_Hop Count_], [8], [Numero di hop dall'originator],
      [_RREQ ID_], [32], [Identificatore univoco della richiesta],
      [_Destination IP_], [32], [Indirizzo IP della destinazione cercata (broadcast per RREQ)],
      [_Destination Seq_ \#], [32], [Ultimo SN noto della destinazione],
      [_Originator IP_], [32], [Indirizzo IP del nodo origine],
      [_Originator Seq_ \#], [32], [Sequence number del nodo origine],
    ),
    caption: [Formato del messaggio RREQ]
  )
]
*Flag importanti*:
- *G (Gratuitous RREP)*: Se settato, il nodo che risponde con una RREP all'origine, invia anche una *RREP gratuita alla destinazione*, informandola della creazione del percorso inverso verso l'origine (utile per la scoperta bidirezionale)

- *D (Destination Only)*: Solo la destinazione può rispondere, i nodi intermedi non possono inviare RREP anche se conoscono la route

- *U (Unknown Sequence Number)*: L'origine non conosce il SN della destinazione

=== Creazione e Propagazione RREQ

Un nodo crea una RREQ in due casi:
- *Destinazione sconosciuta*: Non ha una route valida verso la destinazione 
- Destinazione conosciuta, ma *rotta scaduta* (lifetime = 0)
- La *rotta* è stata marcata come *invalida* (RERR ricevuto)

Gli step per creare una RREQ sono:
1. L'originator incrementa il proprio SN: $"Originator_SN"++$ e il numero della RREQ: $"RREQ_ID"++$

2. Se la destinazione è sconosciuta, imposta flag $U = 1$

3. Viene memorizzata la coppia $("Originator_IP", "RREQ_ID")$ per *rilevare duplicati*. L'informazione viene mantenuta per un tempo detto *"PATH_DISCOVERY_TIME"*

4. Imposta il TTL in base alla strategia di ricerca

I *parametri di rete* (impostati dal protocolo) sono:
- *PATH_DISCOVERY_TIME* $= 2 * "NET_TRAVERSAL_TIME"$: Tempo per cui la coppia $("Originator_IP", "RREQ_ID")$ è considerata valida (es. 3000 ms)

- *NET_TRAVERSAL_TIME* $=2*"NODE_TRAVERSAL_TIME" * "DIAMETER"$: Tempo massimo per la RREQ di attraversare la rete. Al massimo è $2$ volte il diametro della rete (andata e ritorno)

- *NODE_TRAVERSAL_TIME*: Tempo stimato per attraversare un nodo

=== Expanding Ring Search

Per ridurre l'overhead (evitare di diffondere RREQ in tutta la rete), _AODV_ utilizza la tecnica *Expanding Ring Search*.

I Vantaggi offerti sono:
  - *Riduce overhead* se la destinazione è vicina (caso comune)
  - *Evita flooding* completo se non necessario

#informalmente[
  L'originator inizia con un TTL basso (es. 2) per cercare la destinazione nei nodi vicini. Se non riceve risposta entro un *timeout*, incrementa il TTL e ritrasmette la RREQ, *espandendo progressivamente l'area di ricerca* fino a raggiungere un TTL massimo.
]


#align(center)[
  #figure(
    cetz.canvas(length: 0.7cm, {
      import cetz.draw: *

      let center = (5, 3)
      
      // Origin node
      circle(center, radius: 0.3, fill: rgb("#C00000"), stroke: black)
      content(center, text(fill: white, weight: "bold", size: 0.8em)[S])

      // Expanding circles
      for (r, label, col) in ((1.5, $"TTL"_"start"$, rgb("#4472C4")), (3, $"TTL"_"start" + "TTL"_"inc"$, rgb("#70AD47")), (4.5, $"TTL"_"diameter"$, rgb("#FFC000"))) {
        circle(center, radius: r, stroke: (paint: col, thickness: 1.5pt, dash: "dashed"), fill: none)
        content((center.at(0), center.at(1) + r + 0.4), text(size: 0.7em, fill: col)[#label])
      }

      // Timer indicators
      line((6, 5), (10, 5), mark: (end: ">"), stroke: (thickness: 1pt))
      content((9, 5.4), text(size: 0.7em)[Tempo])
      
    }),
    caption: [Expanding Ring Search: ricerca progressiva con TTL crescente]
  )
]

*Parametri*:
- $"TTL"_"start"$: TTL iniziale basso (es. 2), assumendo destinazione vicina
- $"TTL"_"increment"$: Incremento ad ogni fallimento (dopo timeout)
- $"TTL"_"net_diameter"$: *TTL massimo*, diametro massimo della rete

#nota[  
  Esiste un *caso speciale* per cui la ricerca parte con un TTL più alto: Se esiste una entry invalida per la destinazione (o un percorso interrotto) con *hop count noto* (es. 10), la ricerca parte con $"TTL_noto"$ invece di $"TTL"_"start"$.
]

L'originator continua ad espandere il TTL fino a ricevere una RREP o raggiungere il TTL massimo. Ogni tentativo fallito viene memorizzato e ogni volta si incrementano $"RREQ_ID"$ e $"Originator_SN"$ per garantire unicità. Il numero di tentativi è limitato dal parametro *"RREQ_RETRIES"*, dopo il quale si considera la destinazione irraggiungibile.


=== Gestione Ricezione RREQ

Quando un nodo riceve una RREQ, verifica se ha già visto la coppia $<"Originator_IP", "RREQ_ID">$:

*Se già vista* (duplicato):
1. Scarta la RREQ (non inoltra)
2. Confronta $"Originator_SN"$ nella RREQ con quello in tabella:
   $ "SN"_"RREQ" > "SN"_"table" => "Aggiorna tabella" $
3. Aggiorna/crea il *percorso inverso* verso l'originator:
   - Next Hop = nodo da cui è arrivata la RREQ
   - Hop Count = Hop Count della RREQ + 1
   - Destination SN = Originator SN dalla RREQ

*Se non ancora vista*:
1. Memorizza $("Originator_IP", "RREQ_ID")$
2. Crea/aggiorna percorso inverso verso originator (come sopra)
3. Incrementa $"Hop_Count"++$
4. Aggiorna $"Destination_SN"$ nella RREQ se ne possiede uno più recente
5. Decrementa TTL: $"TTL"--$
6. Se $"TTL" > 0$: ritrasmette RREQ in broadcast

Mentre la RREQ si propaga, ogni nodo intermedio costruisce il *percorso inverso* verso l'originator. Questo percorso sarà utilizzato dalla RREP per tornare indietro in unicast.

#nota[
  Se il flag $"destination_only" == 0$, allora un *nodo intermedio può rispondere* con una RREP se ha una route valida e fresca verso la destinazione, evitando di propagare ulteriormente la RREQ.

  Formalmente le condizioni di risposta sono:
  - $"SN_destination_tabella" >= "SN_destination_RREQ"$
  - Route Status = Valida
]

#align(center)[
  #image("/assets/RREQ.png", width: 75%)
]

== Formato RREP (Route Reply)

Il messaggio RREP contiene i seguenti campi:

#align(center)[
  #figure(
    table(
      columns: (2fr, 1fr, 4fr),
      align: center + horizon,
      [*Campo*], [*Bit*], [*Significato*],
      [_Type_], [8], [Tipo di messaggio (2 = RREP)],
      [_Flags_], [5], [R, A (Repair, Acknowledgment Required)],
      [_Reserved_], [9], [Riservato],
      [_Prefix Size_], [5], [Lunghezza prefisso di rete (per subnet routing)],
      [_Hop Count_], [8], [Numero di hop dalla destinazione (incrementato ad ogni inoltro)],
      [_Destination IP_], [32], [Indirizzo IP della destinazione originale della RREQ],
      [_Destination Seq_ \#], [32], [Sequence number della destinazione],
      [_Originator IP_], [32], [Indirizzo IP del nodo che ha iniziato la RREQ],
      [_Lifetime_], [32], [Tempo di validità della route (millisecondi)],
    ),
    caption: [Formato del messaggio RREP]
  )
]

*Differenze chiave rispetto a RREQ*:
- Non contiene RREQ ID (non necessario per la risposta essendo unicast)
- Include *Lifetime*: indica per quanto tempo la route è valida
- Hop Count parte da 0 e viene incrementato ad ogni nodo intermedio
- Flag A: se settato, richiede ACK per confermare la ricezione della RREP

La RREP viene trasmessa in *unicast lungo il percorso inverso* creato dalla RREQ.

=== Generazione RREP (Route Reply)

Una RREP viene generata quando:
1. La RREQ raggiunge la destinazione finale
2. Un nodo intermedio ha una route valida e sufficientemente fresca verso la destinazione (se flag $D=0$). *Condizione di freschezza* per risposta intermedia:
$ "Destination_SN"_"table" >= "Destination_SN"_"RREQ" $

#align(center)[
  #figure(
    cetz.canvas(length: 0.6cm, {
      import cetz.draw: *

      // Nodes
      let nodes = (
        ("A", (2, 3)),
        ("B", (5, 4)),
        ("D", (5, 2)),
        ("C", (8, 3)),
        ("H", (11, 3)),
      )

      for (name, pos) in nodes {
        let col = if name == "A" { rgb("#C00000") } else if name == "H" { rgb("#70AD47") } else { rgb("#4472C4") }
        circle(pos, radius: 0.4, fill: col, stroke: black)
        content(pos, text(fill: white, weight: "bold")[#name])
      }

      // RREQ forward (dashed blue)
      line((2, 3), (5, 4), mark: (end: ">"), stroke: (paint: blue, thickness: 1pt, dash: "dashed"))
      line((5, 4), (8, 3), mark: (end: ">"), stroke: (paint: blue, thickness: 1pt, dash: "dashed"))
      line((5, 2), (8, 3), mark: (end: ">"), stroke: (paint: blue, thickness: 1pt, dash: "dashed"))
      line((8, 3), (11, 3), mark: (end: ">"), stroke: (paint: blue, thickness: 1pt, dash: "dashed"))
      
      content((3.5, 3.7), anchor: "south", text(size: 0.6em, fill: blue)[RREQ])
      content((6.5, 3.6), anchor: "south", text(size: 0.6em, fill: blue)[RREQ])

      // RREP backward (solid green)
      line((11, 3), (8, 3), mark: (end: ">"), stroke: (paint: rgb("#70AD47"), thickness: 1.5pt))
      line((8, 3), (5, 4), mark: (end: ">"), stroke: (paint: rgb("#70AD47"), thickness: 1.5pt))
      line((5, 4), (2, 3), mark: (end: ">"), stroke: (paint: rgb("#70AD47"), thickness: 1.5pt))

      content((9.5, 3.3), anchor: "north", text(size: 0.65em, fill: rgb("#70AD47"), weight: "bold")[RREP])
      content((6.5, 3.3), anchor: "north", text(size: 0.65em, fill: rgb("#70AD47"), weight: "bold")[RREP])
      content((3.5, 3.3), anchor: "north", text(size: 0.65em, fill: rgb("#70AD47"), weight: "bold")[RREP])

      // Legend
      content((6.5, 0.5), text(size: 0.7em)[Percorso selezionato: A → B → C → H])
    }),
    caption: [RREP torna in unicast lungo il percorso inverso creato dalla RREQ]
  )
]

\ *Rep generata dalla destinazione*: I passi che vengono eseguit dalla destinazione quando riceve una RREQ sono:
1. Incrementa il proprio SN: $"Destination_SN"++$
2. Crea una RREP con:
    - _Destination IP_ = se stessa
    - _Destination SN_ = il nuovo SN incrementato
    - _Originator IP_ = IP dell'originator dalla RREQ
    - _Lifetime_ = Parametro $"MY-ROUTE-TIMEOUT"$
    - _Hop Count_ = 0
3. Invia la RREP in unicast lungo il percorso inverso verso l'originator

\ *Rep generata da nodo intermedio*: Un nodo può generare in risposta una RREP se e solo se valgono le seguenti condizioni (in and):
1. Il nodo ha una rotta valida verso la destinazione (entry valida nella tabella di routing)
2. Il flag $"destination_only" == 0$ nella RREQ
3. $"DST SN"_"ENTRY" >= "DST SN"_"RREQ"$

Se le condizioni sono soddisfatte, il nodo intermedio crea una RREP con:
- _Destination IP_ = IP della destinazione dalla RREQ
- _Destination SN_ = SN della destinazione dalla tabella di routing
- _Originator IP_ = IP dell'originator dalla RREQ
- _Lifetime_ = In base al valore presente nella entry
- _Hop Count_ = Valore presente nella entry

Successivamente invia la RREP in unicast lungo il percorso inverso verso l'originator, senza propagare ulteriormente la RREQ.

#nota[
  Se il flag *$"gratuitous_rrep" == 1$*, il nodo intermedio, invia anche una RREP gratuita alla destinazione, informandola della creazione del percorso inverso verso l'origine. 
  
  Utile per la *scoperta bidirezionale*.
]

Ogni nodo intermedio che inoltra la RREP:
- Crea/aggiorna la route forward verso la destinazione
- Incrementa Hop Count nella RREP
- Imposta il lifetime della route

=== Esempio: RREP Intermedio vs RREP dalla Destinazione

#esempio[
*Scenario*: Il nodo $A$ ha inviato una RREQ per trovare $H$ con i seguenti parametri:
- _DEST_: $H$
- _DST_SN_: $140$
- _Orig_: $A$  
- _Orig SN_: $200$
- _Hop_: $0$

*Topologia della rete:*
#align(center)[
  #figure(
    cetz.canvas(length: 0.9cm, {
      import cetz.draw: *

      // Nodes positioning
      let nodes = (
        ("A", (0, 3), rgb("#70AD47")),
        ("B", (3, 5), rgb("#4472C4")),
        ("C", (3, 1), rgb("#4472C4")),
        ("D", (6, 5), rgb("#4472C4")),
        ("E", (7.5, 6.5), rgb("#D9D9D9")),
        ("F", (6, 1), rgb("#C00000")),
        ("G", (9, 1), rgb("#4472C4")),
        ("H", (12, 3), rgb("#FFC000")),
      )

      for (name, pos, col) in nodes {
        circle(pos, radius: 0.5, fill: col, stroke: black + 1.5pt)
        content(pos, text(fill: white, weight: "bold", size: 1.1em)[#name])
      }

      // Wireless links (dashed gray)
      let links = (
        ((0, 3), (3, 5)),    // A-B
        ((0, 3), (3, 1)),    // A-C
        ((3, 5), (6, 5)),    // B-D
        ((3, 1), (6, 1)),    // C-F
        ((6, 5), (7.5, 6.5)), // D-E
        ((6, 5), (12, 3)),   // D-H
        ((6, 1), (9, 1)),    // F-G
        ((9, 1), (12, 3)),   // G-H
      )

      for (start, end) in links {
        line(start, end, stroke: (paint: gray, thickness: 0.8pt, dash: "dashed"))
      }
      
      // Legend
      content((6, -0.5), anchor: "north", text(size: 0.85em)[#text(fill: rgb("#70AD47"), weight: "bold")[A:] Origine | #text(fill: rgb("#FFC000"), weight: "bold")[H:] Destinazione | #text(fill: rgb("#C00000"), weight: "bold")[F:] Nodo con cache])
    }),
    caption: [Topologia della rete]
  )
]

\ *Fase Iniziale*: I nodi $B$ e $C$ hanno ricevuto la RREQ da A. Entrambi inoltrano la richiesta ai propri vicini:
- *$B -> C$*
- *$C -> F$* 

#align(center)[
  #figure(
    cetz.canvas(length: 0.9cm, {
      import cetz.draw: *

      // Nodes
      let nodes = (
        ("A", (0, 3), rgb("#D9D9D9")),
        ("B", (3, 5), rgb("#4472C4")),
        ("C", (3, 1), rgb("#4472C4")),
        ("D", (6, 5), rgb("#4472C4")),
        ("E", (7.5, 6.5), rgb("#D9D9D9")),
        ("F", (6, 1), rgb("#C00000")),
        ("G", (9, 1), rgb("#D9D9D9")),
        ("H", (12, 3), rgb("#FFC000")),
      )

      for (name, pos, col) in nodes {
        circle(pos, radius: 0.5, fill: col, stroke: black + 1.5pt)
        content(pos, text(fill: white, weight: "bold", size: 1.1em)[#name])
      }

      // Links
      let links = (
        ((0, 3), (3, 5)), ((0, 3), (3, 1)), ((3, 5), (6, 5)), ((3, 1), (6, 1)),
        ((6, 5), (7.5, 6.5)), ((6, 5), (12, 3)), ((6, 1), (9, 1)), ((9, 1), (12, 3)),
      )
      for (start, end) in links {
        line(start, end, stroke: (paint: gray, thickness: 0.8pt, dash: "dashed"))
      }

      // RREQ propagation from B to D
      line((3, 5), (6, 5), mark: (end: ">"), stroke: (paint: blue, thickness: 1.3pt, dash: "dashed"))
      content((4.5, 5.5), text(size: 0.8em, fill: blue, weight: "bold")[RREQ])
      
      // RREQ propagation from C to F
      line((3, 1), (6, 1), mark: (end: ">"), stroke: (paint: blue, thickness: 1.3pt, dash: "dashed"))
      content((4.5, 0.5), text(size: 0.8em, fill: blue, weight: "bold")[RREQ])
      
      // RREQ info box
      content((10, 6), anchor: "west", text(size: 0.75em)[
        *RREQ ricevuta da D e F:*\
        DEST: H | DST_SN: 140\
        Orig: A | Orig_SN: 200\
        \#Hop: 1
      ])
    }),
    caption: [B inoltra la RREQ verso D, C inoltra la RREQ verso F]
  )
]

\ * $F$ risponde*: Avvengono due azioni in parallelo:
- *$D$ inoltra la RREQ verso $H$:*
  - $D$ non ha una rotta valida verso $H$
  - Incrementa l'Hop Count: $1 -> 2$
  - Inoltra la RREQ verso i suoi vicini ($E$ e $H$)

- *F risponde con RREP:*
  #align(center)[
    #table(
      columns: (auto, auto, auto, auto),
      align: center + horizon,
      [*Dest*], [*Next Hop*], [*Hop Count*], [*DST SN*],
      [H], [G], [2], [149],
    )
  ] 
  - $F$ ha una entry valida nella sua tabella con $"DST_SN" = 149$ ($> 140$ RREQ)
  - $F$ genera una RREP con:
    - _Destination IP_: $H$
    - _Destination SN_: $149$
    - _Hop Count_: $2$ (dalla sua entry verso $H: F -> G -> H$)

#align(center)[
  #figure(
    cetz.canvas(length: 0.9cm, {
      import cetz.draw: *

      // Nodes
      let nodes = (
        ("A", (0, 3), rgb("#D9D9D9")),
        ("B", (3, 5), rgb("#D9D9D9")),
        ("C", (3, 1), rgb("#4472C4")),
        ("D", (6, 5), rgb("#4472C4")),
        ("E", (7.5, 6.5), rgb("#D9D9D9")),
        ("F", (6, 1), rgb("#C00000")),
        ("G", (9, 1), rgb("#D9D9D9")),
        ("H", (12, 3), rgb("#FFC000")),
      )

      for (name, pos, col) in nodes {
        circle(pos, radius: 0.5, fill: col, stroke: black + 1.5pt)
        content(pos, text(fill: white, weight: "bold", size: 1.1em)[#name])
      }

      // Links
      let links = (
        ((0, 3), (3, 5)), ((0, 3), (3, 1)), ((3, 5), (6, 5)), ((3, 1), (6, 1)),
        ((6, 5), (7.5, 6.5)), ((6, 5), (12, 3)), ((6, 1), (9, 1)), ((9, 1), (12, 3)),
      )
      for (start, end) in links {
        line(start, end, stroke: (paint: gray, thickness: 0.8pt, dash: "dashed"))
      }

      // RREQ D to H (blue dashed)
      line((6, 5), (12, 3), mark: (end: ">"), stroke: (paint: blue, thickness: 1.3pt, dash: "dashed"))
      content((9, 4.5), text(size: 0.8em, fill: blue, weight: "bold")[RREQ])
      // RREP from F to C (red solid)
      line((6, 1), (3, 1), mark: (end: ">"), stroke: (paint: red, thickness: 1.5pt))
      content((4.5, 1.5), text(size: 0.8em, fill: red, weight: "bold")[RREP])
      content((4.5, 0.3), text(size: 0.7em, fill: red)[DST_SN: 149, Hop: 2])
    }),
    caption: [D inoltra RREQ a H; F risponde con RREP verso C]
  )
]


\ *Ricezione RREP da $F$*: La RREP generata da $F$ arriva ad $A$ passando per $C$. $A$ aggiorna la sua tabella di routing.

#align(center)[
  #figure(
    cetz.canvas(length: 0.9cm, {
      import cetz.draw: *

      // Nodes
      let nodes = (
        ("A", (0, 3), rgb("#70AD47")),
        ("B", (3, 5), rgb("#D9D9D9")),
        ("C", (3, 1), rgb("#4472C4")),
        ("D", (6, 5), rgb("#D9D9D9")),
        ("E", (7.5, 6.5), rgb("#D9D9D9")),
        ("F", (6, 1), rgb("#C00000")),
        ("G", (9, 1), rgb("#D9D9D9")),
        ("H", (12, 3), rgb("#FFC000")),
      )

      for (name, pos, col) in nodes {
        circle(pos, radius: 0.5, fill: col, stroke: black + 1.5pt)
        content(pos, text(fill: white, weight: "bold", size: 1.1em)[#name])
      }

      // Links
      let links = (
        ((0, 3), (3, 5)), ((0, 3), (3, 1)), ((3, 5), (6, 5)), ((3, 1), (6, 1)),
        ((6, 5), (7.5, 6.5)), ((6, 5), (12, 3)), ((6, 1), (9, 1)), ((9, 1), (12, 3)),
      )
      for (start, end) in links {
        line(start, end, stroke: (paint: gray, thickness: 0.8pt, dash: "dashed"))
      }

      // Path F -> C -> A (red)
      line((6, 1), (3, 1), mark: (end: ">"), stroke: (paint: red, thickness: 1.5pt))
      line((3, 1), (0, 3), mark: (end: ">"), stroke: (paint: red, thickness: 1.5pt))
      
      content((4.5, 1.5), text(size: 0.8em, fill: red, weight: "bold")[RREP])
      content((1.5, 1.8), text(size: 0.8em, fill: red, weight: "bold")[RREP])
    }),
    caption: [RREP da F arriva ad A attraverso C]
  )
]

*Tabella routing di A dopo aver ricevuto RREP da F:*
#align(center)[
  #table(
    columns: (auto, auto, auto, auto),
    align: center + horizon,
    [*Dest*], [*Next Hop*], [*Hop Count*], [*DST SN*],
    [H], [C], [3], [149],
  )
]

A registra il percorso: $mono("A -> C -> F -> G -> H")$ con 3 hop e DST_SN = 149.

#nota[
  *Mancanza di bidirezionalità*: In questo momento, $A$ ha un percorso verso $H$ (passando per $C-F-G$), ma questo percorso *non è bidirezionale*. $H$ non ha ancora ricevuto informazioni su questa rotta e non può usarla per comunicare con $A$. Questo perché:
  - La RREP di $F$ è stata generata dalla cache di $F$, non da $H$
  - $H$ non ha ricevuto alcuna informazione su questo percorso
  - La comunicazione in questa fase è *unidirezionale*: $A$ può raggiungere $H$, ma $H$ non può ancora rispondere usando la stessa rotta.
]

\ *RREQ Raggiunge $H$, generazione RREP*

La RREQ inoltrata da $D$ raggiunge la destinazione $H$. Il nodo $H$ possiede già in cache un percorso verso $A$:
#align(center)[
  #table(
    columns: (auto, auto, auto, auto),
    align: center + horizon,
    [*Dest*], [*Next Hop*], [*Hop Count*], [*Orig SN*],
    [A], [D], [3], [200],
  )
]
Di conseguenza il nodo $H$ esegue i seguenti passi per generare la RREP:
1. *Incrementa il proprio Sequence Number*: $149 -> 150$
2. *Genera una RREP* con:
  - _Originator IP_: $A$ 
  - _Destination IP_: $H$ (se stesso)
  - _Destination SN_: $150$ (nuovo SN incrementato)
  - _Hop Count_: $0$
3. *Invia la RREP in unicast* utilizzando il *percorso in cache* verso A: $H -> D ->  B -> A$. $H$ può inviare la RREP direttamente usando il percorso che già conosce verso $A$ (_Next Hop_: D, con _Orig_SN_ = 200 dalla RREQ ricevuta)

#align(center)[
  #figure(
    cetz.canvas(length: 0.9cm, {
      import cetz.draw: *

      // Nodes
      let nodes = (
        ("A", (0, 3), rgb("#70AD47")),
        ("B", (3, 5), rgb("#4472C4")),
        ("C", (3, 1), rgb("#D9D9D9")),
        ("D", (6, 5), rgb("#4472C4")),
        ("E", (7.5, 6.5), rgb("#D9D9D9")),
        ("F", (6, 1), rgb("#D9D9D9")),
        ("G", (9, 1), rgb("#D9D9D9")),
        ("H", (12, 3), rgb("#FFC000")),
      )

      for (name, pos, col) in nodes {
        circle(pos, radius: 0.5, fill: col, stroke: black + 1.5pt)
        content(pos, text(fill: white, weight: "bold", size: 1.1em)[#name])
      }

      // Links
      let links = (
        ((0, 3), (3, 5)), ((0, 3), (3, 1)), ((3, 5), (6, 5)), ((3, 1), (6, 1)),
        ((6, 5), (7.5, 6.5)), ((6, 5), (12, 3)), ((6, 1), (9, 1)), ((9, 1), (12, 3)),
      )
      for (start, end) in links {
        line(start, end, stroke: (paint: gray, thickness: 0.8pt, dash: "dashed"))
      }

      // Path H -> D -> B -> A (green)
      line((12, 3), (6, 5), mark: (end: ">"), stroke: (paint: rgb("#70AD47"), thickness: 1.5pt))
      line((6, 5), (3, 5), mark: (end: ">"), stroke: (paint: rgb("#70AD47"), thickness: 1.5pt))
      line((3, 5), (0, 3), mark: (end: ">"), stroke: (paint: rgb("#70AD47"), thickness: 1.5pt))
      
      content((9, 4.5), text(size: 0.8em, fill: rgb("#70AD47"), weight: "bold")[RREP])
      content((4.5, 5.5), text(size: 0.8em, fill: rgb("#70AD47"), weight: "bold")[RREP])
      content((1.5, 4.2), text(size: 0.8em, fill: rgb("#70AD47"), weight: "bold")[RREP])
      content((11, 4.45), text(size: 0.7em, fill: rgb("#70AD47"))[DST_SN: 150, Hop: 0])
    }),
    caption: [RREP da H arriva ad A attraverso D e B]
  )
]

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  
  [
    *H incrementa il proprio SN:*
    #align(center)[
      #table(
        columns: (auto, auto),
        align: center + horizon,
        [*Campo*], [*Valore*],
        [SN precedente], [149],
        [*SN nuovo*], [*150*],
      )
    ]
  ],
  
  [
    *Tabella routing di D (dopo RREP):*
    #align(center)[
      #table(
        columns: (auto, auto, auto, auto),
        align: center + horizon,
        [*Dest*], [*Next Hop*], [*Hop*], [*DST SN*],
        [H], [H], [1], [150],
      )
    ]
  ]
)

\ *Aggiornamento con la Rotta Migliore*: La RREP da $H$ arriva ad $A$. Il nodo $A$ confronta questa nuova informazione con quella già in memoria.

*A confronta le due RREP ricevute:*

#align(center)[
  #table(
    columns: (auto, auto, auto, auto, auto),
    align: center + horizon,
    [*Fonte*], [*Next Hop*], [*Hop Count*], [*DST SN*], [*Decisione*],
    [F (vecchia)], [C], [4], [149], [❌ Scartata],
    [H (nuova)], [B], [3], [150], [✓ Accettata],
  )
]
In questo modo, il nodo $A$ salva definitivamente il percorso: $mono("A -> B -> D -> H")$ con $3$ hop e $"DST_SN" = 150$.
]

== Flag Gratuito

Risolve il problema della *potenziale assimetria* (a differenza dell'esempio precedente).

Se un nodo intermedio riceve una RREQ con flag $G==1$ e soddisfa le condizioni per rispondere, oltre a generare una RREP verso l'origine, invia anche una *RREP gratuita verso la destinazione*. Questa RREP gratuita informa la destinazione dell'esistenza di un percorso verso l'origine, permettendo così alla destinazione di aggiornare la propria tabella di routing e costruire un percorso bidirezionale.

#informalmente[
  Viene *simulata* la risposta di un nodo intermedio alla destinazione, come se la destinazione avesse inviato una RREQ verso l'origine e il nodo intermedio stesse rispondendo a quella richiesta.
]

La RREP gratuita verso la destinazione (della RREQ originale) contiene:
- _Hop Count_: numero di hop verso la destinazione (valore preso dalla entry)
- _Destination IP_: IP dell'originator (come se fosse la destinazione che chiede di trovare una rotta verso l'origine) 
- _Destination SN_: SN nella entry verso l'origine della RREQ 
- _Originator IP_: IP della destinazione (preso dalla RREQ)
- _Lifetime_: lifetime della rotta verso l'origine (preso dalla entry)

#nota[
  Tramite questo meccanismo, andiamo a risolvere il seguiente problema: Se un nodo intermedio risponde alla richiesta, allora, simao in grado di stabilire un *percorso unidirezionale*:
  $
    "Originator" -> "Nodo Intermedio" -> "Destinazione"
  $
  Tuttavia, *non* possiamo sapere se la destinazione conosce un modo per arrivare alla sorgente, il percorso origine-destinazione potrebbe essere *asimmetrico*.
]



#esempio[
  Sempre usando la stessa topologia dell'esempio precedente e considerando la RREQ inviata da $A$ per raggiungere $H$ con $"DST_SN" = 140$, $G=1$.

  Quando la RREQ raggiunge $F$, siccome esso ha una entry valida verso $H$ con $"DST_SN" = 149$ ($> 140$ RREQ), può rispondere alla RREQ. Inoltre, siccome $G==1$, $F$ genera anche una RREP gratuita verso $H$:

  - *RREP di F*, contiene:
    - DEST = $H$
    - DEST SN = $149$
    - Originator = $A$
    - Hop = $2$

  - *RREP Gratuita*, contiene:
    - DEST = $A$ (è come se il nodo $H$ avesse chiesto di trovare una rotta per il nodo $A$)
    - DEST SN = $200$ (SN di $A$)
    - Originator = $H$
    - Hop count = $2$
]

== Hello Message

Ogni nodo può indicare informazioni sulla propria *connettività* locale ai vicini tramite gli *Hello Message*.

#nota()[
  I messaggi di hello message non sono altro che RREP con un $"TTL (Time To Live)" = 1$, inviati in *broadcast* ai vicini.
]

Tali messaggi servono per costruire la conoscenza della rete a distanza $1$. Hanno il compito di *mantenere conto della connettività locale*, stato dei link del vicinato. 

=== Formato

Un hello message contiene:
- _Destination IP_: IP del nodo stesso
- _Destination SN_: SN del nodo stesso
- _Hop Count_: 0
- _Lifetime_: $"ALLOWED_HELLO_LOSS" * "HELLO_INTERVAL"$ 

Ogni nodo ha quindi il compito di tenere traccia della connettività con i nodi indicati come _next hop_ nelle proprie entry. Esistono due meccanismi per monitorare se un hello message è fallito:
- *Livello Data Link*
- *Livello Rete*

=== Livello Data Link

In mancanza di un Clear to Send o un *ACK* (da parte di un vicino), il link viene considerato _rotto_. 

L'hello message viene mandato unicast a livello 2 o broadcast a livello 3:
 - Se viene mandato *unicast* e l'altro nodo non risponde, allora il link viene considerato guasto (dopo un certo numero di tentativi). 
 
 - Se invece viene mandato in *broadcast*, non è possibile sapere se il vicino ha ricevuto o meno il messaggio, quindi non è possibile monitorare la connettività a livello 2.

=== Livello di Rete

Se un nodo riceve un *qualsiasi pacchetto* da un vicino, allora quel vicino è considerato attivo. Se invece non riceve pacchetti da un vicino per un certo periodo di tempo, allora quel vicino viene considerato inattivo. Posso essere usate due tecniche per monitorare la connettività: 
  - Route Request al next hop (destinazione è il next hop)
  - ICMP Echo Request

== Route Error (RERR)

Se un link viene marcato come interrotto/scaduto (utilizzando livello 2 o livello 3), e se esso fa parte di un *percorso attivo*:
- Vengono invalidati tutti i percorsi che usano quel link. Sicome AODV *non ammette multipath*, è sufficiente invalidare tutte le entry che usano quel link come next hop.

- Vengono identificate le destinazioni per le quali viene usato come next hop il link interrotto

- Viene determinato quali vicini possono essere affetti da questo problema (*lista dei predecessori*). Cioè i vicini che usano quel link come next hop per raggiungere una destinazione.

- Viene inviato ai vicini identificati un messaggio di *Route Error (RERR)*

#nota()[
  I link che sono stati marcati come interrotti *non vengono eliminati*, ma marcati come invalidi per un certo periodo di tempo, in attesa di eventuali riparazioni.
]

=== Formato

Il messaggio *RERR (Route Error)* ha la seguente struttura:

#align(center)[
  #figure(
    table(
      columns: (2fr, 5fr),
      align: (center + horizon, left + horizon),
      [*Campo*], [*Descrizione*],
      [Type], [Valore fisso = 3 (identifica il messaggio come RERR)],
      [Flag N], [Se impostato a 1, indica che il link è rotto ma la destinazione della RERR, non deve cancellare le entry perché è stata eseguita una riparazione dal nodo che invia il messaggio],
      [DestCount], [Numero di destinazioni non raggiungibili elencate nel messaggio (deve valere almeno 1)],
      [Unreachable Dest], [Indirizzo IP della destinazione non raggiungibile],
      [Unreachable SN], [Sequence Number della destinazione non raggiungibile],
      [Additional Unreachable Destinations], [Eventuali coppie (IP, SN) aggiuntive per altre destinazioni non raggiungibili],
    ),
    caption: [Formato del messaggio Route Error (RERR)]
  )
]

Il messaggio di RERR può essere inviato quando: 

*Viene identificato un link interrotto*: quando un nodo deve inoltrare pacchetti dati lungo quel link. Se il transito insiste sul link interrotto, il nodo avvisa i vicini.
#esempio[
  Se nell'immagine di prima si guasta il link da $F$ a $G$, l'entry di $C$ che usa $F,G$ per andare a $H$ viene invalidata e il nodo $C$ viene avvisato con un messaggio di errore per l'entry $<H,F>$.
]

*Informazioni non aggiornate*: se un nodo riceve un pacchetto DATA per una destinazione per cui non possiede una entry. Il nodo ha delle informazioni non aggiornate che utilizzano ancora il link interrotto.

*Route Error da vicini*: se un nodo riceve una RERR da un vicino per una o più destinazioni, le informazioni vengono aggiornate. Si tratta di una *RERR _passiva_*: Il nodo corrente usa come _next hop_ un nodo che a sua volta utilizza il nodo che ha scoperto il link interrotto.

#esempio[
  $C$ riceve un Route Error da $F$. Siccome $C$ usava $F$ per andare a $H$, anche $C$ non raggiunge più $H$. In questo caso $C$ avvisa $A$ che non raggiunge più $H$.
]

Cosa succede quando un nodo riceve un RERR:
 - Marca come invalide le entry che sono indicate nella RERR

 - Ogni entry viene invalidata ma preservata per eventuali riparazioni (per un certo lasso di tempo $"DELETE_PERIOD"$)


- Vengono inoltrare le *RERR* ai predecessori (massimo di 1 hop) che usano il link interrotto come next hop per raggiungere una destinazione. Se un nodo non ha predecessori, non inoltra la RERR.

=== Local Repair

Se un nodo riceve un pacchetto per una destinazione lungo un percorso interrotto e la *destinazione non è troppo lontana* (fissato un numero di hop limitato), si può cercare di riparare la rottura trovando un percorso alternativo. La distanza di riparazione massima è data da: 
$
  "MAX_REPAIR_TTL" = 1/3 * "NET_DIAMETER"
$
#informalmente()[
  La riparazione è limitata a un certo numero di hop, che è al massimo 1/3 del diametro della rete.
]

 #nota()[
    La riparazione viene effettuata solo se il link rotto viene utilizzato in modo attivo (arrivano dei dati su quel link). Si tratta di una *riparazione reattiva* scatenata da un evento: trasmissione dei dati.
 ]

La riparazione viene eseguita tramite una *RREQ* limitata. Viene impostato un TTL in modo da raggiungere la sorgente. Se viene trovato un percorso alternativo:

- Se il numero di hop trovato è accettabile, il percorso viene usato

- Se il percorso trovato è più lungo, viene mandato un messaggio di *RERR* con il flag $ N ("no delete") = 1$. Il percorso trovato può essere accettato o meno, la scelta sta alla sorgente. Se non è soddisfatta può eseguire una nuova RREQ per trovare un percorso migliore.

- Se la procedura di riparazione fallisce, viene inviato un RERR con $N=0$ (per indicare che le entry devono essere eliminate).

=== Reboot

La procedura di reboot viene eseguita quando un nodo si riavvia. *Durante* il *reboot*, il *nodo non è in grado di inoltrare messaggi* o rispondere a richieste. 

Viene aspettato un certo periodo di tempo (definito da $"DELETE_PERIOD"$) prima di considerare il nodo attivo. Durante questo periodo, il nodo non può essere usato come next hop per nessuna destinazione.

Tuttavia, potrebbero esserci ancora delle informazioni vecchie nelle tabelle di routing che indicano quel nodo come next hop per alcune destinazioni. Se il nodo che si sta riavviando riceve dei messaggi, *viene generata una RERR*, poiché il nodo non può operare come nodo attivo durante il $"DELETE_PERIOD"$.


=== Esempio Completo di Route Discovery //TODO modificare con tema esame

#esempio[
*Scenario*: Nodo A cerca una route verso H senza RREP intermedi

#align(center)[
  #figure(
    cetz.canvas(length: 0.55cm, {
      import cetz.draw: *

      // Network topology - posizionamento nodi come nell'immagine
      let nodes = (
        ("A", (0, 3), rgb("#70AD47")),
        ("B", (3, 4.5), rgb("#4472C4")),
        ("C", (3, 1.5), rgb("#4472C4")),
        ("D", (6, 4.5), rgb("#4472C4")),
        ("E", (6, 3), rgb("#E7E6E6")),
        ("F", (6, 1.5), rgb("#4472C4")),
        ("G", (9, 3), rgb("#4472C4")),
        ("H", (12, 3), rgb("#C00000")),
      )

      // Draw nodes
      for (name, pos, col) in nodes {
        circle(pos, radius: 0.4, fill: col, stroke: black)
        content(pos, text(fill: white, weight: "bold", size: 0.9em)[#name])
        
        // Labels con informazioni
        if name == "A" {
          content((pos.at(0), pos.at(1) - 0.9), text(size: 0.6em)[A SN\ 200])
        } else if name == "B" {
          content((pos.at(0), pos.at(1) + 0.9), text(size: 0.55em)[< A, A, 1, 200>])
        } else if name == "D" {
          content((pos.at(0), pos.at(1) + 0.9), text(size: 0.55em)[< A, B, 2, 200>])
        } else if name == "E" {
          // X rossa su E
          line((pos.at(0) - 0.3, pos.at(1) - 0.3), (pos.at(0) + 0.3, pos.at(1) + 0.3), stroke: (paint: red, thickness: 2pt))
          line((pos.at(0) - 0.3, pos.at(1) + 0.3), (pos.at(0) + 0.3, pos.at(1) - 0.3), stroke: (paint: red, thickness: 2pt))
          content((pos.at(0), pos.at(1) - 1.1), text(size: 0.55em)[< A, D, 3, 200>\ SN 199])
        } else if name == "F" {
          content((pos.at(0), pos.at(1) - 1.1), text(size: 0.55em)[< H, G, 2, 139>\  A, C, 2, 200>])
        } else if name == "C" {
          content((pos.at(0), pos.at(1) - 0.9), text(size: 0.55em)[< A, A, 1, 200>])
        } else if name == "G" {
          content((pos.at(0), pos.at(1) + 0.9), text(size: 0.55em)[< A, F, 3, 200>])
        } else if name == "H" {
          content((pos.at(0), pos.at(1) + 0.9), text(size: 0.55em)[< A, D, 3, 200>])
          content((pos.at(0), pos.at(1) - 0.9), text(size: 0.6em)[H SN\ 150])
        }
      }

      // RREQ propagation arrows (dashed blue)
      let rreq-paths = (
        ((0, 3), (3, 4.5)),
        ((0, 3), (3, 1.5)),
        ((3, 4.5), (6, 4.5)),
        ((3, 1.5), (6, 1.5)),
        ((6, 4.5), (9, 3)),
        ((6, 1.5), (9, 3)),
        ((9, 3), (12, 3)),
      )

      for (start, end) in rreq-paths {
        line(start, end, stroke: (paint: blue, thickness: 1.2pt, dash: "dashed"))
      }

      // RREQ labels
      content((1.5, 4.2), text(size: 0.6em, fill: blue)[RREQ])
      content((7.5, 3.7), text(size: 0.6em, fill: red, weight: "bold")[RREQ])
      content((10.5, 3.3), text(size: 0.6em, fill: red, weight: "bold")[RREQ])
    }),
    caption: [Propagazione RREQ da A verso H - Esempio senza RREP intermedio]
  )
]

*Stato iniziale della rete*:
- Nodo A (sorgente): Sequence Number = 200
- Nodo H (destinazione): Sequence Number = 150
- Nodo F conosce: $angle.l H, G, 2, 139 angle.r$ (route verso H via G, vecchia)
- Nodo D conosce: $angle.l A, E, 4, 199 angle.r$ (route verso A via E, vecchia)
- Nodo E ha entry con SN 199 per A (non aggiornata)

*RREQ generata da A*:
#align(center)[
  #table(
    columns: (auto, auto),
    [*Campo*], [*Valore*],
    [Destination IP], [H],
    [Destination SN], [—],
    [Originator IP], [A],
    [Originator SN], [200],
    [Hop Count], [0],
  )
]

*Propagazione step-by-step*:

*Step 1 - A trasmette RREQ*:
- A incrementa il proprio SN → 200
- A non conosce il SN di H → flag U = 1
- RREQ trasmessa in broadcast

*Step 2 - B e C ricevono RREQ*:
- Entrambi non conoscono A → creano nuova entry:
  - B: $angle.l A, A, 1, 200 angle.r$ (A raggiungibile via A in 1 hop)
  - C: $angle.l A, A, 1, 200 angle.r$
- Incrementano Hop Count → 1
- Ritrasmettono RREQ in broadcast

*Step 3 - D riceve RREQ da B*:
- D possedeva: $angle.l A, E, 4, 199 angle.r$ (vecchia route via E)
- RREQ contiene Originator SN = 200 > 199 (più fresca!)
- D aggiorna entry: $angle.l A, B, 2, 200 angle.r$
  - Route più fresca E più corta (2 hop invece che 4)
- Incrementa Hop Count → 2
- Ritrasmette RREQ

*Step 4 - E riceve RREQ*:
- E aveva SN vecchio (199) per A
- RREQ ha SN = 200 > 199 → *E aggiorna la sua entry*
- Anche se E scarta la RREQ (duplicato), aggiorna il percorso inverso

*Step 5 - F riceve RREQ da C*:
- F crea entry per A: $angle.l A, C, 2, 200 angle.r$
- F conosce H (ha $angle.l H, G, 2, 139 angle.r$)
- Ma SN di F per H è 139 < 150 richiesto (non sufficientemente fresco)
- Oppure flag D = 1 (Destination Only) → F *non può rispondere*
- F inoltra RREQ

*Step 6 - G riceve RREQ da D e F*:
- Crea entry: $angle.l A, F, 3, 200 angle.r$ (o via D)
- Inoltra verso H

*Step 7 - H riceve RREQ*:
- H è la destinazione finale
- H crea entry reverse: $angle.l A, D, 3, 200 angle.r$ (o via G)
- *RREQ arrivata alla destinazione che deve rispondere*
- H genera RREP da inviare in unicast ad A

*Osservazioni chiave*:

1. *Nessun RREP intermedio*: Anche se F conosceva H, non può rispondere perché:
   - Il suo SN per H (139) è troppo vecchio
   - Oppure il flag D (Destination Only) impone che solo H risponda

2. *Aggiornamento dinamico*: Il nodo D aggiorna la sua route verso A quando riceve informazioni più fresche (SN 200 > 199), anche se aveva già una route

3. *Percorso inverso costruito*: Mentre la RREQ si propaga, ogni nodo costruisce il percorso inverso verso A, che sarà usato dalla RREP

4. *Multiple RREQ scartate*: Ogni nodo riceve probabilmente multiple copie della stessa RREQ (es. G riceve da D e da F), ma inoltra solo la prima o la migliore

*Percorso finale stabilito*: A ↔ B ↔ D ↔ G ↔ H (oppure A ↔ C ↔ F ↔ G ↔ H)
]
