#import "../template.typ": *


=== E-UTRAN collegamento core network

Oltre ad essere collegate alla rete core tramite l'interfaccia S1, le base station, possono anche comunicare tra di loro tramite l'*interfaccia X2* in modo *peer-to-peer*.

Le comunicazioni tra BS sono *comunicazione logiche* (dipendenti dal deployment della rete). Esse possono essere realizzate in diversi modi:
- Tramite punti radio (canale diretto fisico)
- Sfruttando la Transform Network (rete di backhaul) con tunnel dedicati

Le base station (eNodeB), sono a loro volta organizzate in *tracking areas* (TAs), ovvero aree geografiche che raggruppano più celle. Ogni TA è identificata da un *Tracking Area Code* (TAC).

==== Interfaccia X2

L'interfaccia $"X"2$ permette la comunicazione diretta tra eNodeB, senza passare per la rete core. Tale interfaccia aggiunge una serie di funzionalità:

- *Gestione degli handover*. Il traffico di controllo necessario per l'handover viene gestito tra i due eNodeB, senza coinvolgere larete core.

- *Self-Organized-Network* (SON). Esse servono per migliorare le prestazioni della rete in modo autonomo, ad esempio:
  - *Load balancing*. Se un eNodeB è sovraccarico, può chiedere ai suoi vicini di spostare alcuni dispositivi verso di loro (handover) per bilanciare il carico.
  - *Gestione delle interferenze*. Se un dispositivo sul bordo della cella subisce interferenza da celle vicine, l'eNodeB che lo gestisce può chiedere ai vicini di modificare la frequenza di trasmissione.

- Evitare effetto *ping-pong*. Viene tenuto uno storico dei dispositivi già visti. Se un eNodeB accetta di nuovo un dispositivo già visto in precedenza, in un lasso di tempo troppo breve, non avvia la fase di handover.

== Architettura LTE

In LTE si ha una netta separazione tra *control plane* e *data plane*.

=== Control Plane: Stack Protocollare

Il *control plane* gestisce tutta la parte di segnalazione e di controllo della rete. Lo stack protocollare è organizzato in diversi livelli, ciascuno con funzionalità specifiche.

Il control plane controlla i seguenti moduli: UE, eNode, MME

#figure[
  #align(center)[
    #import "@preview/cetz:0.3.2": canvas, draw
    #canvas(length: 0.8cm, {
      import draw: *

      // Parametri
      let box-width = 3.5
      let box-height = 0.7
      let col-spacing = 1.5
      let ue-x = 0
      let enb-x = ue-x + box-width + col-spacing
      let enb-s1-x = enb-x + box-width + 0.3
      let mme-x = enb-s1-x + box-width + col-spacing

      // Funzione per disegnare un box dello stack
      let stack-box(x, y, width, height, label, color) = {
        rect((x, y), (x + width, y + height), fill: color, stroke: 1pt + black)
        content((x + width / 2, y + height / 2), text(size: 9pt, weight: "bold", label))
      }

      // Titoli colonne
      content((ue-x + box-width / 2 - 0., 8), text(size: 11pt, weight: "bold", "UE"))
      content((enb-x + box-width / 2 + 2, 7.5), text(size: 11pt, weight: "bold", "eNodeB"))
      content((mme-x + box-width / 2, 8), text(size: 11pt, weight: "bold", "MME"))

      // Etichette livelli ISO/OSI a sinistra
      let levels = (
        (7, "L7"),
        (6.3, ""),
        (5.6, "L3"),
        (4.9, ""),
        (4.2, "L2"),
        (3.5, ""),
        (2.8, ""),
        (3.4, "L1"),
      )

      for (y, label) in levels {
        if label != "" {
          content((-0.8, y + 0.35), text(size: 8pt, weight: "bold", label))
        }
      }

      // Colori
      let color-nas = rgb("#9ACD32") // Verde oliva chiaro
      let color-rrc = rgb("#87CEEB") // Azzurro
      let color-s1ap = rgb("#9ACD32") // Verde
      let color-pdcp = rgb("#87CEEB") // Azzurro
      let color-rlc = rgb("#87CEEB") // Azzurro
      let color-mac = rgb("#87CEEB") // Azzurro
      let color-phy = rgb("#9ACD32") // Verde
      let color-sctp = rgb("#FFB6C1") // Rosa chiaro
      let color-ip = rgb("#9ACD32") // Verde
      let color-l2 = rgb("#9ACD32") // Verde
      let color-l1 = rgb("#9ACD32") // Verde

      // Stack UE (colonna sinistra)
      let y-pos = 7
      stack-box(ue-x, y-pos, box-width, box-height, "NAS", color-nas)

      y-pos = y-pos - box-height
      stack-box(ue-x, y-pos, box-width, box-height, "RRC", color-rrc)

      y-pos = y-pos - box-height
      stack-box(ue-x, y-pos, box-width, box-height, "PDCP", color-pdcp)

      y-pos = y-pos - box-height
      stack-box(ue-x, y-pos, box-width, box-height, "RLC", color-rlc)

      y-pos = y-pos - box-height
      stack-box(ue-x, y-pos, box-width, box-height, "MAC", color-mac)

      y-pos = y-pos - box-height
      stack-box(ue-x, y-pos, box-width, box-height, "PHY", color-phy)

      // Stack eNodeB (colonna centrale) - parte radio
      y-pos = 7
      y-pos = y-pos - box-height
      stack-box(enb-x, y-pos, box-width, box-height, "RRC", color-rrc)

      y-pos = y-pos - box-height
      stack-box(enb-x, y-pos, box-width, box-height, "PDCP", color-pdcp)

      y-pos = y-pos - box-height
      stack-box(enb-x, y-pos, box-width, box-height, "RLC", color-rlc)

      y-pos = y-pos - box-height
      stack-box(enb-x, y-pos, box-width, box-height, "MAC", color-mac)

      y-pos = y-pos - box-height
      stack-box(enb-x, y-pos, box-width, box-height, "PHY", color-phy)


      // Stack eNodeB - parte S1
      y-pos = 6.3
      stack-box(enb-s1-x, y-pos, box-width, box-height, "S1-AP", color-s1ap)

      y-pos = y-pos - box-height
      stack-box(enb-s1-x, y-pos, box-width, box-height, "SCTP", color-sctp)

      y-pos = y-pos - box-height
      stack-box(enb-s1-x, y-pos, box-width, box-height, "IP", color-ip)

      y-pos = y-pos - box-height
      stack-box(enb-s1-x, y-pos, box-width, box-height, "L2", color-l2)

      y-pos = y-pos - box-height
      stack-box(enb-s1-x, y-pos, box-width, box-height, "L1", color-l1)

      // Stack MME
      y-pos = 7
      stack-box(mme-x, y-pos, box-width, box-height, "NAS", color-nas)

      y-pos = y-pos - box-height
      stack-box(mme-x, y-pos, box-width, box-height, "S1-AP", color-s1ap)

      y-pos = y-pos - box-height
      stack-box(mme-x, y-pos, box-width, box-height, "SCTP", color-sctp)

      y-pos = y-pos - box-height
      stack-box(mme-x, y-pos, box-width, box-height, "IP", color-ip)

      y-pos = y-pos - box-height
      stack-box(mme-x, y-pos, box-width, box-height, "L2", color-l2)

      y-pos = y-pos - box-height
      stack-box(mme-x, y-pos, box-width, box-height, "L1", color-l1)


      // Etichette livelli a destra
      content((mme-x + box-width + 1.2, 7 + box-height / 2), text(size: 8pt, "L7 con UE"))
      content((mme-x + box-width + 1.2, 6.3 + box-height / 2), text(size: 8pt, "L7 con eNB"))
      content((mme-x + box-width + 0.6, 5.6 + box-height / 2), text(size: 8pt, "L4"))
      content((mme-x + box-width + 0.6, 4.9 + box-height / 2), text(size: 8pt, "L3"))
      content((mme-x + box-width + 0.6, 4.2 + box-height / 2), text(size: 8pt, "L2"))
      content((mme-x + box-width + 0.6, 3.5 + box-height / 2), text(size: 8pt, "L1"))
    })
  ]
]

I numeri a lato dell'immagine indicano i livelli ISO/OSI. L'eNodeB ha due stack protocollari distinti in quanto deve parlare con entrambi i lati (UE e MME).

MME ha invece un'unico stack che gestisce sia la comunicazione con l'UE che quella con l'eNodeB.


=== Livelli del Control Plane

*SCTP (Stream Control Transmission Protocol)*:
- Gestisce il trasporto affidabile delle informazioni di controllo a livello L4
- Trasporta i messaggi S1-AP tra eNodeB e MME
- Invia misurazioni, richieste di risorse e comandi di gestione della mobilità
- Fornisce affidabilità e supporto multi-homing

*S1-AP (S1 Application Protocol)*:
- Protocollo a livello applicativo per l'interfaccia S1-MME
- Gestisce procedure di: attach, detach, handover, paging, context management

*PDCP (Packet Data Convergence Protocol)*:
- Permette la convergenza tra diverse applicazioni di livello superiore
- Mappa i flussi applicativi sui canali radio sottostanti
- Esegue compressione degli header IP (ROHC - Robust Header Compression)
- Gestisce la cifratura e l'integrità dei dati

*RLC (Radio Link Control)*:
- Gestisce il link radio (ma non le risorse fisiche)
- *Correzione degli errori* tramite ARQ (Automatic Repeat Request)
- *Segmentazione e riassemblaggio* dei pacchetti in unità di dimensione appropriata
- *Gestione della ritrasmissione* di segmenti persi o corrotti

*MAC (Medium Access Control)*:
- Gestisce l'accesso al canale fisico condiviso
- Esegue lo *scheduling* delle risorse radio (allocazione PRB)
- Multiplexa traffico dati e controllo
- Gestisce l'HARQ (Hybrid ARQ) per ritrasmissioni rapide

#nota()[
  Il mezzo radio è condiviso tra più utenti in modo ortogonale (OFDMA). Lo stack protocollare deve coordinare l'accesso di utenti con canali eterogenei e requisiti QoS diversi.
]

=== Stack Protocollare dell'eNodeB

L'eNodeB implementa un *dual stack*:
- *Stack verso la rete core*: protocolli IP standard (S1-AP/SCTP/IP)
- *Stack radio verso gli UE*: protocolli LTE (PDCP/RLC/MAC/PHY)

L'eNodeB funge da *gateway* tra i due domini, convertendo i messaggi tra le due interfacce.

Interfaccia S1-MME:
- Utilizza il protocollo S1-AP sopra SCTP/IP
- Gli indirizzi IP sono *interni alla rete dell'operatore* (IP dell'MME e IP dell'eNodeB)
- Non c'è visibilità dall'esterno: si tratta di una rete privata gestita dall'operatore


=== SCTP: Motivazioni

LTE utilizza *SCTP* invece di TCP per il control plane. In quanto TCP in ambito LTE sarebbe limitante per diversi motivi:
+ *Stream-oriented vs Message-oriented*:
  - TCP è *stream-oriented*: i dati sono visti come un flusso continuo di byte. Di conseguenza, le applicazioni devono aggiungere *marker* (delimitatori) per identificare i confini dei messaggi, introducendo *overhead superfluo* in termini di processing e banda
  - Nel control plane LTE, i messaggi hanno confini ben definiti (es. "Handover Request", "Attach Request")

+ *Mancanza di Multi-homing*:
  - TCP crea una connessione univoca tra due endpoint (IP:porta sorgente <-> IP:porta destinazione). Se uno degli endpoint fallisce, la connessione si interrompe
  - In LTE, un'area è servita da *più MME* per ridondanza e bilanciamento del carico. Per garantire la *fault tolerance* (gestione dei guasti), vogliamo che l'eNodeB possa connettersi a più MME simultaneamente.

+ *Head-of-Line (HOL) Blocking*: problema critico per il multiplexing di messaggi di controllo

#nota()[
  *Non* è possibile usare *UDP* perché non fornisce *affidabilità*. Il control plane deve garantire la consegna corretta di tutti i messaggi di segnalazione essendo fondamentali per il funzionamento della rete.
]

==== Problema del HOL Blocking in TCP

Il *Head-of-Line (HOL) Blocking* è una limitazione fondamentale di TCP quando si multiplexano messaggi indipendenti. In quanto TCP garantisce la consegna *in ordine* dei byte, se un segmento viene perso, tutti i segmenti successivi vengono bloccati fino a quando il segmento perso non viene ritrasmesso e ricevuto correttamente (i messaggi da consegnare sono tenuti in buffer).

#esempio()[
  Scenario: trasmissione di 3 segmenti TCP
  + Il segmento $1$ viene perso durante la trasmissione
  + I segmenti $2$ e $3$ arrivano correttamente a destinazione
  + I segmenti $2$ e $3$ *non possono essere consegnati* all'applicazione finché il segmento $1$ non viene ritrasmesso e ricevuto

]

In LTE TCP potrebbe portare a situazioni di HOL blocking molto gravi, soprattutto considerando che i messaggi di controllo sono *indipendenti* tra loro e hanno *requisiti di latenza stringenti*. In particolare, se ci sono più UE collegati alla stessa eNodeB, l'ack comulativo di TCP potrebbe bloccare messaggi di controllo importanti per un UE a causa di un messaggio perso per un altro UE.

#esempio()[
  Supponiamo di avere $3$ UE diversi ($A$, $B$, $C$) collegati alla stessa eNodeB, con messaggi di controllo inviati su un unico stream TCP:
  - UE A: messaggio di handover
  - UE B: messaggio di context setup
  - UE C: messaggio di bearer modification

  Se il pacchetto TCP contenente il messaggio di A viene perso, *anche i messaggi di B e C sono bloccati*, anche se sono completamente indipendenti. I messaggi $B$ e $C$ vengono inseriti in un buffer, non possono essere consegnati a livello applicazione
]

Per risolvere questi scenari di _blocco_, ci possono essere diverse soluzioni:

- Una connessione TCP per ogni UE. Il *$mr("problema")$* è un overhead insostenibile
  - Un eNodeB serve centinaia di UE $->$ centinaia di connessioni TCP
  - L'MME serve decine di eNodeB $->$ migliaia di connessioni TCP

  Questa soluzione *non scala*, troppo overhead di memoria e processing

- Usare SCTP → *approccio adottato da LTE*

==== SCTP: Multi-Streaming

SCTP risolve il problema HOL attraverso il *multi-streaming*.

L'idea è che una singola connessione SCTP possa contenere *più stream logici* indipendenti, ciascuno con il proprio ordinamento FIFO. In questo modo, se un messaggio in uno stream viene perso, solo quello stream è bloccato, mentre gli altri stream possono continuare a consegnare i loro messaggi normalmente.

#nota()[
  L'ordine è *parziale* tra stream, ma *totale* all'interno di ogni stream
]

SCTP aggiunge uno *Stream ID* nell'header di ogni messaggio, che identifica a quale stream appartiene. Il ricevitore mantiene buffer separati per ogni stream e consegna i messaggi all'applicazione in modo indipendente per ciascuno stream.

#esempio()[
  Configurazione SCTP con 3 stream:
  - Stream 0: messaggi per UE $A$
  - Stream 1: messaggi per UE $B$
  - Stream 2: messaggi per UE $C$

  Se un messaggio nello Stream 0 viene perso:
  - Stream 0 attende la ritrasmissione (HOL blocking *locale*)
  - Stream 1 e 2 continuano a consegnare i loro messaggi normalmente

  Risultato: i messaggi degli UE $B$ e $C$ non sono bloccati dal problema dell'UE $A$
]

==== SCTP: Multihoming

SCTP supporta il *multihoming*: un endpoint può avere *più indirizzi IP* associati alla stessa connessione.

*In TCP*:
- Connessione identificata da:
  `(IP_src, Port_src, IP_dst, Port_dst)`
- Se `IP_dst` diventa irraggiungibile → connessione fallisce

*In SCTP*:
- Connessione identificata da: `({IP_src1, IP_src2, ...}, Port_src, {IP_dst1, IP_dst2, ...}, Port_dst)`
- Se `IP_dst1` fallisce → SCTP passa automaticamente a `IP_dst2`
- *Failover trasparente*: l'applicazione non si accorge del cambio

In LTE, il multihoming è fondamentale per garantire la *ridondanza* e l'affidabilità del control plane.

Un dispositivo *eNodeB* può essere configurato con *più indirizzi IP* per connettersi a più MME:
- MME primario: gestisce il traffico normale
- MME secondario: subentra in caso di failure del primario

#nota()[
  Il multihoming introduce un piccolo *overhead nell'header* SCTP per specificare gli indirizzi multipli, ma i benefici in termini di affidabilità superano ampiamente questo costo.
]

==== SCTP: Message-Oriented

A differenza di TCP, SCTP è *message-oriented* invece di *stream-oriented*. Ciò significa che SCTP preserva i confini dei messaggi inviati dall'applicazione, senza richiedere un delimitatore esplicito.

#figure[
  #align(center)[
    #import "@preview/cetz:0.3.2": canvas, draw
    #canvas(length: 1cm, {
      import draw: *

      // Colori
      let color-red = rgb("#E74C3C")
      let color-blue = rgb("#3498DB")
      let color-light-blue = rgb("#5DADE2")

      // Funzione per disegnare un message box
      let msg-box(x, y, width, height, label, color) = {
        rect((x, y), (x + width, y + height), fill: color, stroke: 1.5pt + black, radius: 0.1)
        content((x + width / 2, y + height / 2), text(size: 7pt, fill: white, weight: "bold", label))
      }

      // ============ PARTE TCP (stream-oriented) ============
      let tcp-y = 5

      // Titolo TCP
      content((5, tcp-y + 2.8), text(size: 12pt, weight: "bold", "TCP (Stream-Oriented)"))

      // Application A (sinistra)
      rect((0, tcp-y + 0.8), (2, tcp-y + 2.5), stroke: 2pt + black, radius: 0.15)
      content((1, tcp-y + 2.3), text(size: 9pt, weight: "bold", "Application A"))

      // Messaggi in A
      msg-box(0.2, tcp-y + 1.8, 1.6, 0.35, "App message 1", color-red)
      msg-box(0.2, tcp-y + 1.35, 1.6, 0.35, "App message 2", color-blue)
      msg-box(0.2, tcp-y + 0.9, 1.6, 0.35, "App message 3", color-light-blue)

      // Application B (destra)
      rect((8, tcp-y + 0.8), (10, tcp-y + 2.5), stroke: 2pt + black, radius: 0.15)
      content((9, tcp-y + 2.3), text(size: 9pt, weight: "bold", "Application B"))

      // Messaggi in B (stesso ordine ma arrivano come stream)
      msg-box(8.2, tcp-y + 1.8, 1.6, 0.35, "App message 1", color-red)
      msg-box(8.2, tcp-y + 1.35, 1.6, 0.35, "App message 2", color-blue)
      msg-box(8.2, tcp-y + 0.9, 1.6, 0.35, "App message 3", color-light-blue)

      // Label "Application Level"
      content((5, tcp-y + 2.5), text(size: 8pt, style: "italic", fill: gray, "Application Level"))

      // Frecce da A al transport layer
      line((1, tcp-y + 0.8), (1, tcp-y + 0.4), stroke: 2pt + black, mark: (end: ">", scale: 0.8))

      // Transport Layer TCP - byte stream continuo
      let tcp-stream-y = tcp-y + 0.1
      rect((2.5, tcp-stream-y - 0.3), (7.5, tcp-stream-y + 0.3), stroke: 2pt + black, radius: 0.1)

      // Stream continuo di colori (senza separazioni)
      let segment-width = 5 / 9
      for i in range(9) {
        let color = if i < 3 { color-red } else if i < 6 { color-blue } else { color-light-blue }
        rect(
          (2.5 + i * segment-width, tcp-stream-y - 0.25),
          (2.5 + (i + 1) * segment-width, tcp-stream-y + 0.25),
          fill: color,
          stroke: 0.5pt + white,
        )
      }

      // Label Transport Level
      content((5, tcp-stream-y - 0.7), text(size: 8pt, weight: "bold", "Transport Level (TCP)"))
      content((5, tcp-stream-y - 1.1), text(
        size: 9pt,
        style: "italic",
        fill: black,
        "Byte stream continuo - nessun confine tra messaggi",
      ))

      // Frecce da transport layer a B
      line((9, tcp-stream-y), (9, tcp-y + 0.8), stroke: 2pt + black, mark: (end: ">", scale: 0.8))

      // ============ PARTE SCTP (message-oriented) ============
      let sctp-y = 1

      // Titolo SCTP
      content((5, sctp-y + 2), text(size: 12pt, weight: "bold", "SCTP (Message-Oriented)"))

      // Application A (sinistra)
      rect((0, sctp-y + 0.8), (2, sctp-y + 2.5), stroke: 2pt + black, radius: 0.15)
      content((1, sctp-y + 2.3), text(size: 9pt, weight: "bold", "Application A"))

      // Messaggi in A
      msg-box(0.2, sctp-y + 1.8, 1.6, 0.35, "App message 1", color-red)
      msg-box(0.2, sctp-y + 1.35, 1.6, 0.35, "App message 2", color-blue)
      msg-box(0.2, sctp-y + 0.9, 1.6, 0.35, "App message 3", color-light-blue)

      // Application B (destra)
      rect((8, sctp-y + 0.8), (10, sctp-y + 2.5), stroke: 2pt + black, radius: 0.15)
      content((9, sctp-y + 2.3), text(size: 9pt, weight: "bold", "Application B"))

      // Messaggi in B
      msg-box(8.2, sctp-y + 1.8, 1.6, 0.35, "App message 1", color-red)
      msg-box(8.2, sctp-y + 1.35, 1.6, 0.35, "App message 2", color-blue)
      msg-box(8.2, sctp-y + 0.9, 1.6, 0.35, "App message 3", color-light-blue)

      // Frecce da A al transport layer
      line((1, sctp-y + 0.8), (1, sctp-y + 0.4), stroke: 2pt + black, mark: (end: ">", scale: 0.8))

      // Transport Layer SCTP - messaggi separati
      let sctp-stream-y = sctp-y + 0.1

      // Messaggi SCTP separati con gap
      let msg-width = 1.4
      let gap = 0.2

      msg-box(2.5, sctp-stream-y - 0.25, msg-width, 0.5, "SCTP msg 1", color-red)
      msg-box(2.5 + msg-width + gap, sctp-stream-y - 0.25, msg-width, 0.5, "SCTP msg 2", color-blue)
      msg-box(2.5 + 2 * (msg-width + gap), sctp-stream-y - 0.25, msg-width, 0.5, "SCTP msg 3", color-light-blue)

      // Label Transport Level
      content((5, sctp-stream-y - 0.7), text(size: 8pt, weight: "bold", "Transport Level (SCTP)"))
      content((5, sctp-stream-y - 1.1), text(
        size: 9pt,
        style: "italic",
        fill: black,
        "I confini dei messaggi sono preservati",
      ))

      // Frecce da transport layer a B
      line((9, sctp-stream-y), (9, sctp-y + 0.8), stroke: 2pt + black, mark: (end: ">", scale: 0.8))
    })
  ]
]

*TCP (stream-oriented)*:
- L'Applicazione scrive: _MessageA_, _MessageB_, _MessageC_
- TCP invia: _MessageAMessageBMessa_ | _geCM_ | ... (segmentazione arbitraria)
- Il Ricevitore deve ricostruire i confini dei messaggi

*SCTP (message-oriented)*:
- Applicazione scrive: _MessageA_, _MessageB_, _MessageC_
- SCTP garantisce: ogni messaggio viene consegnato *intero* e *delimitato*
- Ricevitore riceve esattamente: _MessageA_, poi _MessageB_, poi _MessageC_
- *Nessun overhead* per delimitazione applicativa

$mg("Vantaggi")$ in LTE:
- Ogni messaggio S1-AP è un'unità atomica (es. "Handover Request")
- Processing più efficiente: non serve parsing per trovare i confini
- Riduzione delle risorse computazionali richieste


== User Plane: Stack Protocollare

L'*user plane* trasporta il traffico dati vero e proprio degli utenti. A differenza del control plane, utilizza il *tunneling GTP* per mantenere la sessione dati indipendente dalla mobilità.

Nell'architettura LTE esistono *tre livelli di indirizzamento IP* distinti:

- *Primo livello - IP dell'utente (UE $<->$ P-GW)*: Si tratta di indirizzi IP assegnati agli UE tramite *DHCP* o configurazione statica. Vengono utilizzati per la comunicazione tra UE e Internet/servizi esterni:
  - Gestiti dal P-GW con *NAT* (Network Address Translation)
  - *Visibili solo* all'interno del tunnel *GTP* tra UE e P-GW
  - _Esempio_: `10.x.x.x` o `172.16.x.x` (IP privati)

- *Secondo livello - IP pubblici (P-GW $<->$ Internet)*: Si tratta di *indirizzi IP pubblici*, assegnati al P-GW per comunicare con Internet:
  - Utilizzati per il traffico verso servizi esterni all'operatore
  - Soggetti a NAT se gli UE hanno IP privati

- *Terzo livello - IP interni della rete operatore*: Indirizzi IP utilizzati per il *routing interno* tra elementi della rete EPC. Essi vengono gestiti dall'operatore come rete privata separata:
  - Utilizzati per stabilire i tunnel GTP (S1-U, S5/S8). *Non visibili* dall'esterno: rete privata dell'operatore
  - _Esempi_: IP degli eNodeB, IP degli S-GW, IP dei P-GW, IP degli MME


#nota()[
  La separazione tra i tre livelli IP permette *mobilità trasparente*: l'IP dell'UE (livello 1) rimane costante anche quando cambiano gli elementi della rete (livello 3) durante la mobilità.
]

== GTP: GPRS Tunneling Protocol

Il *GTP (GPRS Tunneling Protocol)* è il protocollo fondamentale che permette di *incapsulare* il traffico dell'utente in tunnel logici attraverso la rete dell'operatore.

La connessione logica tra UE e P-GW è identificata da una sessione *Packet Data Network (PDN)*. L'UE è libero di muoversi all'interno della rete e possedere un proprio *IP* unico *mantenuto costante* per tutta la durata della sessione, indipendentemente da dove si trovi.

//todo fare disegno
#align(center)[
  #image("/assets/GTP-LTE.png", width: 80%)
]

#nota[
  L'UE ha una sessione dati con un P-GW specifico. Durante la mobilità, l'UE cambia eNodeB e potenzialmente anche S-GW:

  - *Senza GTP*, dovremmo aggiornare tutte le *tabelle di routing* della rete ad ogni movimento

  - *Con GTP*, solo gli endpoint del tunnel vengono aggiornati
]

$mg("Vantaggi")$ del tunneling:
- *Mobilità trasparente*: l'IP dell'UE rimane fisso durante tutta la sessione
- *Routing semplificato*: i router intermedi inoltrano solo in base all'IP del tunnel
- Isolamento: il traffico di ciascun UE è isolato nel proprio tunnel
- QoS end-to-end: ogni tunnel può avere classi di servizio diverse

=== Incapsulamento GTP
#align(center)[
  #image("/assets/DataPlane-LTE.png", width: 70%)
]


L'incapsulamento applicato da GTP per il traffico *uplink* (UE $->$ Internet) è il seguente:

+ *UE $<->$ eNodeB* (interfaccia `Uu`): Il pacchetto IP originale dell'UE viene trasmetto via radio all'eNodeB senza modifiche, esso avrà  i seguenti livelli:

  #figure[
    #align(center)[
      #cetz.canvas(length: 1cm, {
        import cetz.draw: *

        let box-width = 2
        let box-height = 0.8
        let spacing = 0.1


        // Rettangolo 1
        rect((0, 0), (box-width, box-height), stroke: 1pt + black, fill: rgb("#e8f4ff"))
        content((box-width / 2, box-height + 0.3), text(size: 8pt, ""))
        content((box-width / 2, box-height / 2), text(size: 9pt, weight: "bold", "RLC"))

        // Rettangolo 2
        let x2 = box-width + spacing
        rect((x2, 0), (x2 + box-width, box-height), stroke: 1pt + black, fill: rgb("#d0e8ff"))
        content((x2 + box-width / 2, box-height + 0.3), text(size: 8pt, ""))
        content((x2 + box-width / 2, box-height / 2), text(size: 9pt, weight: "bold", "IP"))

        // Rettangolo 3
        let x3 = x2 + box-width + spacing
        rect((x3, 0), (x3 + box-width, box-height), stroke: 1pt + black, fill: rgb("#b8dcff"))
        content((x3 + box-width / 2, box-height + 0.3), text(size: 8pt, ""))
        content((x3 + box-width / 2, box-height / 2), text(size: 9pt, weight: "bold", "UDP/TCP"))

        let x4 = x3 + box-width + spacing
        rect((x4, 0), (x4 + box-width, box-height), stroke: 1pt + black, fill: rgb("#b8dcff"))
        content((x4 + box-width / 2, box-height + 0.3), text(size: 8pt, ""))
        content((x4 + box-width / 2, box-height / 2), text(size: 9pt, weight: "bold", "DATA"))
      })
    ]
  ]

  #nota()[
    A questo livello *non* c'è routing: tutto il traffico va all'eNodeB
  ]

+ *eNodeB $<->$ S-GW* (interfaccia `S1-U`): In questo momento il pacchetto IP originale viene *incapsulato* in un tunnel GTP, con un nuovo header IP che identifica il tunnel tra eNodeB e S-GW.\
  Il `Tunnel ID (TEID)` corrisponde al identificatore tra *`eNodeB` $<->$ `S-GW`*.\
  Il pacchetto avrà i seguenti livelli:

  #figure[
    #align(center)[
      #cetz.canvas(length: 1cm, {
        import cetz.draw: *

        let box-width = 2
        let box-height = 0.8
        let spacing = 0.1

        // Rettangolo 1
        rect((0, 0), (box-width, box-height), stroke: 1pt + black, fill: rgb("#e8f4ff"))
        content((box-width / 2, box-height + 0.3), text(size: 8pt, "IP SGW"))
        content((box-width / 2, box-height / 2), text(size: 9pt, weight: "bold", "IP"))

        // Rettangolo 2
        let x2 = box-width + spacing
        rect((x2, 0), (x2 + box-width, box-height), stroke: 1pt + black, fill: rgb("#d0e8ff"))
        content((x2 + box-width / 2, box-height + 0.3), text(size: 8pt, "UDP port SGW"))
        content((x2 + box-width / 2, box-height / 2), text(size: 9pt, weight: "bold", "UDP"))

        // Rettangolo 3
        let x3 = x2 + box-width + spacing
        rect((x3, 0), (x3 + box-width, box-height), stroke: 1pt + black, fill: rgb("#b8dcff"))
        content((x3 + box-width / 2, box-height + 0.3), text(size: 8pt, "Tunnel ID (TEID)"))
        content((x3 + box-width / 2, box-height / 2), text(size: 9pt, weight: "bold", "GTP"))

        // Rettangolo 4
        let x4 = x3 + box-width + spacing
        rect((x4, 0), (x4 + box-width, box-height), stroke: 1pt + black, fill: rgb("#ffe8e8"))
        content((x4 + box-width / 2 + 0.7, box-height + 0.3), text(size: 8pt, "Pacchetto Utente"))
        content((x4 + box-width / 2, box-height / 2), text(size: 9pt, weight: "bold", "IP"))

        // Rettangolo 5
        let x5 = x4 + box-width + spacing
        rect((x5, 0), (x5 + box-width, box-height), stroke: 1pt + black, fill: rgb("#ffdddd"))
        content((x5 + box-width / 2, box-height + 0.3), text(size: 8pt, ""))
        content((x5 + box-width / 2, box-height / 2), text(size: 9pt, weight: "bold", "UDP/TCP"))

        // Rettangolo 6
        let x6 = x5 + box-width + spacing
        rect((x6, 0), (x6 + box-width, box-height), stroke: 1pt + black, fill: rgb("#ffd0d0"))
        content((x6 + box-width / 2 - 0.7, box-height + 0.3), text(size: 8pt, "INCAPSULAMENTO GTP"))
        content((x6 + box-width / 2, box-height / 2), text(size: 9pt, weight: "bold", "DATA"))
      })
    ]
  ]
  *Campi* el tunnel GTP:
  - *IP esterno*: `IP_eNodeB → IP_SGW` (livello 3: IP interni operatore)
  - *UDP*: porta 2152 (porta standard GTP-U per user plane)
  - *GTP Header*: contiene il *Tunnel ID* (TEID - Tunnel Endpoint Identifier)
    - TEID univoco per identificare la sessione UE specifica
    - Permette al S-GW di demultiplexare i pacchetti di diversi UE
    - Mapping: `(eNodeB, TEID) ↔ (UE, Bearer)`

+ *S-GW $->$ P-GW* (Interfaccia `S5/S8`): L'S-GW riceve il pacchetto, rimuove il tunnel GTP esterno e *crea un nuovo tunnel* verso il P-GW. In particolare vengono cambiati i seguenti campi:
  - `IP SGW` → `IP PGW`
  - `UDP port SGW` → `UDP port PGW`
  - `Tunnel ID (TEID)`: nuovo TEID per il tunnel `S-GW <-> P-GW`

  #figure[
    #align(center)[
      #cetz.canvas(length: 1cm, {
        import cetz.draw: *

        let box-width = 2
        let box-height = 0.8
        let spacing = 0.1

        // Rettangolo 1
        rect((0, 0), (box-width, box-height), stroke: 1pt + black, fill: rgb("#e8f4ff"))
        content((box-width / 2, box-height + 0.3), text(size: 8pt, "IP PGW", red))
        content((box-width / 2, box-height / 2), text(size: 9pt, weight: "bold", "IP"))

        // Rettangolo 2
        let x2 = box-width + spacing
        rect((x2, 0), (x2 + box-width, box-height), stroke: 1pt + black, fill: rgb("#d0e8ff"))
        content((x2 + box-width / 2, box-height + 0.3), text(size: 8pt, "UDP port PGW", red))
        content((x2 + box-width / 2, box-height / 2), text(size: 9pt, weight: "bold", "UDP"))

        // Rettangolo 3
        let x3 = x2 + box-width + spacing
        rect((x3, 0), (x3 + box-width, box-height), stroke: 1pt + black, fill: rgb("#b8dcff"))
        content((x3 + box-width / 2, box-height + 0.3), text(size: 8pt, "Tunnel ID (TEID)", red))
        content((x3 + box-width / 2, box-height / 2), text(size: 9pt, weight: "bold", "GTP"))

        // Rettangolo 4
        let x4 = x3 + box-width + spacing
        rect((x4, 0), (x4 + box-width, box-height), stroke: 1pt + black, fill: rgb("#ffe8e8"))
        content((x4 + box-width / 2, box-height + 0.3), text(size: 8pt, ""))
        content((x4 + box-width / 2, box-height / 2), text(size: 9pt, weight: "bold", "IP"))

        // Rettangolo 5
        let x5 = x4 + box-width + spacing
        rect((x5, 0), (x5 + box-width, box-height), stroke: 1pt + black, fill: rgb("#ffdddd"))
        content((x5 + box-width / 2, box-height + 0.3), text(size: 8pt, ""))
        content((x5 + box-width / 2, box-height / 2), text(size: 9pt, weight: "bold", "UDP/TCP"))

        // Rettangolo 6
        let x6 = x5 + box-width + spacing
        rect((x6, 0), (x6 + box-width, box-height), stroke: 1pt + black, fill: rgb("#ffd0d0"))
        content((x6 + box-width / 2 - 2, box-height + 0.3), text(size: 8pt, "INCAPSULAMENTO GTP"))
        content((x6 + box-width / 2, box-height / 2), text(size: 9pt, weight: "bold", "DATA"))
      })
    ]
  ]
  #nota()[
    Il pacchetto IP originale dell'UE *non viene mai modificato* finché non raggiunge il P-GW.
  ]

+ *P-GW $<->$ Internet*: Il PGW una volta aver ricevuto il pacchetto sull'interfaccia `S5/S8` *decapsula il tunnel GTP*, rimuovendone l'header e recuperando il pacchetto IP originale dell'UE. In particolare:
  1. Riceve il pacchetto GTP
  2. *Decapsula*: estrae il pacchetto IP originale (`IP_UE → IP_Server`)
  3. Applica *NAT* se necessario: traduce `IP_UE` (privato) in `IP_pubblico`
  4. Applica *policy* (firewall, QoS)
  5. Inoltra il pacchetto verso Internet

== EPS Bearer: Gestione della QoS

Gli *EPS Bearer* (Evolved Packet System Bearer) sono i meccanismi attraverso cui LTE garantisce la *qualità di servizio* (QoS) end-to-end tra l'UE e la rete esterna.

=== Architettura degli EPS Bearer

Un EPS Bearer è un *canale logico* con parametri QoS specifici che attraversa tutta la rete, dal dispositivo dell'utente fino al servizio esterno.

*Componenti dell'EPS Bearer*:

*1. External Bearer* (P-GW ↔ Servizio Esterno):
- Connessione tra P-GW e server/servizio su Internet
- QoS gestita tramite accordi con provider esterni o best-effort
- Fuori dal controllo diretto dell'operatore mobile

*2. EPS Bearer interno* (UE ↔ P-GW):
A sua volta suddiviso in tre segmenti:

a) *Radio Bearer* (UE ↔ eNodeB):
- Gestisce la QoS a livello *radio*
- Allocazione dinamica di PRB (Physical Resource Blocks)
- Priorità di scheduling
- Modulazione adattiva in base al canale

b) *S1 Bearer* (eNodeB ↔ S-GW):
- Tunnel GTP attraverso la rete di backhaul
- QoS garantita tramite DiffServ o MPLS
- Interfaccia S1-U

c) *S5/S8 Bearer* (S-GW ↔ P-GW):
- Tunnel GTP nella rete core
- QoS end-to-end all'interno della rete dell'operatore

#nota()[
  Tutti i segmenti del bearer devono *cooperare* per garantire la QoS richiesta. Se il Radio Bearer è lento, gli altri segmenti devono compensare o bufferizzare. La QoS effettiva è limitata dal segmento più debole ("collo di bottiglia").
]

=== Tipi di Bearer

Ogni UE può avere *al massimo 8 bearer attivi contemporaneamente*. I bearer si dividono in due categorie:

==== Default Bearer

Il *Default Bearer* viene creato automaticamente durante la procedura di *attach* (connessione iniziale alla rete).

*Caratteristiche*:
- Creato durante l'attach dell'UE alla rete
- Associato a una *PDN connection* (connessione a un P-GW specifico)
- All'UE viene assegnato un *indirizzo IP* per questa PDN
- Tipicamente ha QoS *best-effort* (QCI 9)
- Rimane attivo finché l'UE è connesso alla rete
- *Sempre presente*: non può essere rimosso senza disconnettere l'UE

#esempio()[
  Quando accendi il telefono e ti connetti alla rete 4G:
  + L'UE esegue la procedura di *attach*
  + Viene creato un *Default Bearer* verso il P-GW dell'operatore
  + Ti viene assegnato un IP (es. `10.123.45.67`)
  + Puoi navigare su Internet con QoS best-effort
]

==== Dedicated Bearer

I *Dedicated Bearer* sono bearer aggiuntivi creati *su richiesta* per fornire QoS garantita a specifiche applicazioni.

*Caratteristiche*:
- Vengono creati *dopo* l'attach, quando necessario
- Sono "fork" (derivazioni) del Default Bearer sulla stessa PDN connection
- Utilizzano lo *stesso IP* del Default Bearer
- Hanno *QoS superiore*: GBR (Guaranteed Bit Rate), latenza garantita, priorità
- Vengono rilasciati al termine della sessione applicativa

*Procedure di creazione*:
- *Network-initiated*: la rete (PCRF/P-GW) decide di creare un Dedicated Bearer
  - Esempio: chiamata VoLTE → IMS richiede al PCRF un bearer con QCI 1
- *UE-initiated*: l'UE richiede QoS specifica (raro, spesso negato per policy)

#esempio()[
  Scenario: videochiamata VoLTE
  + Hai già un *Default Bearer* attivo per navigazione web (QCI 9)
  + Avvii una videochiamata VoLTE
  + L'IMS richiede al PCRF un *Dedicated Bearer* con:
    - QCI 1 (voce, priorità 2, latenza < 100 ms, GBR)
  + Il PCRF invia i comandi a P-GW, S-GW, eNodeB
  + Viene creato un nuovo bearer sullo *stesso IP* del Default Bearer
  + Il traffico VoLTE usa il Dedicated Bearer (bassa latenza)
  + Il traffico web continua sul Default Bearer (best-effort)
  + A fine chiamata, il Dedicated Bearer viene *rilasciato*
]

==== Multiple PDN Connections

È possibile avere *più Default Bearer* contemporaneamente, ciascuno associato a una PDN connection diversa (P-GW diverso).

*Motivazioni*:
- Accesso a *servizi diversi*: Internet pubblica + APN aziendale privato
- Separazione del traffico: dati personali vs dati aziendali
- Multi-homing: connessione a più reti contemporaneamente

*Allocazione IP*:
- Ogni PDN connection ha il proprio *Default Bearer*
- Ogni Default Bearer ha un *indirizzo IP diverso*
- L'UE può avere quindi più IP simultanei


#esempio()[
  Smartphone aziendale:
  + *PDN 1*: Internet pubblica → Default Bearer con IP `10.x.x.x`
  + *PDN 2*: VPN aziendale → Default Bearer con IP `192.168.x.x`
  + *PDN 2.1*: Dedicated Bearer per VoIP aziendale (QCI 1)

  Totale: 3 bearer attivi (2 default + 1 dedicated)
]

*Limitazioni*:
- Massimo *8 bearer totali* per UE (somma di default e dedicated)
- Ogni Default Bearer può avere più Dedicated Bearer associati
- Configurazione tipica:
  - 1-2 Default Bearer (Internet + eventuale APN privato)
  - 0-6 Dedicated Bearer per applicazioni specifiche

#nota()[
  In 5G, il concetto di bearer viene sostituito dai *Network Slices*, che permettono una gestione ancora più granulare e flessibile della QoS, con la possibilità di creare "reti virtuali" dedicate per specifici servizi.
]

=== QoS Class Identifier (QCI)

Ogni bearer è caratterizzato da un *QCI* che definisce i parametri di QoS:

#align(center)[
  #table(
    columns: 6,
    align: (center, center, center, center, center, left),
    table.header([*QCI*], [*Tipo*], [*Priorità*], [*Delay*], [*Loss Rate*], [*Applicazione*]),
    [1], [GBR], [2], [100 ms], [$10^(-2)$], [VoLTE],
    [2], [GBR], [4], [150 ms], [$10^(-3)$], [Video call],
    [3], [GBR], [3], [50 ms], [$10^(-3)$], [Gaming real-time],
    [4], [GBR], [5], [300 ms], [$10^(-6)$], [Video streaming],
    [5], [Non-GBR], [1], [100 ms], [$10^(-6)$], [IMS signaling],
    [6], [Non-GBR], [6], [300 ms], [$10^(-6)$], [Video TCP],
    [7], [Non-GBR], [7], [100 ms], [$10^(-3)$], [Voice, gaming],
    [8], [Non-GBR], [8], [300 ms], [$10^(-6)$], [Web, email],
    [9], [Non-GBR], [9], [-], [-], [Internet default],
  )
]

== Procedure di Gestione EPS

=== Attach Procedure

Quando un UE si connette alla rete LTE, esegue la *procedura di attach*:

*Step*:
+ L'UE invia un *Attach Request* all'eNodeB
+ L'eNodeB lo inoltra all'MME (l'eNodeB non può decidere autonomamente di accettare o rifiutare)
+ L'MME verifica con l'HSS:
  - Autenticazione dell'utente
  - Profilo di abbonamento
  - Servizi autorizzati
+ L'MME contatta il P-GW appropriato
+ Viene creato il *Default Bearer*
+ All'UE viene assegnato un *indirizzo IP*
+ L'UE diventa *mobility registered* e *connected*

*Stati dell'UE*:
- *EMM-DEREGISTERED*: non connesso alla rete
- *EMM-REGISTERED*: connesso, può ricevere paging
  - *ECM-IDLE*: connesso ma senza risorse radio allocate
  - *ECM-CONNECTED*: risorse radio attive, può trasmettere/ricevere

=== Idle Mode e Paging

Quando l'UE è inattivo (nessun traffico dati), passa in *Idle Mode* per risparmiare energia:

*Caratteristiche Idle Mode*:
- Le risorse radio vengono *rilasciate*
- Il Default Bearer rimane *attivo logicamente*
- L'MME sa in quale Tracking Area si trova l'UE
- L'UE monitora i canali di *paging*

*Procedura di Paging*:
+ Arriva traffico per l'UE (es. chiamata in arrivo)
+ Il P-GW inoltra i pacchetti all'S-GW
+ L'S-GW notifica l'MME
+ L'MME invia *paging* a tutti gli eNodeB della Tracking Area
+ L'UE risponde al paging
+ Viene riattivato l'ECM-CONNECTED
+ Le risorse radio vengono riallocate
+ Il traffico può fluire

#informalmente()[
  L'Idle Mode è come "mettere il telefono in standby": la connessione logica rimane attiva (ricevi paging), ma non consumi risorse radio (batteria). Quando arriva una notifica o una chiamata, la rete ti "sveglia" tramite paging.
]
