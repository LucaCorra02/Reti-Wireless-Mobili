#import "../template.typ": *

== L2CAP Canali logici

$mb("L2CAP")$ (#[*Logical Link Control and Adaptation Protocol*]) supporta solo canali $mg("ACL")$. Offre tre tipi di canali logici:

/ *Connectionless*: canale $mo("unidirezionale")$, utilizzato quando un'applicazione vuole mandare qualcosa in $mp("broadcast")$ a tutta la rete.

/ *Connection-oriented*: canale $mo("bidirezionale")$, richiede di stabilire prima il livello di $mr("QoS")$ (Quality of Service). Serve per operazioni di controllo all'interno della piconet.

/ *SOS*: canale per servizi speciali.

#nota()[
  I pacchetti di L2CAP si occupano di *segmentazione* e *frammentazione* lato mittente, e *riassemblaggio* lato destinazione, in quanto un pacchetto applicativo non ci sta in un singolo pacchetto livello baseband.
]

#informalmente()[
  La frammentazione viene nascosta a livello data-link: un pacchetto fornito a L2CAP può occupare più pacchetti baseband e deve essere frammentato.
]

=== Identificazione dei canali

I 3 canali (servizi offerti da L2CAP) vengono riconosciuti da un $mb("Channel ID")$ ($2$ byte):

- $mg("ID = 1")$: *Canale di controllo*
- $mg("ID = 2")$: *Connectionless path*
- $mg("ID" >= 64)$: *Connection-oriented*

=== SDP Service Discovery

$mb("SDP")$ (#[*Service Discovery Protocol*]) è il protocollo utilizzato lato $mo("client")$ per:
- *Ricercare* un servizio specifico
- Fare *browsing* dei servizi disponibili

#nota()[
  SDP si appoggia sui canali $mg("ACL")$ per la comunicazione.
]

= Bluetooth Low Energy

#attenzione()[
  Introdotto nello standard $mb("4.0")$, l'obiettivo principale è $mr("ridurre drasticamente")$ le risorse utilizzate da Bluetooth, in particolare il *consumo energetico*.
]

=== Differenze principali rispetto a Bluetooth Classic

La procedura di $mg("inquiring")$ cambia, diventando *molto più semplice* e richiedendo $mo("meno consumo di batteria")$.

A differenza del Bluetooth normale abbiamo differenti *pattern di comunicazione*:

/ *Piconet* (stella): topologia classica con master e slave

/ *Broadcast*: trasmissione a tutti i dispositivi in ascolto

/ *Architettura Mesh*: rete distribuita tra più nodi

/ *Presenza*: notifica automatica della presenza di un dispositivo

/ *Distanza*: misura della distanza tramite radio frequenze ($mr("RSSI")$)

/ *Direction*: individuazione della direzione di provenienza del segnale

#nota()[
  *Tutti* i beacon Bluetooth sono dispositivi $mb("Low Energy")$.
]

=== Caratteristiche tecniche

Per quanto riguarda il protocollo cambiano alcuni livelli a differenza del Bluetooth base. In particolare l'*architettura si semplifica*.

La banda rimane $mg(2.4 "GHz")$. I canali diventano $mb(40)$ canali:
- $mo(37)$ canali usati come *data channels*
- $mr(3)$ canali dedicati all'*advertising*: canali $37$, $38$, $39$

#nota()[
  Il $mp("frequency hopping")$ è *molto più semplice*. Il canale successivo viene calcolato come:
  $
    mg("Channel") = ("curr_channel" + "hop") mod 37
  $
  dove $"hop"$ è stabilito all'atto della connessione.
]

=== Modulazione

Viene utilizzata $mb("GFSK")$ (#[*Gaussian Frequency Shift Keying*]) con rate di modulazione a $mo(1 "Mbps")$, sufficiente per gli scopi di Bluetooth Low Energy.

#figure[
  #align(center)[
    #cetz.canvas(length: 1cm, {
      import cetz.draw: *

      let start-x = 0
      let total-width = 14
      let channel-width = total-width / 40

      // Banda totale 2.4 GHz
      rect((start-x, 0), (start-x + total-width, 1.5), stroke: 1.2pt + black)
      content((start-x + total-width / 2, 1.8), text(size: 10pt, weight: "bold", "2.4 GHz ISM Band"))

      // Canali di advertising
      let adv-positions = (0, 19.5, 39)
      for pos in adv-positions {
        let x = start-x + pos * channel-width
        rect((x, 0), (x + channel-width, 1.5), fill: rgb("#FF6B6B").lighten(30%), stroke: 1.2pt + red)
      }

      // Etichette canali advertising
      content(
        (start-x + 0 * channel-width + channel-width / 2, 0.75),
        text(size: 7pt, weight: "bold", "37"),
        fill: white,
      )
      content(
        (start-x + 19.5 * channel-width + channel-width / 2, 0.75),
        text(size: 7pt, weight: "bold", "38"),
        fill: white,
      )
      content(
        (start-x + 39 * channel-width + channel-width / 2, 0.75),
        text(size: 7pt, weight: "bold", "39"),
        fill: white,
      )

      // Zona data channels (centro)
      rect(
        (start-x + 1 * channel-width, 0.3),
        (start-x + 19 * channel-width, 1.2),
        fill: rgb("#4ECDC4").lighten(50%),
        stroke: none,
      )
      content((start-x + 10 * channel-width, 0.75), text(size: 8pt, "Data Channels 0-36"))

      // Legenda
      let legend-y = -1
      rect(
        (start-x, legend-y),
        (start-x + 0.5, legend-y + 0.4),
        fill: rgb("#FF6B6B").lighten(30%),
        stroke: 0.8pt + black,
      )
      content((start-x + 2, legend-y + 0.2), text(size: 8pt, "Advertising Channels (37, 38, 39)"), anchor: "west")

      rect(
        (start-x, legend-y - 0.6),
        (start-x + 0.5, legend-y - 0.2),
        fill: rgb("#4ECDC4").lighten(50%),
        stroke: 0.8pt + black,
      )
      content((start-x + 2, legend-y - 0.4), text(size: 8pt, "Data Channels (0-36)"), anchor: "west")
    })
  ]
  caption: [Distribuzione dei 40 canali BLE nella banda 2.4 GHz]
]

#informalmente()[
  Un ricevitore conosce l'$"hop"$, capisce qual è il $"current channel"$ perché sente trasmettere e calcola il canale successivo con queste informazioni.
]

#attenzione()[
  I canali di $mr("advertising")$ sono posizionati strategicamente: uno all'*inizio*, uno al *centro* e uno alla *fine* dello spettro. Questo serve per $mo("ridurre le interferenze")$ con altri dispositivi (come WiFi). Vengono spalmati in modo _equo_ all'interno dello spettro.
]

== Stati del Link Layer BLE

Cambia la *macchina a stati finiti*, in particolare gli $mb("stati del link-layer")$. Gli stati sono diversi dal punto di vista dell'*utilizzo* che ne viene fatto:

/ $mo("Isochronous Broadcasting")$: modo *temporizzato* di fare broadcasting. Il livello link layer mette a disposizione questo servizio che periodicamente invia sui $3$ canali di advertising.

/ $mp("Advertising")$: Si $mr("inverte")$ il paradigma classico! Non c'è più un master che fa enquiring, è lo $mg("slave")$ che annuncia _"ci sono!"_ sui canali di advertising.

#attenzione()[
  *Inversione di paradigma*: in Bluetooth classico il master cerca attivamente gli slave (inquiry), in BLE sono gli slave che si annunciano periodicamente (advertising) e il master li ascolta passivamente.
]

#nota()[
  Rimane la completa $mr("non sincronizzazione")$ del sistema: master e slave non hanno un clock comune.
]

=== Meccanismo di Advertising

L'advertising viene fatto nel seguente modo:

#informalmente()[
  Il dispositivo che vuole essere scoperto (advertiser) trasmette periodicamente pacchetti di advertising sui 3 canali dedicati.
]

Il $mb("tempo di advertising")$ è l'intervallo tra due eventi di advertising consecutivi:
$
  mg(T_"advEvent") = mo("advInterval") + mr("advDelay")
$

Dove:

/ $mo("advInterval")$: parametro *configurabile* interno al dispositivo. La scelta di questo tempo influisce direttamente sul $mr("consumo di batteria")$:
  - Intervallo $mo("breve")$ → maggiore consumo, ma più veloce discovery
  - Intervallo $mo("lungo")$ → minor consumo, ma discovery più lenta

/ $mr("advDelay")$: numero $mp("random")$ tra $0$ e $10"ms"$. Serve per ridurre la possibilità di $mr("collisioni")$ tra più dispositivi che fanno advertising contemporaneamente.

#figure[
  #align(center)[
    #cetz.canvas(length: 1cm, {
      import cetz.draw: *

      let start-x = 0
      let y-pos = 2

      // Timeline
      line((start-x, y-pos), (start-x + 14, y-pos), stroke: 1.2pt + black, mark: (end: ">"))
      content((start-x + 14.5, y-pos), text(size: 9pt, "t"))

      // Eventi di advertising
      for i in range(4) {
        let base-x = start-x + i * 3.5
        let delay = (0.3, 0.5, 0.2, 0.4).at(i)
        let event-x = base-x + delay

        // Pacchetto advertising
        rect((event-x, y-pos - 0.3), (event-x + 0.4, y-pos + 0.3), fill: rgb("#FF6B6B"), stroke: 1pt + black)

        // Linea verticale
        line((event-x + 0.2, y-pos - 0.35), (event-x + 0.2, y-pos - 0.8), stroke: (paint: gray, dash: "dashed"))

        if i > 0 {
          // advInterval
          let prev-x = start-x + (i - 1) * 3.5 + (0.3, 0.5, 0.2, 0.4).at(i - 1) + 0.2
          line((prev-x, y-pos - 1.2), (base-x, y-pos - 1.2), stroke: 1pt + blue, mark: (start: ">", end: ">"))
          content(((prev-x + base-x) / 2, y-pos - 1.5), text(size: 7pt, fill: blue, "advInterval"))

          // advDelay
          if delay > 0 {
            line((base-x, y-pos - 1.8), (event-x + 0.2, y-pos - 1.8), stroke: 1pt + red, mark: (start: ">", end: ">"))
            content(((base-x + event-x + 0.2) / 2, y-pos - 2.1), text(size: 7pt, fill: red, "advDelay"))
          }
        }
      }

      // Etichetta
      content((start-x + 7, y-pos + 0.8), text(size: 9pt, weight: "bold", "Advertising Events"))
    })
  ]
  caption: [Timing degli eventi di advertising con advInterval e advDelay random]
]

#attenzione()[
  *Non ci sono garanzie di latenza* (a causa del delay random). Bluetooth Low Energy $mr("non ha requisiti real-time")$.
]

=== GATT (Generic Attribute Profile)

$mb("GATT")$ gestisce i *profili* dei dispositivi BLE. I profili sono specifici e definiscono $mo("cosa fa")$ il dispositivo.

#esempio()[
  Alcuni profili comuni:
  - $mg("BCS")$ - Body Composition Service
  - $mg("CSCP")$ - Cycling Speed and Cadence Profile
  - $mg("HRS")$ - Heart Rate Service
  - $mg("BAS")$ - Battery Service
]

#nota()[
  Un dispositivo può $mp("includere più profili")$ contemporaneamente. I profili $mr("non sono esclusivi")$.
]

=== GAP (Generic Access Profile)

$mb("GAP")$ gestisce lo *stato del dispositivo* a un livello più alto, più vicino al software applicativo.

#informalmente()[
  GAP definisce i $mo("ruoli")$ che un dispositivo può assumere nella rete BLE.
]

I quattro ruoli principali sono:

- $mg("Broadcaster")$ (TX): spedisce advertising packet
- $mo("Observer")$ (RX): ascolta sui canali di advertising (passivo)
- $mp("Peripheral")$ (Slave): si annuncia e vuole essere scoperto
- $mr("Central")$ (Master): scopre e si connette ai peripheral

=== Processo di connessione

#nota()[
  Il processo è $mr("specchiato")$ rispetto a Bluetooth Classic!
]

A livello link layer, durante la fase di connessione troviamo i seguenti stati (obiettivo: creare una comunicazione $mo("unicast")$ per scambiare messaggi):

+ Il dispositivo che vuole essere scoperto ($mg("slave")$) usa periodicamente i $3$ canali di advertising

+ Il dispositivo $mp("scanner")$ ascolta questi canali

+ Una volta ricevuto un messaggio, il scanner $mo("risponde sempre su quel canale")$. Se non riceve risposta cambia canale

+ Dopo aver connesso lo slave, viene comunicato l'$mr("hop")$ dall'$"initiator"$ che diventa client

#informalmente()[
  Il master svolge il ruolo di $mb("client")$ per verificare se lo slave si è collegato correttamente.
]

=== Comunicazione broadcast

In questo caso abbiamo un dispositivo in modalità $mg("Broadcaster")$ che vuole trasmettere a tutti.

#figure[
  #align(center)[
    #cetz.canvas(length: 1cm, {
      import cetz.draw: *

      // Broadcaster al centro
      circle((7, 4), radius: 0.6, fill: rgb("#FF6B6B"), stroke: 1.5pt + black)
      content((7, 4), text(size: 9pt, weight: "bold", fill: white, "B"))
      content((7, 2.8), text(size: 8pt, weight: "bold", "Broadcaster"))

      // Cerchio di broadcast
      circle((7, 4), radius: 3, stroke: (paint: rgb("#FF6B6B"), thickness: 1.5pt, dash: "dashed"))

      // Observers intorno
      let observers = (
        (4, 6, "O1"),
        (10, 6, "O2"),
        (4.5, 2.5, "O3"),
        (9.5, 2, "O4"),
      )

      for (x, y, label) in observers {
        circle((x, y), radius: 0.5, fill: rgb("#4ECDC4"), stroke: 1.2pt + black)
        content((x, y), text(size: 8pt, weight: "bold", fill: white, label))

        // Frecce dal broadcaster
        let angle = calc.atan2(y - 4, x - 7)
        let start-x = 7 + 0.6 * calc.cos(angle)
        let start-y = 4 + 0.6 * calc.sin(angle)
        let end-x = x - 0.5 * calc.cos(angle)
        let end-y = y - 0.5 * calc.sin(angle)

        line((start-x, start-y), (end-x, end-y), stroke: 1.2pt + red, mark: (end: ">"))
      }

      // Observer fuori range
      circle((12, 4), radius: 0.5, fill: gray.lighten(40%), stroke: 1.2pt + black)
      content((12, 4), text(size: 8pt, weight: "bold", fill: white, "O5"))

      // X per indicare fuori range
      line((11.7, 3.7), (12.3, 4.3), stroke: 2pt + red)
      line((11.7, 4.3), (12.3, 3.7), stroke: 2pt + red)

      // Legenda
      content((7, 0.5), text(size: 7pt, "Raggio di comunicazione broadcast"))
    })
  ]
  caption: [Comunicazione broadcast: un Broadcaster trasmette a tutti gli Observer nel raggio]
]

#informalmente()[
  Chi vuole ascoltare si mette in modalità $mp("Observer")$ ricevendo le informazioni. $mr("Solamente")$ chi è nel raggio di comunicazione le riceve.
]

#nota()[
  L'observer scandaglia solamente i $mg(3)$ canali di advertising. $mo("Non c'è risposta")$ della ricezione delle informazioni, è solamente un *ascolto passivo*.
]

=== Passive and Active scanning

// riguardare

= ZigBee

#attenzione()[
  ZigBee è uno standard per reti wireless *personali* ($"WPAN"$) ottimizzato per $mr("basso consumo")$, $mo("basso costo")$ e $mg("alta affidabilità")$.
]

=== Obiettivi di design

*Requisiti principali*:

/ $mr("Affidabilità")$: comunicazione robusta e stabile

/ $mo("Basso costo")$: dispositivi economici e accessibili

/ $mg("Lunga durata batteria")$: anni di funzionamento con una singola batteria

/ $mp("Bassa complessità")$: hardware semplice per ridurre costi e consumi

/ $mb("Banda ISM gratuita")$: $2.4 "GHz"$ senza licenze da pagare

/ $mo("Alto numero di nodi")$: supporto per migliaia di dispositivi (vs. 7 slave in Bluetooth)

/ $mg("Interoperabilità")$: standard aperto, compatibilità tra diversi vendor

=== Tipi di dispositivi

- $mg("FFD")$ (Full Function Device): coordinatore di rete, può instradare
- $mo("Router FFD")$ (Router Full Function Device): instrada pacchetti tra dispositivi
- $mp("EndDevice RFD")$ (Reduced Function Device): dispositivo finale, solo TX/RX

=== Tipologie di scambio dati

ZigBee supporta tre pattern di comunicazione:

/ $mg("Dati periodici")$: invio $mo("regolare e programmato")$ di dati
  - Esempio: sensori di temperatura, umidità, dispositivi IoT smart
  - Prevedibile e ottimizzabile per il consumo energetico

/ $mr("Dati intermittenti asincroni")$: comunicazione $mp("guidata da eventi")$
  - Esempio: interruttori, pulsanti, allarmi
  - Stimoli esterni imprevedibili

/ $mb("Dati ripetitivi a bassa latenza")$: comunicazione $mo("time-critical")$
  - Richiede allocazione di $mg("time slot garantiti")$ (GTS)
  - Esempio: controllo in tempo reale, automazione industriale

== Architettura

#nota()[
  Lo standard $mb("IEEE 802.15.4")$ definisce i livelli *fisico* e *MAC*, che rimangono fissi. I livelli superiori sono definiti dalla ZigBee Alliance.
]

=== Livello fisico

Lo standard specifica la tipologia di $mg("modulazione")$ e di $mo("spread spectrum")$ per 3 bande di frequenza:

/ $mp("Spread Spectrum")$: tecnica DSSS (Direct Sequence Spread Spectrum)
  - *Spread factor*: sequenza di bit pseudo-casuale ($"PN code"$) messa in $mr("XOR")$ con il bit da trasmettere
  - *Chip rate*: rapporto tra bit trasmessi fisicamente e bit utili di payload

/ $mg("Modulazione")$:
  - $mb("BPSK")$ (Binary Phase Shift Keying): $1$ chip per simbolo
  - $mo("O-QPSK")$ (Offset Quadrature Phase Shift Keying): $2$ chip per simbolo

*Bande di frequenza supportate*:

- $868 "MHz"$: $1$ canale, BPSK, $20 "Kbps"$
- $915 "MHz"$: $10$ canali, BPSK, $40 "Kbps"$
- $mg(2.4 "GHz")$: $mg(16)$ canali, $mo("O-QPSK")$, $mo(250 "Kbps")$ (più usata)

#informalmente()[
  Il data rate massimo è $mo(250 "Kbps")$, circa $mr(1/4)$ del data rate di Bluetooth Classic. Sembra molto basso, ma per l'utilizzo tipico di ZigBee (sensori, controllo, automazione) è $mg("più che sufficiente")$.
]

== Livello MAC

=== Duty-Cycle

#attenzione()[
  Il $mb("duty-cycle")$ è il parametro fondamentale per il risparmio energetico in ZigBee. È specifico per ogni dispositivo.
]

#informalmente()[
  Se l'obiettivo è ridurre l'utilizzo della batteria, $mr("non")$ conviene mantenere la radio $mo("sempre accesa")$ in ascolto e trasmissione. Andiamo a scegliere dei *tempi di spegnimento* a seconda del tipo di dispositivo e del suo ruolo nella rete.
]

$
  mg("duty-cycle") = ("tempo attivo") / ("tempo totale") times 100%
$

#esempio()[
  - Coordinatore: duty-cycle $mr("alto")$ (sempre o quasi sempre attivo)
  - Router: duty-cycle $mo("medio")$ (attivo quando necessario)
  - End device: duty-cycle $mg("molto basso")$ (acceso solo per TX/RX brevi)
]

=== Modalità di accesso al mezzo

C'è sempre un $mb("coordinatore")$ che gestisce la rete. Due modalità principali:

/ *Gestione basata su beacon*: Il coordinatore emette periodicamente messaggi di $mg("beacon")$ per sincronizzare la rete
  - $mr("Non")$ c'è TDMA puro
  - Si usa $mo("CSMA/CA")$ (Carrier Sense Multiple Access with Collision Avoidance)
  - In wireless $mr("non si può fare collision detection")$: non posso trasmettere e sentire contemporaneamente cosa trasmetto
  - Devo $mg("prevenire")$ le collisioni, non solo rilevarle

/ *Broadcast dal coordinatore*: Il coordinatore invia messaggi a tutta la rete

#nota()[
  Le possibilità di gestione di CSMA/CA sono:
  - $mo("Unslotted CSMA/CA")$: accesso asincrono, senza sincronizzazione
  - $mg("Slotted CSMA/CA")$: richiede beacon periodici per sincronizzazione temporale
]

=== CSMA/CA con Beacon

Il coordinatore invia periodicamente dei $mb("beacon")$. La frequenza deve essere concordata a priori, inoltre c'è una deriva del clock abbastanza importante.

#attenzione()[
  I beacon servono per tre funzioni fondamentali:
]

+ $mg("Sincronizzazione")$: tutti i dispositivi sincronizzano i loro clock con il coordinatore

+ $mo("Organizzazione comunicazione")$: gestire device che comunicano periodicamente vs. device asincroni

+ $mr("Comunicazione indiretta")$: il coordinatore mantiene una *lista di pending messages*. Nel beacon comunica quali dispositivi hanno messaggi in attesa. Il dispositivo che si riconosce nella lista sa che deve lasciare la radio $mp("accesa")$ per ricevere. Se non deve né ascoltare né trasmettere, può $mg("spegnere la radio")$ e risparmiare energia.

=== Struttura del Super-Frame

Il beacon definisce la struttura del $mb("super-frame")$, che va da un beacon al successivo.

#figure[
  #align(center)[
    #cetz.canvas(length: 1cm, {
      import cetz.draw: *

      let start-x = 0
      let start-y = 3
      let sf-width = 12
      let sf-height = 1.5

      // Beacon iniziale
      rect((start-x, start-y), (start-x + 0.3, start-y + sf-height), fill: rgb("#FF6B6B"), stroke: 1.2pt + black)
      content((start-x + 0.15, start-y + sf-height + 0.4), text(size: 7pt, weight: "bold", "Beacon"))

      // Parte attiva (CAP + CFP)
      let active-width = 7

      // CAP (Contention Access Period)
      let cap-width = 4.5
      rect(
        (start-x + 0.3, start-y),
        (start-x + 0.3 + cap-width, start-y + sf-height),
        fill: rgb("#4ECDC4").lighten(30%),
        stroke: 1.2pt + black,
      )
      content((start-x + 0.3 + cap-width / 2, start-y + sf-height / 2), text(size: 9pt, weight: "bold", "CAP"))
      content((start-x + 0.3 + cap-width / 2, start-y + sf-height / 2 - 0.4), text(size: 7pt, "Contention"))
      content((start-x + 0.3 + cap-width / 2, start-y + sf-height / 2 - 0.7), text(size: 7pt, "Access Period"))

      // CFP (Contention Free Period)
      let cfp-width = active-width - cap-width
      rect(
        (start-x + 0.3 + cap-width, start-y),
        (start-x + 0.3 + active-width, start-y + sf-height),
        fill: rgb("#95E1D3"),
        stroke: 1.2pt + black,
      )
      content((start-x + 0.3 + cap-width + cfp-width / 2, start-y + sf-height / 2), text(
        size: 8pt,
        weight: "bold",
        "CFP",
      ))
      content((start-x + 0.3 + cap-width + cfp-width / 2, start-y + sf-height / 2 - 0.4), text(size: 6pt, "GTS slots"))

      // Parte inattiva
      let inactive-width = sf-width - active-width - 0.3 - 0.3
      rect(
        (start-x + 0.3 + active-width, start-y),
        (start-x + sf-width - 0.3, start-y + sf-height),
        fill: gray.lighten(60%),
        stroke: 1.2pt + black,
      )
      content((start-x + 0.3 + active-width + inactive-width / 2, start-y + sf-height / 2), text(
        size: 9pt,
        weight: "bold",
        "Inattiva",
      ))
      content((start-x + 0.3 + active-width + inactive-width / 2, start-y + sf-height / 2 - 0.5), text(
        size: 7pt,
        "Radio OFF",
      ))

      // Beacon finale
      rect(
        (start-x + sf-width - 0.3, start-y),
        (start-x + sf-width, start-y + sf-height),
        fill: rgb("#FF6B6B"),
        stroke: 1.2pt + black,
      )
      content((start-x + sf-width - 0.15, start-y + sf-height + 0.4), text(size: 7pt, weight: "bold", "Beacon"))

      // Frecce e annotazioni
      // Beacon Interval
      line((start-x + 0.15, start-y - 0.5), (start-x + sf-width - 0.15, start-y - 0.5), stroke: 1.2pt + blue, mark: (
        start: ">",
        end: ">",
      ))
      content((start-x + sf-width / 2, start-y - 0.9), text(
        size: 8pt,
        fill: blue,
        weight: "bold",
        "Beacon Interval (BI)",
      ))

      // Super-frame Duration
      line((start-x + 0.3, start-y - 1.5), (start-x + 0.3 + active-width, start-y - 1.5), stroke: 1.2pt + red, mark: (
        start: ">",
        end: ">",
      ))
      content((start-x + 0.3 + active-width / 2, start-y - 1.9), text(
        size: 8pt,
        fill: red,
        weight: "bold",
        "Super-frame Duration (SD)",
      ))

      // Slot divisions nel CAP
      for i in range(1, 8) {
        let x = start-x + 0.3 + (cap-width / 8) * i
        line((x, start-y), (x, start-y + sf-height), stroke: (paint: black, thickness: 0.5pt, dash: "dotted"))
      }

      // Legenda
      let legend-y = start-y - 3
      rect(
        (start-x, legend-y),
        (start-x + 0.5, legend-y + 0.3),
        fill: rgb("#4ECDC4").lighten(30%),
        stroke: 0.8pt + black,
      )
      content((start-x + 1.5, legend-y + 0.15), text(size: 7pt, "CAP: slot in contesa (CSMA/CA)"), anchor: "west")

      rect((start-x, legend-y - 0.5), (start-x + 0.5, legend-y - 0.2), fill: rgb("#95E1D3"), stroke: 0.8pt + black)
      content((start-x + 1.5, legend-y - 0.35), text(size: 7pt, "CFP: slot garantiti (GTS)"), anchor: "west")

      rect((start-x, legend-y - 1), (start-x + 0.5, legend-y - 0.7), fill: gray.lighten(60%), stroke: 0.8pt + black)
      content((start-x + 1.5, legend-y - 0.85), text(size: 7pt, "Inattiva: risparmio energetico"), anchor: "west")
    })
  ]
  caption: [Struttura del Super-Frame in ZigBee 802.15.4]
]

#informalmente()[
  Il super-frame è diviso in due parti principali:

  *Parte Attiva* (divisa in due):
  - $mo("CAP")$ - Contention Access Period: slot condivisi, tutti i dispositivi competono usando CSMA/CA
  - $mg("CFP")$ - Contention Free Period: contiene $mr("GTS")$ (Guaranteed Time Slot), slot già allocati dal coordinatore a specifici dispositivi per comunicazioni con garanzie di latenza

  *Parte Inattiva*:
  - Nessun messaggio viene comunicato
  - Più è grande la parte inattiva, $mp("più risparmio energia")$
  - I dispositivi possono $mb("spegnere la radio")$ completamente
]

=== Parametri del Super-Frame

La durata delle varie parti del super-frame viene comunicata attraverso il beacon:

#nota()[
  *Parametri fondamentali*:
]

/ $mb("aBaseSuperFrameDuration")$ ($mg("aBSD")$): Unità di tempo fondamentale definita dallo standard IEEE 802.15.4
  - Corrisponde alla trasmissione di $mr(960)$ simboli
  - Unità di base per calcolare tutte le altre durate

/ $mo("Beacon Order")$ ($"BO"$): Determina l'intervallo tra beacon consecutivi
  $
    mg("Beacon Interval") = mo("aBSD") times 2^mb("BO")
  $
  - Valore: $0 <= "BO" <= 14$ ($2$ byte)
  - $"BO" = 0$ → beacon molto frequenti
  - $"BO" = 14$ → beacon molto distanziati

/ $mp("Super-frame Order")$ ($"SO"$): Determina la durata della parte attiva
  $
    mr("Super-frame Duration") = mo("aBSD") times 2^mp("SO")
  $
  - Valore: $0 <= "SO" <= "BO" <= 14$
  - Deve essere $"SO" <= "BO"$ (la parte attiva non può superare l'intervallo tra beacon)

#attenzione()[
  Il $mb("duty-cycle")$ della rete è determinato dal rapporto tra $"SO"$ e $"BO"$:
  $
    mg("duty-cycle") = (2^mo("SO")) / (2^mr("BO")) = 2^(mo("SO") - mr("BO"))
  $
]

#esempio()[
  - $"BO" = 8$, $"SO" = 6$ → duty-cycle $= 2^(-2) = 1/4 = 25%$
  - $"BO" = 10$, $"SO" = 5$ → duty-cycle $= 2^(-5) = 1/32 approx 3%$ ($mr("risparmio energetico elevato")$)
  - $"BO" = "SO"$ → duty-cycle $= 100%$ (nessuna parte inattiva)
]

=== Super-Frame Specification Field

Il campo $mb("Super-frame Specification")$ nel beacon contiene tutte le informazioni sulla struttura del super-frame:

- $mg("Beacon Order")$ (BO): determina $mo("ogni quanto")$ aspettarsi un beacon
- $mp("Super-frame Order")$ (SO): determina quanto è $mr("grande")$ la parte attiva
- $mo("Final CAP Slot")$: indica in che punto $mg("termina")$ il CAP (non può sforare nel CFP)
- $mb("Reserved")$: bit riservati per uso futuro
- $mr("PAN Coordinator")$: flag che indica se il dispositivo è un coordinatore PAN
- $mg("Association Permit")$: flag che indica se sono permesse nuove associazioni alla rete

#nota()[
  Il CAP è diviso in $mg(16)$ slot temporali di uguale durata. La grandezza di ogni slot dipende dal numero totale di simboli nella parte attiva diviso 16.
]

#informalmente()[
  Il numero di simboli nella Super-frame Duration può variare da $mg("aBSD") times 2^0 = 960$ simboli a $mg("aBSD") times 2^14 = 15.728.640$ simboli.

  Questi simboli vengono divisi in $mr(16)$ slot uguali nel CAP:
  $
    mo("Slot size") = (mg("aBSD") times 2^mp("SO")) / 16
  $
]

=== Guaranteed Time Slots (GTS)

#attenzione()[
  Il $mb("GTS")$ è un $mr("contratto")$ che il coordinatore ha fatto con specifici dispositivi, per garantire di comunicare $mo("senza interferenze")$ in determinati slot temporali.
]

#nota()[
  La durata degli slot condivisi nel CAP dipende da quanti simboli ho diviso 16. I GTS nel CFP hanno durate che possono essere multiple degli slot base.
]

=== Accesso al CAP: Algoritmo CSMA/CA

Il livello fisico offre il servizio $mg("CS")$ (#[*Carrier Sense*]): ascolta la portante e rileva se qualcuno sta trasmettendo.

#nota()[
  Il livello fisico mette a disposizione la $mb("CCA")$ (#[*Clear Channel Assessment*]) per capire se il canale è $mo("libero")$. Ascolta per intervalli brevi (costa energia!).
]

=== Variabili di stato (per ogni dispositivo)

Ogni dispositivo mantiene internamente tre variabili per gestire l'accesso:

- $mg("NB")$ (Number of Backoffs): iniziale $= 0$, max $= 4$ - Numero di backoff tentati (ottimista!)
- $mo("BE")$ (Backoff Exponent): iniziale $= 3$, max $= 5$ - Periodo di attesa
- $mp("CW")$ (Contention Window): iniziale $= 2$, max $= 2$ - CCA consecutive richieste

/ $mg("NB")$ (#[*Number of Backoffs*]): Conta i tentativi di accesso falliti
  - Inizialmente è $0$ (siamo ottimisti!)
  - Massimo $mr(4)$ tentativi
  - Se dopo $4$ tentativi non va a buon fine, viene comunicato al livello superiore il $mr("fallimento")$

/ $mo("BE")$ (#[*Backoff Exponent*]): Determina il numero di slot da attendere prima di riprovare
  - Periodo di backoff $= "random"[0, 2^mb("BE") - 1] times 20$ simboli
  - Aumenta ad ogni fallimento per $mp("differenziare")$ i dispositivi (exponential backoff)
  - Serve per $mr("disallinearsi")$: tutti i dispositivi sono allineati alla ricezione del beacon

/ $mp("CW")$ (#[*Contention Window*]): Numero di CCA $mg("consecutive")$ con esito positivo necessarie prima di trasmettere
  - Devono essere $2$ CCA consecutive con canale libero
  - Riduce la probabilità di collisioni

=== Algoritmo CSMA/CA: Esempio dettagliato

#esempio()[
  *Scenario*: Un dispositivo vuole trasmettere un pacchetto usando slotted CSMA/CA nel CAP.

  #figure[
    #align(center)[
      #cetz.canvas(length: 1cm, {
        import cetz.draw: *

        let slot-width = 0.8
        let slot-height = 1.2
        let start-x = 0
        let y-beacon = 5
        let y-backoff = 3.5
        let y-cca = 2
        let y-tx = 0.5

        // Beacon
        rect((start-x, y-beacon), (start-x + 0.5, y-beacon + 0.8), fill: rgb("#FF6B6B"), stroke: 1.2pt + black)
        content((start-x + 0.25, y-beacon + 0.4), text(size: 8pt, weight: "bold", fill: white, "B"))
        content((start-x + 0.25, y-beacon + 1.2), text(size: 7pt, "Beacon"))

        // Timeline
        line((start-x + 0.5, y-beacon + 0.4), (start-x + 14, y-beacon + 0.4), stroke: 1pt + gray, mark: (end: ">"))

        // Slot del CAP
        for i in range(16) {
          let x = start-x + 0.5 + i * slot-width
          rect((x, y-beacon + 0.1), (x + slot-width - 0.05, y-beacon + 0.7), stroke: 0.5pt + gray, fill: none)
          if i < 3 {
            content((x + slot-width / 2, y-beacon - 0.3), text(size: 6pt, str(i)))
          }
        }

        // Random backoff (esempio: 3 slot)
        let backoff-start = start-x + 0.5
        let backoff-slots = 3
        for i in range(backoff-slots) {
          let x = backoff-start + i * slot-width
          rect(
            (x, y-backoff),
            (x + slot-width - 0.05, y-backoff + slot-height),
            fill: rgb("#FFD93D").lighten(30%),
            stroke: 1pt + black,
          )
        }
        content((backoff-start + backoff-slots * slot-width / 2, y-backoff + slot-height / 2), text(size: 7pt, "Wait"))
        content((backoff-start + backoff-slots * slot-width / 2, y-backoff - 0.5), text(
          size: 7pt,
          fill: orange,
          "Random backoff",
        ))
        content((backoff-start + backoff-slots * slot-width / 2, y-backoff - 0.8), text(
          size: 6pt,
          fill: orange,
          "[0, 2^BE - 1] × 20 simboli",
        ))

        // Prima CCA (successo)
        let cca1-x = backoff-start + backoff-slots * slot-width
        rect(
          (cca1-x, y-cca),
          (cca1-x + slot-width - 0.05, y-cca + slot-height),
          fill: rgb("#6BCB77").lighten(30%),
          stroke: 1.2pt + green.darken(20%),
        )
        content((cca1-x + slot-width / 2, y-cca + slot-height / 2), text(size: 7pt, weight: "bold", "CCA1"))
        content((cca1-x + slot-width / 2, y-cca + slot-height / 2 - 0.3), text(size: 6pt, "✓ OK"))
        content((cca1-x + slot-width / 2, y-cca - 0.5), text(size: 7pt, fill: green.darken(20%), "CW = 1"))

        // Seconda CCA (successo)
        let cca2-x = cca1-x + slot-width
        rect(
          (cca2-x, y-cca),
          (cca2-x + slot-width - 0.05, y-cca + slot-height),
          fill: rgb("#6BCB77").lighten(30%),
          stroke: 1.2pt + green.darken(20%),
        )
        content((cca2-x + slot-width / 2, y-cca + slot-height / 2), text(size: 7pt, weight: "bold", "CCA2"))
        content((cca2-x + slot-width / 2, y-cca + slot-height / 2 - 0.3), text(size: 6pt, "✓ OK"))
        content((cca2-x + slot-width / 2, y-cca - 0.5), text(size: 7pt, fill: green.darken(20%), "CW = 0"))

        // Trasmissione
        let tx-x = cca2-x + slot-width
        rect(
          (tx-x, y-tx),
          (tx-x + 2 * slot-width - 0.05, y-tx + slot-height),
          fill: rgb("#4ECDC4"),
          stroke: 1.5pt + blue,
        )
        content((tx-x + slot-width, y-tx + slot-height / 2), text(size: 8pt, weight: "bold", fill: white, "TX"))
        content((tx-x + slot-width, y-tx - 0.5), text(size: 7pt, fill: blue, "Trasmissione!"))

        // Frecce di flusso
        line(
          (backoff-start + backoff-slots * slot-width / 2, y-backoff - 0.3),
          (cca1-x + slot-width / 2, y-cca + slot-height + 0.2),
          stroke: 1pt + gray,
          mark: (end: ">"),
        )
        line((cca1-x + slot-width / 2, y-cca - 0.3), (cca2-x + slot-width / 2, y-cca - 0.3), stroke: 1pt + gray)
        line(
          (cca2-x + slot-width / 2, y-cca - 0.7),
          (tx-x + slot-width, y-tx + slot-height + 0.2),
          stroke: 1pt + blue,
          mark: (end: ">"),
        )
      })
    ]
    caption: [Accesso con successo al CAP usando CSMA/CA]
  ]

  *Passi dell'algoritmo (caso successo)*:

  + $mg("Ricezione beacon")$: tutti i dispositivi si sincronizzano

  + $mo("Random backoff")$: attendo un numero casuale $[0, 2^mr("BE") - 1]$ slot
    - Con $"BE" = 3$ iniziale → attendo tra $[0, 7]$ slot
    - Nel nostro caso: $3$ slot di backoff
    - La radio può essere $mp("spenta")$ durante l'attesa (risparmio energia)

  + $mg("Prima CCA")$: ascolto il canale
    - Canale $mo("libero")$ ✓ → $"CW" = 1$

  + $mg("Seconda CCA")$: riascolto nel slot successivo
    - Canale ancora $mo("libero")$ ✓ → $"CW" = 0$

  + $mb("Trasmissione")$: posso finalmente trasmettere il pacchetto!
]

#esempio()[
  *Scenario con collisione*:

  Se durante una delle CCA il canale risulta $mr("occupato")$:

  + La $mp("CW")$ viene $mr("reimpostata")$ a $2$

  + $mg("NB")$ viene incrementato: $"NB" = "NB" + 1$

  + $mo("BE")$ viene incrementato: $"BE" = min("BE" + 1, 5)$
    - Aumenta l'intervallo di backoff per $mp("differenziare")$ i dispositivi
    - Con $"BE" = 4$ → backoff casuale tra $[0, 15]$ slot

  + Si $mr("riparte")$ dal random backoff con i nuovi parametri

  + Se $"NB" > 4$ → $mr("fallimento")$, comunicato al livello superiore
]

#nota()[
  Durante il backoff la radio può essere $mo("spenta")$ per risparmiare energia. Si $mr("perde")$ l'opportunità di trasmettere prima, ma in ZigBee $mg("non ci sono requisiti di bassa latenza")$ o real-time.
]

#attenzione()[
  *Gestione del tempo limite del CAP*:

  Se mentre aspetto il random backoff o faccio le CCA il tempo $mr("sconfina")$ oltre la fine del CAP (inizio del CFP), l'algoritmo:

  + $mo("Blocca")$ il timer al valore corrente

  + Al $mg("beacon successivo")$ riparte da quel valore salvato

  + Rimane in una sorta di $mp("coda virtuale")$

  Questo meccanismo $mr("previene la starvation")$ del dispositivo: se ripartisse sempre da $"BE" = 3$ potrebbe non riuscire mai a trasmettere.
]

//aggiungere tempo di Turn around

//aggiungere tempo d Turn around
