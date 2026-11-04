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

La *Point Coordination Function (PCF)* è un meccanismo di *coordinamento centralizzato* opzionale definito nello standard IEEE 802.11 per gestire l'accesso al mezzo trasmissivo. A differenza del *Distributed Coordination Function* (DCF), che è basato su CSMA/CA e quindi distribuito, il PCF implementa un approccio centralizzato basato su polling.

Un *Basic Service Set* (BSS) identifica una cella o una rete wifi, composta da un AP e dalle stazioni associate. Il PCF opera all'interno di un BSS per coordinare l'accesso al canale tra le stazioni. Se si ha una rete *ad hoc* (senza AP), il PCF non è applicabile. In questo caso si utilizzano le funzioni di coordinamento distribuito (*DCF*) diventando un *Independent Basic Service Set* (IBSS). 

#align(center)[
  #image("../assets/Struttura-wifi.png", width: 60%)
]

== Architettura dei protocolli 

Possiamo suddividere l'architettura di Wifi in 4 moduli principali: 
- *Livello fisico* (PHY): definisce le caratteristiche fisiche della trasmissione (modulazione, frequenza, potenza)
- *Livello MAC*: gestisce l'accesso al mezzo, il formato dei frame, la sicurezza. Al suo interno troviamo sia il DCF che il PCF.

- *Logical Link Control* (LLC): incapsula i pacchetti di livello superiore (es. IP) all'interno dei frame 802.11. Permette di avere servizi di comunicazione affidabili e indipendenti dal tipo di rete sottostante.

=== Logical Link Control (LLC)

Il LLC fornisce un'*interfaccia uniforme per i protocolli* di livello superiore (es. IP, ARP) indipendentemente dal tipo di rete sottostante (Ethernet, WiFi, etc.). In particolare, i servizi offerti sono: 

- *Unacknowledged connectionless service*: il mittente invia un frame LLC senza aspettare conferma di ricezione. Questo è il servizio più semplice e veloce, ma non garantisce l'affidabilità.

- *Connection-mode service*: il mittente stabilisce una connessione logica con il destinatario prima di inviare i dati (canale punto-punto). Il ricevente conferma la ricezione di ogni frame, garantendo affidabilità ma con maggiore overhead.

- *Acknowledged connectionless service*: il mittente invia un frame LLC e aspetta un ACK dal destinatario, ma *non* stabilisce una *connessione* formale. Questo servizio è un compromesso tra i due precedenti, offrendo affidabilità senza la complessità di una connessione.

=== Livelli dei pacchetti

Il livello LLC incapsula i pacchetti di livello superiore (es. IP) all'interno dei frame 802.11.

#align(center)[
  #figure(
    cetz.canvas(length: 1cm, {
      import cetz.draw: *

      let fill-ip   = rgb("#D9EAF7")
      let fill-hdr  = rgb("#8DB8D8")
      let fill-phy  = rgb("#2E75B6")
      let h = 0.72

      let y-ip  = 3 * (h + 0.22)
      let y-llc = 2 * (h + 0.22)
      let y-mac = 1 * (h + 0.22)
      let y-phy = 0.0

      // x boundaries
      let x-phy0 = 0.0     // PHY header start
      let x-mac0 = 0.55    // PHY header end / MAC header start
      let x-llc0 = 1.25    // MAC header end / LLC header start
      let x-ip0  = 1.85    // LLC header end / IP & payload start
      let x-ip1  = 4.35    // IP / payload right edge & PHY middle right
      let x-phy1 = 5.05    // PHY trailer right

      let lx = 5.25        // arrow/line end
      let tx = 5.4         // label text start

      let arrow-stroke = black + 0.6pt
      let box-stroke   = black + 0.8pt

      // ── IP packet row ──────────────────────────────────────────────
      rect((x-ip0, y-ip), (x-ip1, y-ip + h), fill: fill-ip, stroke: box-stroke)
      content(((x-ip0 + x-ip1) / 2, y-ip + h / 2), text(size: 0.68em)[IP packet])
      line((x-ip1, y-ip + h / 2), (lx, y-ip + h / 2), stroke: arrow-stroke,
           mark: (end: ">", fill: black))
      content((tx, y-ip + h / 2), anchor: "west", text(size: 0.67em)[Network layer packet])

      // ── LLC sublayer frame ─────────────────────────────────────────
      rect((x-llc0, y-llc), (x-ip0, y-llc + h), fill: fill-hdr, stroke: box-stroke)
      content(((x-llc0 + x-ip0+0.1) / 2, y-llc + h / 2), text(size: 0.6em)[LLC\ header])
      rect((x-ip0, y-llc), (x-ip1, y-llc + h), fill: fill-ip, stroke: box-stroke)
      content(((x-ip0 + x-ip1) / 2, y-llc + h / 2), text(size: 0.68em)[Payload])
      line((x-ip1, y-llc + h / 2), (lx, y-llc + h / 2), stroke: arrow-stroke,
           mark: (end: ">", fill: black))
      content((tx, y-llc + h / 2), anchor: "west", text(size: 0.67em)[LLC sublayer frame])

      // ── MAC sublayer frame ─────────────────────────────────────────
      rect((x-mac0, y-mac), (x-llc0, y-mac + h), fill: fill-hdr, stroke: box-stroke)
      content(((x-mac0 + x-llc0) / 2, y-mac + h / 2), text(size: 0.6em)[MAC\ header])
      rect((x-llc0, y-mac), (x-ip1, y-mac + h), fill: fill-ip, stroke: box-stroke)
      content(((x-llc0 + x-ip1) / 2, y-mac + h / 2), text(size: 0.68em)[Payload])
      line((x-ip1, y-mac + h / 2), (lx, y-mac + h / 2), stroke: arrow-stroke,
           mark: (end: ">", fill: black))
      content((tx, y-mac + h / 2), anchor: "west", text(size: 0.67em)[MAC sublayer frame])

      // ── PHY layer frame ────────────────────────────────────────────
      rect((x-phy0, y-phy), (x-mac0, y-phy + h), fill: fill-phy, stroke: box-stroke)
      content(((x-phy0 + x-mac0+0.1) / 2, y-phy + h / 2),
              text(size: 0.58em, fill: white)[PHY\ header])
      rect((x-mac0, y-phy), (x-ip1, y-phy + h), fill: fill-ip, stroke: box-stroke)
      rect((x-ip1, y-phy), (x-phy1, y-phy + h), fill: fill-phy, stroke: box-stroke)
      content(((x-ip1 + x-phy1) / 2, y-phy + h / 2),
              text(size: 0.58em, fill: white)[PHY\ trailer])
      line((x-phy1, y-phy + h / 2), (lx+0.2, y-phy + h / 2), stroke: arrow-stroke,
           mark: (end: ">", fill: black))
      content((tx+0.2, y-phy + h / 2), anchor: "west", text(size: 0.67em)[PHY layer frame])
    }),
    caption: [Incapsulamento dei livelli: da IP (rete) a PHY (fisico).]
  )
]

== 802.11 Senza Infrastruttura

Rispetto alle reti cablate, in wifi, il canale è molto inaffidabile e condiviso tra più stazioni. Per questo motivo, è necessario un meccanismo di coordinamento per evitare collisioni e garantire l'accesso equo al mezzo. Il sotto-livello MAC di 802.11 offre due servizi:
- Servizio dati *asincrono*: non ci sono garanzie di dealy o QoS. Adatto a traffico best-effort come email, web, etc.

- Servizio dati *sincrono* (time-sensitive): Offre garanzie di delay. Disponibile solo in presenza di un coordinatore centrale (AP) che gestisce l'accesso al mezzo tramite polling. Adatto a traffico real-time come VoIP, streaming video, etc.

=== Distributed Coordination Function (DCF)

Il DCF è il meccanismo di accesso al mezzo predefinito in 802.11, basato su *CSMA/CA* (Carrier Sense Multiple Access with Collision Avoidance). In questo modello, ogni stazione ascolta il canale prima di trasmettere e utilizza un algoritmo di backoff per evitare collisioni.

#attenzione()[
  La procedura di accesso al mezzo è diversa da quella utilizzata in bluethooth anche se entrambi usano (CSMA/CA). Wi-Fi punta alle prestazioni e alla velocità, ZigBee punta al risparmio energetico estremo.
]

Vengono utilizzati diversi *Inter-frame Space* (IFS) per gestire le priorità di accesso al canale:

- *Slot Time*: *Unità base* di tempo (interna al dispositivo), non si tratta di una suddivisione temporale rigida, ma è usata per calcolare i tempi di backoff e IFS. Tiene conto di vari fattori come il tempo di propagazione, il tempo di commutazione tra trasmissione e ricezione, etc.

- *SIFS (Short Inter-frame Space)*: Intervallo di attesa piùà breve, usato per messaggi ad alta priorità come ACK. La durata dipende dalla tipologia di trasmettitore. 

- *DIFS (Distributed Inter-frame Space)*: Intervallo di attesa più lungo, utilizzato per messaggi a bassa priorità best effort. La durata è data da:
$
  "DIFS" = "SIFS" + 2 * "Slot Time"
$

- *PCF Inter-frame Space (PIFS)*: Intervallo di attesa intermedio, usato per traffico di tipo time-bounded. Si calcola come:
$
  "PIFS" = "SIFS" + 1 * "Slot Time"
$

=== Accesso al canale con DCF

Supponiamo che il *canale di trasmissione sia libero*:
+ Il sender inizia ad ascoltare il canale

+ Esegue un CCA (Clear Channel Assessment) per verificare che il canale sia effettivamente libero

+ Se il canale è libero lo ascolta per un *intervallo di tempo lungo  (DIFS)*. Se il canale rimane libero per tutta la durata del periodo, esegue un altro CCA

+ Se anche il secondo CCA conferma che il canale è libero, il sender può cominciare la trasmissione. Ci sono due possibili scenari per la conferma della trasmissione:
  - Se *non è necessario l'ACK*, una volta terminata la trasmissione, il sender ha finito e può considerare il frame inviato con successo (es. per traffico broadcast o multicast).

  - Se *è necessario l'ACK*, dopo aver trasmesso il frame, il sender attende un intervallo di *tempo SIFS*. Se riceve un ACK entro questo intervallo, considera la trasmissione avvenuta con successo. Se non riceve l'ACK, o se riceve un frame di controllo diverso, considera la trasmissione fallita e avvia la procedura di backoff.

#attenzione()[
  A differenza di ZigBee, in Wi-Fi, la *radio rimane accesa* durante l'attesa del DIFS e del backoff, eseguendo continuamente il carrier sensing. Questo permette di rilevare rapidamente quando il canale diventa occupato da un'altra stazione, ma comporta un consumo energetico maggiore (obbiettivo non primario).
]

Supponiamo che il *frame venga corrotto* prime della ricezione completa:

+ Il destinatario non riesce a decodificare correttamente il frame e quindi non invia un ACK.

+ Il sender attende un intervallo di tempo *SIFS*. Siccome non riceve ACK assume che la trasmissione non sia andata a buon fine, di conseguenza ritrasmette lo stesso frame subito. 

#align(center)[
  #image("../assets/CMDCA-WIFI.png", width: 60%)
]

#nota()[
  Siccome il trasmettitore ha ottenuto l'*accesso esclusivo al canale*, aspetta un intervallo di tempo SIFS più breve rispetto al DIFS, garantendo così una risposta rapida e affidabile.


  Il canale viene rilasciato una volta che la trasmissione viene completata. Da standard $802.11$ è previsto un massimo numero di tentativi 
]

Supponiamo che il *canale sia occupato* da un'altra stazione:

+ Il sender può rilevare che il canale è occupato durante due momenti: 
  - CCA 
  - Durante il periodo di attesa DIFS

  In entrambi i casi, se il sender rileva che il canale è occupato, *rimane in ascolto* fino al termine della trasmissione corrente

+ Quando il canale è di nuovo libero, il sender esegue un CCA. Inoltre, rimane in ascolto per un periodo DIFS, PIFS o SIFS, in base alla *priorità del frame* che vuole trasmettere. Se durante questo periodo rileva che il canale è libero, esegue un'ulteriore CCA. 

+ Se l'ultima CCA conferma che il canale è libero, il sender *entra in contesa* con tutti gli altri dispositivi che stavano aspettando. Durante la contesa, il sender aspetta un numero casuale di _slot time_ (*Binary Exponential Backoff*) prima di tentare di trasmettere. Durante questo periodo, il sender continua a fare *carrier sensing*. 


#align(center)[
  #image("../assets/CMDCA-WIFI-2.png", width: 65%)
]  

Se durante il *perido di contesa* il canale *diventa occupato* ci sono due opzioni: 
  + Il sender al prossimo ciclo riparte dalla contesa con un intervallo più ampio. Si trata di una soluzione *non equa* nei confronti delle stazioni che hanno _perso_ la contensa (rischio di starvation)
  + Il sender blocca il timer al valore in cui è stato rilevato il canale occupato. Al ciclo successivo riparte da quel valore, garantendo così una maggiore equità tra le stazioni in contesa (soluzione più comune)
