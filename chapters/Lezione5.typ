#import "../template.typ": *

== L2CAP Canali logici

*L2CAP* (#[*Logical Link Control and Adaptation Protocol*]) supporta solo canali ACL. Offre tre tipi di canali logici:

/ *Connectionless*: canale unidirezionale, utilizzato quando un'applicazione vuole mandare un messaggio in *broadcast* a tutta la rete.

/ *Connection-oriented*: canale bidirezionale, richiede di stabilire prima il livello di *QoS* (Quality of Service).

/ *Signaling (SOS)*: canale bidirezionale usato per  per servizi speciali. Serve per *operazioni di controllo* all'interno della piconet.

#nota()[
  Il livello L2CAP si occupa di fare *segmentazione* e *frammentazione* dei pacchetti che arrivano lato applicazione dal mittente, e *riassemblaggio* lato destinazione. Operazioni necessarie in quanto un pacchetto applicativo non ci sta in un singolo pacchetto livello baseband.

  La frammentazione viene nascosta a livello data-link.
]

=== Dimensione dei pacchetti

I 3 canali (servizi offerti da L2CAP) vengono riconosciuti da un *Channel ID* ($2$ byte):
- $"ID" = 1$: _Canale di controllo_
- $"ID" = 2$: _Connectionless path_
- $"ID" >= 64$: _Connection-oriented_

Al posto di avere dati relativi all'applicazione, il payload di un pacchetto di controllo contiene:
- _Code_: codice per il tipo di comando
- _Id_: per l'Identificazione del comando



=== SDP Service Discovery

*SDP* (#[*Service Discovery Protocol*]) è il protocollo utilizzato lato client per:
- *Ricercare* un servizio specifico
- Fare *browsing* dei servizi disponibili

#nota()[
  SDP si appoggia sui canali ACL per la comunicazione.
]

= Bluetooth Low Energy

#attenzione()[
  Introdotto nello standard *4.0*, l'obiettivo principale è *ridurre drasticamente* le risorse utilizzate da Bluetooth, in particolare il *consumo energetico*.
]

== Bluetooth Low Energy vs Bluetooth Classic

La prima differenza è che la procedura di *inquiry* cambia, diventando *molto più semplice*, richiedendo *meno consumo di batteria*.

A differenza del Bluetooth normale abbiamo differenti *pattern di comunicazione*:
/ *Piconet* (stella): topologia classica con master e slave.

/ *Broadcast*: trasmissione a tutti i dispositivi in ascolto.

/ *Architettura Mesh*: rete distribuita tra più nodi.

/ *Presenza*: notifica automatica della presenza di un dispositivo.

/ *Distanza*: misura della distanza tramite radio frequenze (RSSI).

/ *Direction*: individuazione della direzione di provenienza del segnale.

#nota()[
  *Tutti* i beacon Bluetooth sono dispositivi *Low Energy*.
]



== BLE Radio (PHY)

Viene utilizzata *GFSK* (#[*Gaussian Frequency Shift Keying*]) con rate di modulazione a $1 "Mbps"$, sufficiente per gli scopi di Bluetooth Low Energy.

Per quanto riguarda il protocollo in sè cambiano alcuni livelli a differenza del Bluetooth base. In particolare l'*architettura si semplifica*. La *banda* rimane *$2.4 "GHz"$*, tuttavia i canali diventano $40$:
- $37$ canali usati come data channels
- $3$ canali dedicati all'advertising: canali $37$, $38$, $39$

#nota()[
  Il *frequency hopping* è *molto più semplice*. Il canale successivo viene calcolato come:
  $
    "Channel" = ("curr_channel" + "hop") mod 37
  $
  dove $"hop"$ è stabilito all'atto della connessione.
]

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
        (start-x + 1.2 * channel-width, 0.3),
        (start-x + 19.2 * channel-width, 1.2),
        fill: rgb("#4ECDC4").lighten(50%),
        stroke: none,
      )
      content((start-x + 10 * channel-width, 0.75), text(size: 8pt, "Data Channels 0-36"))

      rect(
        (start-x + 13.2 + 1 * channel-width, 0.3),
        (start-x + 20.8 * channel-width, 1.2),
        fill: rgb("#4ECDC4").lighten(50%),
        stroke: none,
      )
      content((start-x + 30 * channel-width, 0.75), text(size: 8pt, "Data Channels 0-36"))

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

#attenzione()[
  I canali di *advertising* sono posizionati strategicamente: uno all'*inizio*, uno al *centro* e uno alla *fine* dello spettro. Questo serve per *ridurre le interferenze* con altri dispositivi (come WiFi). Vengono spalmati in modo _equo_ all'interno dello spettro.
]

=== Stati del Link Layer BLE

Cambia la *macchina a stati finiti*, in particolare gli *stati del link-layer*. Gli stati sono diversi dal punto di vista dell'*utilizzo* che ne viene fatto:

/ *Isochronous Broadcasting*: modo *temporizzato* di fare broadcasting (isocrono). Il livello link layer mette a disposizione questo servizio che periodicamente invia sui 3 canali di advertising.

/ *Advertising*: Si *inverte* il paradigma classico. Non c'è più un master che fa inquiry, è lo *slave* che *annuncia la presenza* sui canali di advertising.

#nota()[
  Nonostante l'*inversione di paradigma*: in Bluetooth classico il master cerca attivamente gli slave (inquiry), in BLE sono gli slave che si annunciano periodicamente (advertising) e il master li ascolta passivamente.\
  Rimane la completa *non sincronizzazione* del sistema: master e slave non hanno un clock comune.
]


=== Meccanismo di Advertising

#informalmente()[
  Il dispositivo che vuole essere scoperto (advertiser) trasmette periodicamente pacchetti di advertising sui 3 canali dedicati.
]

Il *tempo di advertising* è l'intervallo tra due eventi di advertising consecutivi ed è determinato da:
$
  T_"advEvent" = "advInterval" + "advDelay"
$
Dove:
- `advInterval`: rappresenta il rate di invio dei pacchetti di advertising. Si tratta di un multiplo di $625 mu s$ nel range $20 "ms"-10.24"s"$. Il suo valore è determinato in base all'uso del dispositivo (tipologia di sensore). La scelta di questo tempo influisce direttamente sul *consumo di batteria*:
  - Intervallo *breve* → maggiore consumo, ma più veloce nella discovery
  - Intervallo *lungo* → minor consumo, ma discovery più lenta

- `advDelay`: numero *random* tra $0$ e $20"ms"$. Serve per *ridurre* la possibilità di *collisioni* tra più dispositivi che fanno advertising contemporaneamente (sempre multiplo di $625 mu s$).

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
    caption: [
    Timing degli eventi di advertising con advInterval e advDelay random
    ]
  ]
]
#attenzione()[
  *Non ci sono garanzie di latenza* (a causa del delay random). Bluetooth Low Energy *non ha requisiti real-time*.
]

=== GATT (Generic Attribute Profile)

*GATT* gestisce i *profili* dei dispositivi BLE. Il suo compito è mediare tra il server (provider di servizi) e applicazione (richiede i servizi). I profili sono specifici e definiscono *cosa fa* il dispositivo. Alcuni profili comuni sono:
- *BCS* - Body Composition Service
- *CSCP* - Cycling Speed and Cadence Profile
- *HRS* - Heart Rate Service
- *BAS* - Battery Service

#nota()[
  Un dispositivo può *includere più profili* contemporaneamente. I profili *non sono esclusivi*.
]

=== GAP (Generic Access Profile)

*GAP* gestisce lo *stato del dispositivo* a un livello più alto, più vicino al software applicativo. Un'applicazione in base al suo scopo può decidere uno dei ruoli definiti da GAP.

I quattro ruoli principali sono:
- *Broadcaster* (TX): spedisce advertising packet (trasmissione connectionless)
- *Observer* (RX): ascolta sui canali di advertising (passivo)
- *Peripheral* (Slave): si annuncia e vuole essere scoperto
- *Central* (Master): scopre e si connette ai peripheral

=== Processo di connessione

#nota()[
  Il processo è *specchiato* rispetto a Bluetooth Classic
]

L'obiettivo è creare una comunicazione *unicast* (peer to peer) per scambiare messaggi. A livello link layer, durante la fase di connessione troviamo i seguenti stati (supponendo di avere un Host $A$ che funge da master e un Host $B$ che funge da slave) :

+ Il dispositivo che vuole essere scoperto (*slave*) usa periodicamente i 3 canali di advertising, inviando degli advertising packet undirect (diretti a _nessuno_).

+ Il dispositivo *scanner* (Master) ascolta questi canali

+ Una volta ricevuto un messaggio, il master *risponde sempre su quel canale*. In particolare, il master invierà una *connection request* nello slot di tempo successivo (viene mantenuto sempre il *TDD*, nello slot di tempo successivo all’invio il dispositivo starà aspettando). Nella connection request sono presenti anche le informazioni per il FH.

+ Dopo aver connesso lo slave, viene comunicato l'*hop* dall'initiator che diventa client

#informalmente()[
  Il master svolge il ruolo di *client* per verificare se lo slave si è collegato correttamente.
]

=== Comunicazione broadcast

In questo caso abbiamo un dispositivo in modalità *Broadcaster* che vuole trasmettere a tutti. Utile quando un broadcaster non ha interesse ad avere un master (vuole solo inviari i dati).

I dispositivi che vogliono ascoltare si mettono in modalità *Observer* ricevendo le informazioni. *Solamente* chi è nel raggio di comunicazione le riceve.

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

      // Observers intorno (posizioni distribuite per evitare sovrapposizione frecce)
      let observers = (
        (5, 6.2, "O1"),
        (9, 6, "O2"),
        (4.5, 2.5, "O3"),
        (9, 2, "O4"),
      )

      for (x, y, label) in observers {
        circle((x, y), radius: 0.5, fill: rgb("#4ECDC4"), stroke: 1.2pt + black)
        content((x, y), text(size: 8pt, weight: "bold", fill: white, label))
      }

      // Frecce dal broadcaster agli observers (separate dal loop per evitare sovrapposizioni)
      for (x, y, label) in observers {
        let dx = x - 7
        let dy = y - 4
        let distance = calc.sqrt(dx * dx + dy * dy)

        // Calcola i punti di inizio e fine sulle circonferenze
        let start-x = 7 + 0.7 * dx / distance
        let start-y = 4 + 0.7 * dy / distance
        let end-x = x - 0.6 * dx / distance
        let end-y = y - 0.6 * dy / distance

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

#nota()[
  L'observer scandaglia solamente i 3 canali di advertising. *Non c'è risposta* della ricezione delle informazioni, è solamente un *ascolto passivo*.
]

\ *Passive scanning*: Lo scanner ascolta passivamente e periodicamente sui canali di advertising (solo passivo).

\ *Active scanning*: Sempre e solo usando i canali di advertising, lo scanner ascolta sul canale per poi richiedere dei dati tramite scan request (e di conseguenza otterrà la response). Quest’ultima parte è unicast con il dispositivo
di broadcast.

= ZigBee

ZigBee è uno standard per reti wireless *personali* (WPAN) ottimizzato per *basso consumo*, *basso costo* e *alta affidabilità*.

Rispetta sempre lo standard IEEE $802.15$. Gli obbiettivi che si prefigge questo protocollo sono:
- *Affidabilità*: comunicazione robusta e stabile

- *Basso costo*: dispositivi economici e accessibili

- *Lunga durata batteria*: anni di funzionamento con una singola batteria. Utilizzato soprattutto per sensoristica.

- *Bassa complessità*: hardware semplice per ridurre costi e consumi

- *Banda ISM gratuita*: $2.4 "GHz"$ senza licenze da pagare

- *Alto numero di nodi*: supporto per migliaia di dispositivi (vs. 7 slave in Bluetooth)

- *Interoperabilità*: standard aperto, compatibilità tra diversi vendor

=== Tipi di dispositivi

- *Coordinator FFD* (Full Function Device): coordinatore di rete, è l'unico all'interno della rete. Il suo compito è creare la rete e mantenere le informazioni della rete (es. chiavi di sicurezza).

- *Router FFD* (Router Full Function Device): instrada pacchetti tra dispositivi

- *EndDevice RFD* (Reduced Function Device): dispositivo finale. Da un punto di vista di rete possiedono solo la funzionalità di parlare con un router/coordinatore. Ridotta complessità ed elevato risparmio energetico.

=== Topologie di rete

ZigBee supporta diverse topologie di rete a seconda delle esigenze applicative:
- *Star*: La topologia più semplice, tutti i dispositivi comunicano direttamente con il coordinatore
- *Cluster Tree*: Estende la copertura usando router che formano una struttura ad albero
- *Mesh*: La più flessibile e robusta, i router sono interconnessi e offrono percorsi multipli per i dati

#figure[
  #align(center)[
    #cetz.canvas(length: 0.5cm, {
      import cetz.draw: *

      // === TOPOLOGIA STAR ===
      let star-x = 2
      let star-y = 7

      // Coordinatore centrale
      circle((star-x, star-y), radius: 0.4, fill: red, stroke: 1.2pt + black)

      // Dispositivi intorno (6 nodi)
      let star-devices = (
        (star-x - 1.5, star-y + 1.5),
        (star-x, star-y + 1.8),
        (star-x + 1.5, star-y + 1.2),
        (star-x + 1.5, star-y - 0.5),
        (star-x, star-y - 1.8),
        (star-x - 1.5, star-y - 0.5),
      )

      for (x, y) in star-devices {
        circle((x, y), radius: 0.3, fill: yellow, stroke: 1pt + black)
        line((star-x, star-y), (x, y), stroke: 1.2pt + black)
      }

      // Etichetta
      content((star-x, star-y - 3), text(size: 11pt, weight: "bold", "Star"))

      // === TOPOLOGIA CLUSTER TREE ===
      let tree-x = 8
      let tree-y = 4

      // Coordinatore
      circle((tree-x, tree-y), radius: 0.4, fill: red, stroke: 1.5pt + black)

      // Router livello 1 (2 router)
      let router1-pos = ((tree-x - 1.5, tree-y - 2), (tree-x + 1.5, tree-y - 2))

      for (rx, ry) in router1-pos {
        circle((rx, ry), radius: 0.35, fill: blue, stroke: 1.2pt + black)
        line((tree-x, tree-y), (rx, ry), stroke: 1.2pt + black)

        // Dispositivi per ogni router (3 dispositivi)
        let devices = (
          (rx - 1, ry - 1.3),
          (rx, ry - 1.5),
          (rx + 1, ry - 1.3),
        )

        for (dx, dy) in devices {
          circle((dx, dy), radius: 0.3, fill: yellow, stroke: 1pt + black)
          line((rx, ry), (dx, dy), stroke: 1.2pt + black)
        }
      }

      // Etichetta
      content((tree-x, tree-y - 5), text(size: 11pt, weight: "bold", "Cluster Tree"))

      // === TOPOLOGIA MESH ===
      let mesh-x = 16
      let mesh-y = 7

      // Coordinatore
      circle((mesh-x, mesh-y), radius: 0.4, fill: red, stroke: 1.5pt + black)

      // Router positions (5 router interconnessi)
      let routers = (
        (mesh-x + 1.5, mesh-y + 0.8),
        (mesh-x + 2.5, mesh-y - 0.5),
        (mesh-x + 1.8, mesh-y - 2),
        (mesh-x, mesh-y - 2.5),
        (mesh-x - 1.2, mesh-y - 1),
      )

      // Disegna router
      for (rx, ry) in routers {
        circle((rx, ry), radius: 0.35, fill: blue, stroke: 1.2pt + black)
      }

      // Connessioni mesh tra nodi
      let mesh-connections = (
        (0, 1),
        (0, 2),
        (0, 3),
        (0, 4), // Dal coordinatore
        (1, 2),
        (2, 3),
        (3, 4),
        (1, 3),
        (2, 4), // Tra router
      )

      for (i, j) in mesh-connections {
        if i == 0 {
          let (rx, ry) = routers.at(j)
          line((mesh-x, mesh-y), (rx, ry), stroke: 1.2pt + black)
        } else {
          let (x1, y1) = routers.at(i - 1)
          let (x2, y2) = routers.at(j)
          line((x1, y1), (x2, y2), stroke: 1.2pt + black)
        }
      }

      // Dispositivi finali collegati ai router
      let mesh-devices = (
        (mesh-x + 1.5, mesh-y + 2),
        (mesh-x + 3, mesh-y + 0.8),
        (mesh-x + 3.5, mesh-y - 0.5),
        (mesh-x, mesh-y - 4),
        (mesh-x + 2.5, mesh-y - 3),
        (mesh-x + 3.5, mesh-y - 2),
        (mesh-x - 2, mesh-y - 1),
        (mesh-x - 1, mesh-y + 0.5),
      )

      let device-to-router = (
        (0, 0),
        (1, 0),
        (2, 1),
        (3, 3),
        (4, 2),
        (5, 2),
        (6, 4),
        (7, 4),
      )

      for i in range(mesh-devices.len()) {
        let (dx, dy) = mesh-devices.at(i)
        circle((dx, dy), radius: 0.3, fill: yellow, stroke: 1pt + black)

        let router-idx = device-to-router.at(i).at(1)
        if router-idx < routers.len() {
          let (rx, ry) = routers.at(router-idx)
          line((rx, ry), (dx, dy), stroke: 1.2pt + black)
        }
      }

      // Etichetta
      content((mesh-x, mesh-y - 5), text(size: 11pt, weight: "bold", "Mesh"))

      // === LEGENDA ===
      let legend-x = -4
      let legend-y = 2

      circle((legend-x, legend-y), radius: 0.3, fill: red, stroke: 1.2pt + black)
      content((legend-x + 2.5, legend-y), text(size: 9pt, "ZigBee Coordinator"), anchor: "west")

      circle((legend-x, legend-y - 0.8), radius: 0.3, fill: blue, stroke: 1.2pt + black)
      content((legend-x + 2.5, legend-y - 0.8), text(size: 9pt, "ZigBee Routers"), anchor: "west")

      circle((legend-x, legend-y - 1.6), radius: 0.3, fill: yellow, stroke: 1.2pt + black)
      content((legend-x + 2.5, legend-y - 1.6), text(size: 9pt, "ZigBee Devices"), anchor: "west")
    })
  ]
  caption: [Topologie di rete ZigBee: Star, Cluster Tree e Mesh]
]



=== Tipologie di scambio dati

ZigBee supporta tre pattern di comunicazione:
/ *Dati periodici*: invio *regolare e programmato* di dati
  - Esempio: sensori di temperatura, umidità, dispositivi IoT smart
  - Prevedibile e ottimizzabile per il consumo energetico

/ *Dati intermittenti asincroni*: comunicazione *guidata da eventi*
  - Esempio: interruttori, pulsanti, allarmi
  - Stimoli esterni imprevedibili

/ *Dati ripetitivi a bassa latenza*: comunicazione *time-critical*
  - Richiede allocazione di *time slot garantiti* (GTS)
  - Esempio: controllo in tempo reale, automazione industriale

== Architettura

#nota()[
  Lo standard *IEEE 802.15.4* definisce i livelli *fisico* e *MAC*, che rimangono fissi. I livelli superiori sono definiti dalla ZigBee Alliance.
]

=== Livello fisico

Lo standard specifica la tipologia di *modulazione* e di *spread spectrum* per 3 bande di frequenza:

/ *Spread Spectrum*: tecnica DSSS (Direct Sequence Spread Spectrum), viene usato il multiplexing sui canali all'interno della banda:
  - *Spread factor*: sequenza di bit pseudo-casuale (PN code) messa in *XOR* con il bit da trasmettere
  - *Chip rate*: rapporto tra bit trasmessi fisicamente e bit utili di payload

/ *Modulazione*:
  - *BPSK* (Binary Phase Shift Keying): $1$ chip per simbolo
  - *O-QPSK* (Offset Quadrature Phase Shift Keying): $2$ chip per simbolo

*Bande di frequenza supportate*:

- $868 "MHz"$: $1$ canale, BPSK, $20 "Kbps"$
- $915 "MHz"$: $10$ canali, BPSK, $40 "Kbps"$
- $2.4 "GHz"$: 16 canali, O-QPSK, $250 "Kbps"$ (più usata)

#nota()[
  Il data rate massimo è $250 "Kbps"$, circa $1/4$ del data rate di Bluetooth Classic. Sembra molto basso, ma per l'utilizzo tipico di ZigBee (sensori, controllo, automazione) è *più che sufficiente*.
]

=== Livello Data Link (MAC)

Il livello ha i seguenti compiti:
- Gestisce l'invio dei beacon ( se il dispositivo è PAN coordinator)
- Sincronizzazione con i beacon del coordinatore
- Accesso al canale tramite CSMA/CA
- Gestione del duty-cycle del dispositivo

Se l'obiettivo è ridurre l'utilizzo della batteria, *non* conviene mantenere la radio *sempre accesa* in ascolto e trasmissione. Andiamo a scegliere dei *tempi di spegnimento* (duty cycle) a seconda del tipo di dispositivo e del suo ruolo nella rete:
$
  "duty-cycle" = ("tempo attivo") / ("tempo totale") times 100%
$

#attenzione()[
  Il *duty-cycle* è il parametro fondamentale per il risparmio energetico in ZigBee. È specifico per ogni dispositivo.
]

#esempio()[
  - Coordinatore: duty-cycle *alto* (sempre o quasi sempre attivo)
  - Router: duty-cycle *medio* (attivo quando necessario)
  - End device: duty-cycle *molto basso* (acceso solo per TX/RX brevi)
]

=== Modalità di accesso al mezzo

C'è sempre un *coordinatore* che gestisce la rete, attraverso due modalità principali:

/ *Gestione basata su beacon*: Il coordinatore emette periodicamente messaggi di *beacon* per sincronizzare la rete
  - *Non* c'è TDMA puro
  - Si usa *CSMA/CA* (Carrier Sense Multiple Access with Collision Avoidance)

  #attenzione()[
    In ambito wireless *non si può fare collision detection*: non posso trasmettere e _sentire_ contemporaneamente cosa trasmetto. Per questo motivo bisonga cercare di *prevenire* le collisioni, non solo rilevarle.
  ]

  Le possibilità di gestione di CSMA/CA sono:
  - *Unslotted CSMA/CA*: accesso asincrono, senza sincronizzazione
  - *Slotted CSMA/CA*: richiede beacon periodici per sincronizzazione temporale

/ *Broadcast dal coordinatore*: Il coordinatore invia messaggi a tutta la rete

=== Slotted CSMA/CA con Beacon

Nella modalità slotted, il coordinatore invia periodicamente dei *beacon* (inoltrati succesivamente dai router) per sincronizzare la rete. La frequenza deve essere concordata a priori, inoltre c'è una deriva del clock abbastanza importante.

I beacon servono per tre funzioni fondamentali:

+ *Sincronizzazione*: tutti i dispositivi sincronizzano i loro clock con il coordinatore

+ *Organizzazione comunicazione*: gestire device che comunicano periodicamente vs. device asincroni

+ *Comunicazione indiretta*: il coordinatore mantiene una *lista di pending messages*. Nel beacon comunica quali dispositivi hanno messaggi in attesa. Il dispositivo che si riconosce nella lista sa che deve lasciare la radio *accesa* per ricevere. Se non deve né ascoltare né trasmettere, può *spegnere la radio* e risparmiare energia.

=== Struttura del Super-Frame

L’organizzazione che il coordinatore ha in mente (solo logica) per la gestione del tempo di comunicazione è definita *superframe* (sostanzialmente tutto
ciò che passa tra un beacon e l’altro).

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
  - *CAP* - Contention Access Period: slot condivisi, tutti i dispositivi competono usando CSMA/CA
  - *CFP* - Contention Free Period: contiene *GTS* (Guaranteed Time Slot), slot già allocati dal coordinatore a specifici dispositivi per comunicazioni con garanzie di latenza

  *Parte Inattiva*:
  - Nessun messaggio viene comunicato
  - Più è grande la parte inattiva, *più risparmio energia*
  - I dispositivi possono *spegnere la radio* completamente
]

=== Parametri del Super-Frame

La durata delle varie parti del super-frame viene comunicata attraverso il beacon:

#nota()[
  *Parametri fondamentali*:
]

/ *aBaseSuperFrameDuration* (*aBSD*): Unità di tempo fondamentale definita dallo standard IEEE 802.15.4
  - Corrisponde alla trasmissione di 960 simboli
  - Unità di base per calcolare tutte le altre durate

/ *Beacon Order* ($"BO"$): Determina l'intervallo tra beacon consecutivi
  $
    "Beacon Interval" = "aBSD" times 2^("BO")
  $
  - Valore: $0 <= "BO" <= 14$ ($2$ byte)
  - $"BO" = 0$ → beacon molto frequenti
  - $"BO" = 14$ → beacon molto distanziati

/ *Super-frame Order* ($"SO"$): Determina la durata della parte attiva
  $
    "Super-frame Duration" = "aBSD" times 2^("SO")
  $
  - Valore: $0 <= "SO" <= "BO" <= 14$
  - Deve essere $"SO" <= "BO"$ (la parte attiva non può superare l'intervallo tra beacon)

#attenzione()[
  Il *duty-cycle* della rete è determinato dal rapporto tra $"SO"$ e $"BO"$:
  $
    "duty-cycle" = (2^("SO")) / (2^("BO")) = 2^("SO" - "BO")
  $
]

#esempio()[
  - $"BO" = 8$, $"SO" = 6$ → duty-cycle $= 2^(-2) = 1/4 = 25%$
  - $"BO" = 10$, $"SO" = 5$ → duty-cycle $= 2^(-5) = 1/32 approx 3%$ (*risparmio energetico elevato*)
  - $"BO" = "SO"$ → duty-cycle $= 100%$ (nessuna parte inattiva)
]

=== Super-Frame Specification Field

Il campo *Super-frame Specification* nel beacon contiene tutte le informazioni sulla struttura del super-frame:

- *Beacon Order* (BO): determina *ogni quanto* aspettarsi un beacon
- *Super-frame Order* (SO): determina quanto è *grande* la parte attiva
- *Final CAP Slot*: indica in che punto *termina* il CAP (non può sforare nel CFP)
- *Reserved*: bit riservati per uso futuro
- *PAN Coordinator*: flag che indica se il dispositivo è un coordinatore PAN
- *Association Permit*: flag che indica se sono permesse nuove associazioni alla rete

#nota()[
  Il CAP è diviso in 16 slot temporali di uguale durata. La grandezza di ogni slot dipende dal numero totale di simboli nella parte attiva diviso 16.
]

#informalmente()[
  Il numero di simboli nella Super-frame Duration può variare da $"aBSD" times 2^0 = 960$ simboli a $"aBSD" times 2^14 = 15.728.640$ simboli.

  Questi simboli vengono divisi in 16 slot uguali nel CAP:
  $
    "Slot size" = ("aBSD" times 2^("SO")) / 16
  $
]

=== Guaranteed Time Slots (GTS)

#attenzione()[
  Il *GTS* è un *contratto* che il coordinatore ha fatto con specifici dispositivi, per garantire di comunicare *senza interferenze* in determinati slot temporali.
]

#nota()[
  La durata degli slot condivisi nel CAP dipende da quanti simboli ho diviso 16. I GTS nel CFP hanno durate che possono essere multiple degli slot base.
]

=== Accesso al CAP: Algoritmo CSMA/CA

Il livello fisico offre il servizio *CS* (#[*Carrier Sense*]): ascolta la portante e rileva se qualcuno sta trasmettendo.

#nota()[
  Il livello fisico mette a disposizione la *CCA* (#[*Clear Channel Assessment*]) per capire se il canale è *libero*. Ascolta per intervalli brevi (costa energia!).
]

=== Variabili di stato (per ogni dispositivo)

Ogni dispositivo mantiene internamente tre variabili per gestire l'accesso:

- *NB* (Number of Backoffs): iniziale $= 0$, max $= 4$ - Numero di backoff tentati (ottimista!)
- *BE* (Backoff Exponent): iniziale $= 3$, max $= 5$ - Periodo di attesa
- *CW* (Contention Window): iniziale $= 2$, max $= 2$ - CCA consecutive richieste

/ *NB* (#[*Number of Backoffs*]): Conta i tentativi di accesso falliti
  - Inizialmente è $0$ (siamo ottimisti!)
  - Massimo 4 tentativi
  - Se dopo 4 tentativi non va a buon fine, viene comunicato al livello superiore il *fallimento*

/ *BE* (#[*Backoff Exponent*]): Determina il numero di slot da attendere prima di riprovare
  - Periodo di backoff $= "random"[0, 2^("BE") - 1] times 20$ simboli
  - Aumenta ad ogni fallimento per *differenziare* i dispositivi (exponential backoff)
  - Serve per *disallinearsi*: tutti i dispositivi sono allineati alla ricezione del beacon

/ *CW* (#[*Contention Window*]): Numero di CCA *consecutive* con esito positivo necessarie prima di trasmettere
  - Devono essere 2 CCA consecutive con canale libero
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

  + *Ricezione beacon*: tutti i dispositivi si sincronizzano

  + *Random backoff*: attendo un numero casuale $[0, 2^("BE") - 1]$ slot
    - Con $"BE" = 3$ iniziale → attendo tra $[0, 7]$ slot
    - Nel nostro caso: 3 slot di backoff
    - La radio può essere *spenta* durante l'attesa (risparmio energia)

  + *Prima CCA*: ascolto il canale
    - Canale *libero* ✓ → $"CW" = 1$

  + *Seconda CCA*: riascolto nel slot successivo
    - Canale ancora *libero* ✓ → $"CW" = 0$

  + *Trasmissione*: posso finalmente trasmettere il pacchetto!
]

#esempio()[
  *Scenario con collisione*:

  Se durante una delle CCA il canale risulta *occupato*:

  + La *CW* viene *reimpostata* a $2$

  + *NB* viene incrementato: $"NB" = "NB" + 1$

  + *BE* viene incrementato: $"BE" = min("BE" + 1, 5)$
    - Aumenta l'intervallo di backoff per *differenziare* i dispositivi
    - Con $"BE" = 4$ → backoff casuale tra $[0, 15]$ slot

  + Si *riparte* dal random backoff con i nuovi parametri

  + Se $"NB" > 4$ → *fallimento*, comunicato al livello superiore
]

#nota()[
  Durante il backoff la radio può essere *spenta* per risparmiare energia. Si *perde* l'opportunità di trasmettere prima, ma in ZigBee *non ci sono requisiti di bassa latenza* o real-time.
]

#attenzione()[
  *Gestione del tempo limite del CAP*:

  Se mentre aspetto il random backoff o faccio le CCA il tempo *sconfina* oltre la fine del CAP (inizio del CFP), l'algoritmo:

  + *Blocca* il timer al valore corrente

  + Al *beacon successivo* riparte da quel valore salvato

  + Rimane in una sorta di *coda virtuale*

  Questo meccanismo *previene la starvation* del dispositivo: se ripartisse sempre da $"BE" = 3$ potrebbe non riuscire mai a trasmettere.
]

//aggiungere tempo di Turn around

//aggiungere tempo d Turn around
