#import "../template.typ": *

== LTE handover

#attenzione()[
  In LTE esiste solo *hard-handover*
]

Non esiste un nodo centralizzato tra eNodeB. Ogni UE è collegato a una solo base station per volta. In base al bearer in cui l'UE si trova può usare tipi di handover diversi:

- *Seamless handover*: ammette la perdita di traffico ma garantisce una bassa latenza. Usato ad esempio per traffico _voip_. Caratteristiche:
  - Minore latenza
  - Ammette ritrasmissioni

- *Lossless handover*: Garantisce che i pacchetti *non* vengano persi, se viene perso un messaggio *deve essere ritrasmesso*. A livello di handover non possiamo fare riferimento a nessun protocollo di radio link controller (livello 2). La perdita verrà gestita a livello $4$. Un esempio di traffico è _HTTP/FTP_

=== LTE lossless handover

Supponiamo che un UE, a cui sta venendo inviato un *flusso di download* (da parte del S-GW), si sposti da un'eNodeB a un'altra. Il Service Gateway continuerà a mandare pacchetti alla vecchia posizione del dispositivo.

Tramite l'`interfaccia X2` viene tenuto un buffer dentro la base station precedente ($"eNB" 1$), in modo da non perdere i pacchetti in download.

Una volta che l'handover è completato, la base station precedente manda i pacchetti bufferizzati alla nuova base station $"eNB" 2$. I messaggi verranno mandati successivamente al dispositivo. In questo modo *non c'è perdita* di pacchetti, il download può continuare senza interruzioni.

#nota()[
  L'handover viene effettuato tramite un *coordinamento tra le due base station (partenza-arrivo)*, sfruttando il collegamento tra di esse.
]

=== Handover S1 vs Handover X2

Prendiamo in considerazione il sequence diagram di una procedura di handover tramite l'`interfaccia S1`. In questa variante verrà *coinvolta la rete core*.

#figure(
  align(center)[
    #cetz.canvas(length: 0.9cm, {
      import cetz.draw: *

      let x-ue = 0.8
      let x-src-enb = 4.0
      let x-dst-enb = 7.2
      let x-src-mme = 10.4
      let x-dst-mme = 13.6

      let y-bottom = 0.6
      let y-top = 11.2
      let box-h = 0.7

      let lifeline-color = 0.8pt + gray
      let head-fill = luma(225)
      let band-fill = rgb("#9FD7E8")

      // Header + lifeline per ogni attore
      let actor(x, w, label) = {
        rect((x - w / 2, y-top), (x + w / 2, y-top + box-h), fill: head-fill, stroke: black)
        content((x, y-top + box-h / 2), text(size: 8pt, label))
        line((x, y-bottom), (x, y-top), stroke: lifeline-color)
      }

      actor(x-ue, 2.1, "UE")
      actor(x-src-enb, 3.1, "Source eNodeB")
      actor(x-dst-enb, 3.1, "Destination eNodeB")
      actor(x-src-mme, 2.8, "Source MME")
      actor(x-dst-mme, 2.8, "Destination MME")

      // Evidenziazione gruppi RAN (rosso) e core (blu), come nell'immagine
      rect(
        (x-src-enb - 1.7, y-top - 0.15),
        (x-dst-enb + 1.7, y-top + box-h + 0.25),
        stroke: red + 1.6pt,
      )
      rect(
        (x-src-mme - 1.5, y-top - 0.15),
        (x-dst-mme + 1.5, y-top + box-h + 0.25),
        stroke: blue + 1.6pt,
      )

      let msg(y, from, to, label, dashed: false) = {
        let s = if dashed { (paint: black, thickness: 1pt, dash: "dashed") } else { 1pt + black }
        line((from, y), (to, y), stroke: s, mark: (end: ">", fill: black))
        content((calc.min(from, to) + 0.1, y + 0.12), text(size: 8.4pt, label), anchor: "west")
      }

      // Banda 1: decisione iniziale (come nell'immagine)
      rect((x-ue, 9.3), (x-src-mme + 0.4, 10.1), fill: band-fill, stroke: none)
      content(
        (5.0, 9.7),
        text(size: 8.5pt, "1. Decision to trigger a relocation via S1"),
        anchor: "west",
      )

      // Banda 2: setup risorse
      rect((x-src-enb + 1.0, 6.6), (x-src-mme - 1.0, 7.4), fill: band-fill, stroke: none)
      content((7.0, 7.0), text(size: 9pt, "5. Resource setup"))

      // Messaggi della procedura S1
      msg(8.75, x-src-enb, x-src-mme, "2. Handover Required")
      msg(8.10, x-src-mme, x-dst-mme, "3. Forward Relocation Request")
      msg(7.45, x-dst-mme, x-dst-enb, "4. Handover Request")
      msg(6.35, x-dst-enb, x-dst-mme, "6. Handover Request ACK")
      msg(5.70, x-dst-mme, x-src-mme, "7. Forward Relocation Response")
      msg(5.05, x-src-mme, x-src-enb, "8. Handover command")
      msg(4.40, x-src-enb, x-ue, "9. Handover command")
      msg(3.75, x-src-enb, x-src-mme, "10. eNodeB Status Transfer")
      msg(3.25, x-src-enb, x-dst-enb, "10b. Only for direct forwarding of data", dashed: true)
      msg(2.80, x-dst-mme, x-dst-enb, "11. MME Status Transfer")
      msg(2.25, x-ue, x-dst-enb, "12. Handover Confirm")
      msg(1.70, x-dst-enb, x-dst-mme, "13. Handover Notify")
      msg(1.20, x-dst-mme, x-src-mme, "14a. Forward Relocation Complete")
      msg(0.85, x-src-mme, x-dst-mme, "14b. Forward Relocation Complete ACK")
      msg(0.45, x-ue, x-dst-mme, "15. Tracking Area Update Request")
    })
  ],
  caption: [Schema della procedura di handover LTE su `interfaccia S1`],
)

Il source MME (modulo che gestisce la mobilità) gestisce l'UE corrente. L'assunzione è che sia già stato deciso di passare la gestione dell'UE da `eNodeB sorgente` a `eNodeB target`:

2. Da $mr("SRC")$ eNB a $mr("SRC")$ MME, viene fatta una `handover-request`. La base station che sta gestendo il dispositivo chiede all'MME di riallocarlo.

+ $mr("SRC")$ MME inoltra la richiesta di handover all' $mb("DST")$ MME. La destinazione è l'MME che avrà in carico il traffico di controllo dell'UE al termine della procedura di handover.

+ $mb("DST")$ MME manda la `handover-request` al $mb("DST")$ eNB, ovvero al eNodeB che avrà in gestione il dispositivo al termine della richiesta.
  #nota()[
    Tutte le $4$ entità in gioco, sono ora state avvisate della procedura di handover. Inoltre, si tiene traccia dei bearer attivi (con i QoS relativi). Essi andranno ricreati alla fine dell'handover.
  ]

+ $mb("DST")$ eNB prepara le risorse a livello di resource control, per ospitare il dispositivo (UE)

+ $mb("DST")$ eNB invia una `handover-request ACK` a $mb("DST")$ MME per confermare l'allocazione delle risorse. Tale messaggio viaggia sulla rete *back-bone* dell'operatore (non viaggia via radio ma tramite protocollo scp).

+ $mb("DST")$ MME sa che è tutto pronto. $mb("DST")$ MME manda una `forward-handover-response` al $mr("SRC")$ MME. Il comando di handover può essere ora inviato al dispositivo coinvolto.

+ $mr("SRC")$ MME manda un messaggio a $mr("SRC")$ eNB. Il messaggio è di `handover command`.

+ Il comando di handover viene inoltrato da $mr("SRC")$ eNB all'UE finale.

+ Una volta che l'UE è stato avvisato, può iniziare il cambiamento di stato. $mr("SRC")$ MME viene notificato del cambiamento di stato `status transfer` da parte del $mr("SRC")$ eNB.

  #nota()[
    La freccia tratteggiata serve in caso di *lossless handover*, in questo caso l' $mr("SRC")$ eNB deve trasferire anche i pacchetti bufferizzati al $mb("DST")$ eNB per evitare perdite di pacchetti.
  ]

+ Viene inviato un `MME status-transfer` da $mb("DST")$ MME a $mr("SRC")$ eNB.

+ L'`UE` invia una `handover confirm` a $mb("DST")$ eNB per confermare che è arrivato alla nuova base station.

+ Una volta fatto l'handover $mb("DST")$ eNB avvisa $mb("DST")$ MME dell'avvenuto handover con un messaggio di `handover-notify`.

+ $mb("DST")$ MME invia al vecchio $mr("SRC")$ MME una conferma dell'avvenuta procedura di handover. Il $mr("SRC")$ MME risponderà con un messaggio di ACK.

+ L'`UE` chiede un `tracking-area-update`. Il messaggio è diretto all'`DST MME` (in realtà passa da $mr("SRC")$ eNB). Questo messaggio serve per *notificare alla rete core* che il dispositivo è ora sotto la *gestione di un nuovo MME*. In questo modo, la rete core, sa che deve mandare i pacchetti al nuovo MME e non al vecchio.

+ Una volta che la procedura è completata $mr("SRC")$ MME (vecchio MME) manda un messaggio al $mr("SRC")$ eNB (stazione che aveva in gestione il dispositivo) per *rilasciare le risorse* `release-resource`

#nota()[
  Siccome la procedura di handover è hard, l'UE *non* può mantenere una connessione simultanea con entrambe le base station. La risposta dell'handover viene data sulla nuova destinazione.
]

#attenzione()[
  La parte di gestione e preparazione alla procedura di handover è *affidata interamente alla rete* e non all'UE.

  Prima di contattare il dispositivo UE per notificare l'handover, bisogna essere sicuri che, una volta iniziata la procedura di hadover, vada a buon fine. Inoltre, le risorse necessarie devono essere già pronte, in modo da non avere interruzioni del servizio (fino a quando non viene ricevuto un `handover-request-ACK`, la procedura di handover non parte)
]

=== Handover tramite X2

La procedura di handover, in questo caso, viene gestita tra le due base station e solo alla fine viene notificata alla rete core. 

#attenzione()[
  Condizioni *necessarie* per usare questo tipo di handover:
  - Le due eNodeB devono essere situate nella *stessa tracking area* (altrimenti non possono comunicare tra di loro)
  - Interfaccia *X2 attiva*
]




#figure(
  align(center)[
    #cetz.canvas(length: 0.9cm, {
      import cetz.draw: *

      let x-ue = 0.8
      let x-src-enb = 3.8
      let x-dst-enb = 7.0
      let x-mme = 10.2

      let y-bottom = 0.5
      let y-top = 12.0
      let box-h = 0.7

      let lifeline-color = 0.8pt + gray
      let head-fill = luma(225)
      let band-fill = rgb("#D0E8F0")

      // Header + lifeline per ogni attore
      let actor(x, w, label) = {
        rect((x - w / 2, y-top), (x + w / 2, y-top + box-h), fill: head-fill, stroke: black)
        content((x, y-top + box-h / 2), text(size: 8pt, label))
        line((x, y-bottom), (x, y-top), stroke: lifeline-color)
      }

      actor(x-ue, 1.5, "UE")
      actor(x-src-enb, 3.2, "Source LTE eNodeB")
      actor(x-dst-enb, 3.2, "Target LTE eNodeB")
      actor(x-mme, 2.5, "MME/S-GW")

      let msg(y, from, to, label, dashed: false) = {
        let s = if dashed { (paint: black, thickness: 1pt, dash: "dashed") } else { 1pt + black }
        line((from, y), (to, y), stroke: s, mark: (end: ">", fill: black))
        content((calc.min(from, to) + 0.15, y + 0.12), text(size: 7.5pt, label), anchor: "west")
      }

      // Banda per area restrictions  
      rect((x-src-enb - 1.6, 11.0), (x-dst-enb + 1.6, 11.5), fill: band-fill, stroke: none)
      content((x-src-enb + 0.8, 11.25), text(size: 7.5pt, "1. Provision of area restrictions"))

      // Banda per measurement control
      rect((x-src-enb - 1.6, 10.3), (x-dst-enb + 1.6, 10.8), fill: band-fill, stroke: none)
      content((x-src-enb + 0.8, 10.55), text(size: 7.5pt, "2. Measurement control"))

      // Banda per handover decision
      rect((x-src-enb - 1.4, 9.6), (x-src-enb + 1.4, 10.1), fill: band-fill, stroke: none)
      content((x-src-enb + 0.1, 9.85), text(size: 7.5pt, "3. Handover decision"))

      // Banda per resource setup
      rect((x-dst-enb - 1.4, 8.2), (x-dst-enb + 1.4, 8.7), fill: band-fill, stroke: none)
      content((x-dst-enb - 0.6, 8.45), text(size: 7.5pt, "5. Resource setup"))

      // Messaggi della procedura X2
      msg(9.3, x-src-enb, x-dst-enb, "4. Handover Request")
      msg(8.0, x-dst-enb, x-src-enb, "6. Handover Request ACK")

      // Handover Command
      msg(7.3, x-src-enb, x-ue, "7. Handover Command")

      // Rettangolo Data Forwarding sulla sinistra
      content((x-ue - 1.8, 6.0), text(size: 7.5pt, [
        #text(fill: blue, "Data\nforwarding\nover X2\ninterface")
      ]))

      // Status Transfer tra eNodeB (tratteggiato)
      msg(6.0, x-src-enb, x-dst-enb, "8. Status Transfer", dashed: true)

      // Handover Command
      content((2.2, 4.8), text(size: 7.5pt, "9. Handover Complete"), anchor: "west")
      line((x-ue, 4.7), (x-dst-enb, 4.7), stroke: 1pt + black, mark: (end: ">", fill: black))

      // Path Switch Request
      msg(3.9, x-dst-enb, x-mme, "10. Path Switch Request")

      // Path Switch Request ACK
      msg(3.2, x-mme, x-dst-enb, "11. Path Switch Request ACK")

      // Release Resource
      msg(2.5, x-dst-enb, x-src-enb, "12. Release Resource")

      // Linea tratteggiata verticale per separare Handover Command da 7 Handover Request
      line((x-src-enb - 2.0, 7.8), (x-src-enb - 2.0, 5.5), stroke: (paint: gray, thickness: 1pt, dash: "dashed"))
      content((x-src-enb - 2.0, 6.6), text(size: 7pt, [7]), anchor: "east", dx: -0.15)
      content((x-src-enb - 2.0, 5.3), text(size: 7pt, "Handover Command"), anchor: "north")
    })
  ],
  caption: [Schema della procedura di handover LTE su `interfaccia X2`],
)

Procedura (supponendo di aver scelto di fare handover):
+ L'$mb("SRC")$ `eNB` dialoga direttamente con la futura $mr("DST")$ `eNB`. *Non viene contatta la rete core*. Una volta che le due base station si sono accordate, la procedura di handover può partire.

4. L'$mb("SRC")$ `eNB` invia una `handover request` a $mr("DST")$ `eNB` per chiedere di ospitare il dispositivo. Il messaggio contiene anche i bearer attivi e i relativi QoS.

6. Una volta che $mr("DST")$ `eNB` ha allocato le risorse necessarie per ospitare il dispositivo, invia una `handover request ACK` a $mb("SRC")$ `eNB` per confermare che è tutto pronto. A questo punto, la procedura di handover può essere notificata al dispositivo coinvolto.

+ Viene notificata al dispositivo UE la procedura di handover tramite un `handover command` da parte del $mb("SRC")$ `eNB`.

+ La freccia trattegiata indica il trasferimento di pacchetti bufferizzati (nel caso di lossless handover). 

+ L'UE manda un messaggio alla  $mr("DST")$ `eNB` di `hand over complete`. In questo modo il dispositivo conferma di essere arrivato alla nuova base station.

+ Solamente in questo punto viene *contattata la rete core* per la prima volta. Essa viene informata dalla $mr("DST")$ `eNB` dello spostamento del dispositivo tramite un `path switch request`.

+ La rete core aggiorna le tabelle di routing per mandare i pacchetti al nuovo MME e non al vecchio, confermando con un messaggio di `path switch request ACK`.

#nota()[
  La rete core è coinvolta solo per cambiare i percorsi.

  Anche in questo caso la *richiesta di handover parte dalla rete cellulare* (eNodeB). L'UE non può assolutamente far partire la richiesta ma si attiene alle direttive.
]

#part("5G")

= 5G

La rete 5G è stata progettata per supportare una grande varietà di casi d'uso, con requisiti molto diversi tra di loro.

I casi d'uso possono essere divisi in $3$ macro categorie, in base ai requisiti: 
- *eMBB* (enhanced Mobile Broadband)
  - Servizi orientati alle persone
  - Elevata Banda
  - Ad esempio _streaming_

- *uRLLC* (ultra Reliable Low Latency Communication)
  - Servizi orientati alle industrie
  - La banda occupata è meno importante, ma è fondamentale garantire una bassa latenza e un'elevata affidabilità
  - Ad esempio il controllo remoto e la guida autonoma

- *mMTC* (massive Machine Type Communication)
  - Alta densità di connessioni
  - Smart Cities / Smart Agriculture

Le principali direzioni di sviluppo di 5G sono:
- Maggiore efficienza spettrale e QUAM più alte
- Riuso spaziale (celle più dense)
- *Softwarizzazione* della rete. Abbiamo una convergenza tra ICT e IT.

== Software Defined Network (SDN)

Fino ad ora abbiamo visto che la rete è composta da dispositivi in cui la parte di controllo e la parte dati sono *accoppiate*. Ad esempio, sui dispositivi di rete (router, switch) è presente sia la parte di controllo (algoritmi di controllo, scambio dati con altri dispositivi), sia la parte di forwarding (scambio di pacchetti).

L'idea di *SDN* è separare queste due parti, *isolando la parte di controllo* (control plane) in un layer a parte. Tale layer prende il nome di *controller* e si occupa di gestire la rete. Esso ha una visione globale della rete e può prendere decisioni in maniera centralizzata.

La parte di data plane rimane sui dispositivi di rete, ma è *controllata* dal controller (o da più controller)

#figure(
  align(center)[
    #cetz.canvas(length: 0.7cm, {
      import cetz.draw: *

      // Coordinate layers
      let y-app = 8.5
      let y-control = 5.5
      let y-data = 1.5

      // Larghezze
      let app-w = 5.0
      let controller-w = 3.5

      // App Layer
      content((0, y-app + 1.2), text(size: 10pt, weight: "bold", "App Layer"), anchor: "west")
      rect((-0.5, y-app - 0.5), (app-w, y-app + 0.5), stroke: black + 1pt, radius: 0.3, fill: white)
      content((app-w / 2 - 0.25, y-app), text(size: 9pt, "Network application"))

      // Linea separatrice tratteggiata sotto app layer
      line((-1.5, y-app - 1.3), (9, y-app - 1.3), stroke: (paint: gray, thickness: 0.8pt, dash: "dotted"))

      // Control Layer
      content((-1.9, y-control + 1.2), text(size: 10pt, weight: "bold", "Control Layer"), anchor: "west")
      
      // SDN Controller
      rect((-0.5, y-control - 0.5), (controller-w, y-control + 0.5), stroke: black + 1pt, radius: 0.3, fill: red.lighten(80%))
      content((controller-w / 2 - 0.25, y-control), text(size: 9pt, "SDN Controller/s"))

      // Icona controller piccola a destra
      rect((controller-w + 0.5, y-control - 0.3), (controller-w + 1.3, y-control + 0.3), stroke: black + 1pt, radius: 0.2, fill: red.lighten(80%))

      // Linea separatrice tratteggiata sotto control layer
      line((-1.5, y-control - 1.3), (9, y-control - 1.3), stroke: (paint: gray, thickness: 0.8pt, dash: "dotted"))

      // Data Layer
      content((-2, y-data + 1.2), text(size: 10pt, weight: "bold", "Data Layer"), anchor: "west")

      // Funzione per disegnare uno switch
      let draw-switch(x, y, w: 1.0, h: 0.6) = {
        // Corpo dello switch (prospettiva isometrica semplificata)
        let pts = ((x - w/2, y), (x + w/2, y), (x + w/2 + 0.15, y + h), (x - w/2 + 0.15, y + h))
        line(..pts, close: true, fill: blue.lighten(60%), stroke: black + 0.8pt)
        // Linee interne per dettaglio
        line((x - w/4, y), (x - w/4 + 0.15, y + h), stroke: black + 0.5pt)
        line((x + w/4, y), (x + w/4 + 0.15, y + h), stroke: black + 0.5pt)
      }

      // Posizioni degli switch nel data layer
      let switches = (
        (0.5, y-data),
        (2.2, y-data - 0.3),
        (3.9, y-data + 0.2),
        (2.2, y-data + 0.7),
        (5.6, y-data - 0.1),
        (5.6, y-data + 0.8),
      )

      // Disegna gli switch
      for pos in switches {
        draw-switch(pos.at(0), pos.at(1))
      }

      // Collegamenti tra switch (linee blu)
      let connections = (
        (switches.at(0), switches.at(1)),
        (switches.at(0), switches.at(3)),
        (switches.at(1), switches.at(2)),
        (switches.at(1), switches.at(3)),
        (switches.at(2), switches.at(4)),
        (switches.at(2), switches.at(5)),
        (switches.at(3), switches.at(4)),
        (switches.at(4), switches.at(5)),
      )

      for conn in connections {
        line(conn.at(0), conn.at(1), stroke: blue + 1pt)
      }

      // Frecce da App a Controller (nera continua)
      line((app-w / 2 - 0.25, y-app - 0.5), (controller-w / 2 - 0.25, y-control + 0.5), 
           stroke: black + 1pt, mark: (end: ">", fill: black))

      // Frecce da Controller agli switch (rosse tratteggiate)
      for pos in switches.slice(0, 4) {
        line((controller-w / 2 - 0.25, y-control - 0.5), pos, 
             stroke: (paint: red, thickness: 1pt, dash: "dashed"), mark: (end: ">", fill: red))
      }

      // Legenda in alto a destra
      let legend-x = 6.5
      let legend-y = y-app + 0.8
      
      content((legend-x, legend-y), text(size: 8pt, "Configurazione"), anchor: "west")
      line((legend-x - 0.8, legend-y), (legend-x - 0.2, legend-y), stroke: black + 1pt)
      
      content((legend-x, legend-y - 0.5), text(size: 8pt, "Flusso Controllo"), anchor: "west")
      line((legend-x - 0.8, legend-y - 0.5), (legend-x - 0.2, legend-y - 0.5), 
           stroke: (paint: red, thickness: 1pt, dash: "dashed"))
      
      content((legend-x, legend-y - 1.0), text(size: 8pt, "Flusso Dati"), anchor: "west")
      line((legend-x - 0.8, legend-y - 1.0), (legend-x - 0.2, legend-y - 1.0), stroke: blue + 1pt)

      // Etichette laterali
      content((7.2, y-app), text(size: 8pt, fill: gray, []), anchor: "west")
      
      content((5.5, y-control), text(size: 8pt, fill: red, [Algoritmi di\ controllo]), anchor: "west")
    })
  ],
  caption: [Architettura Software Defined Networking (SDN)],
)

#nota()[
  Tramite il software (comportamento del controller) andiamo a definire il comportamento della rete. 
]

=== Evoluzioni di SDN


SDN nel corso degli anni si è evoluta:

+ *Struttura tradizionale*: Control Plane e Data Plane sono situate nello stesso dispositivo.

+ *Prima separazione*: Il control plane è separato dal data plane, ma quest'ultimo è ancora fisso e non programmabile. Il controller può solo configurare il control plane.

+ *Seconda separazione*: Il control plane è completamente separato dal data plane e diventa programmabile. Il data plane può essere gestito in modo più flessibile e dinamico (creazione di header custom, attraverso parser ad hoc).

#esempio()[
  Potrebbe essere creato un modello di machine learning per classificare il traffico in base al tipo. Tale modello potrebbe essere addestrato offline e successivamente inserito all'interno dello switch per fare inferenza in linea, modificando le decisioni di forwarding. 
]

I $mg("vantaggi")$ offerti dalle SDN sono: 
- Flessibilità nella gestione della rete
- La visione centralizzata permette un'ottimizzazione del routing
- Testing e configurazione di nuovi protocolli di rete più semplice e veloce

Le $mr("sfide")$ sono:
- *Controller punto debole dell'architettura*. In caso di guasto del controller, la rete potrebbe non funzionare correttamente. Inoltre, il controller *deve essere* progettato per essere *scalabile* e *resiliente*.
- Reazione ai cambiamenti della rete in maniera real-time
- Ottimizzazione del numero di regole:
  - Gestione ottimizzata delle tabelle di forwarding
  - Gestione e garanzia dell'*isolamento di reti*. Il traffico di reti diverse deve essere separato (come se fossero delle VLAN diverse).
- *Sicurezza*: Prendere il possesso del controller permette di controllare la rete.

== Network Function Virtualization (NFV)

Nelle reti viste fino ad adesso i vari moduli sono _predefiniti_, adempiono agli scopi per cui sono stati costruiti. Tuttavia, questo richiede di avere molti dispositivi hardware specifici (investimento non sempre ripagato).

Ad oggi, esistono i Cloud as a Service. Basta pagare un abbonamento mensile per usufruire di certi servizi, non richiede hardware specifico. 

L'idea è avere una separazione tra *hardware* (che esegue la funzionalità) ed il *software* (che implementa le funzionalità di rete). Dal dispositivo di rete viene estratto il firmware, andando a creare una funzionalità di rete virtualizzata. 

Tali funzionalità virtualizzate gireranno su *hardware standard*. In questo modo potremmo andare ad istanziare più servizi dedicati senza bisogno di avere dispositivi hardware ad hoc.

L'adozione di funzioni di rete virtualizzate, permette di aumentare la *scalabilità* e la *flessibilità*:

- *Scalabilità verticale*: permette di aggiungere o rimuovere risorse fisiche o virtuali a una singola istanza VNF. Andiamo a potenziare un certo nodo

- *Scalabilità orizzontale*: *repliche dello stesso servizio* su macchine diverse. Se il traffico su una macchina è intenso, possiamo creare un'altra istanza dello stesso servizio, andando a bilanciare il traffico.

#nota()[
  Il problema è che nella rete cellulare *non* tutte le funzionalità di rete possono essere virtualizzate. Ad esempio, la parte radio (RAN) è molto difficile da virtualizzare, a causa dei requisiti di latenza e banda. Tuttavia, molte funzionalità della rete core possono essere virtualizzate senza problemi.
]

La rete cellulare adotta un *NFV ibrida*, in cui alcune funzionalità sono virtualizzate (ad esempio MME, S-GW) mentre altre sono ancora basate su hardware dedicato (ad esempio eNodeB).

Un certo servizio di rete può essere realizzato tramite più funzioni di rete virtualizzate (VNF). La *Service Function Chain* (SFC) è una catena di VNF che realizza un certo servizio di rete. Per gestire tali catene, è necessario un modulo di orchestrazione che si occupa di gestire le VNF e le loro interconnessioni. Tale modulo prende il nome di *NFV orchestrator*. Esso è responsabile di:

- Identificare quali template (VNF) servono alla comunicazione

- I template vengono istanziati in base ai requisiti imposti dal data-plane. _Ad esempio_, se un certo servizio richiede una latenza di $10 "ms"$, l'orchestratore deve istanziare il servizio su un nodo che garantisce quella latenza.

- Identificare il *miglior placement* per le funzionalità che vogliamo realizzare. Ovvero dove e come istanziare i vari servizi. L'orchestratore deve essere a conoscenza dello *stato fisico delle risorse* distribuite geograficamente sulla rete.
  #nota()[
    I vari servizi possono essere condivisi tra più catene o essere addirittura istanziati sullo stesso nodo.
  ]

=== NFV Architettura

#figure(
  align(center)[
    #cetz.canvas(length: 0.8cm, {
      import cetz.draw: *

      // Colori
      let color-bss = rgb("#87CEEB")
      let color-mano = rgb("#FFB6C1")
      let color-vnf = rgb("#98D8C8")
      let color-infra = rgb("#F7DC6F")
      let color-virtual = rgb("#AED6F1")
      let color-hardware = rgb("#D5DBDB")

      // BSS/OSS in alto
      rect((5, 11), (11, 12.2), stroke: black + 1pt, fill: color-bss, radius: 0.2)
      content((8, 11.95), text(size: 8pt, weight: "bold", [Business Support System (BSS)]))
      content((8, 11.4), text(size: 9pt, [Operational Support System (OSS)]))


      // NFV MANO (destra)
      rect((12, 3), (16.5, 10.5), stroke: red + 1.5pt, fill: color-mano.lighten(60%), radius: 0.2)
      content((14.25, 10.1), text(size: 9pt, weight: "bold", "NFV MANO"), anchor: "center")

      // Orchestrator
      rect((12.5, 8.8), (16, 9.8), stroke: black + 1pt, fill: color-mano, radius: 0.15)
      content((14.25, 9.3), text(size: 7.5pt, weight: "bold", "Orchestrator"))

      // VNF Manager (VNFM)
      rect((12.5, 6.5), (16, 8.3), stroke: black + 1pt, fill: color-vnf.lighten(40%), radius: 0.15)
      content((14.25, 7.85), text(size: 7.5pt, weight: "bold", "VNF Manager"))
      content((14.25, 7.55), text(size: 6.5pt, "(VNFM)"))
      content((14.25, 7.1), text(size: 6pt, [VNF1]))
      content((14.25, 6.8), text(size: 6pt, [VNF2]))

      // Virtual Infrastructure Manager (VIM)
      rect((12.5, 3.5), (16, 6), stroke: black + 1pt, fill: color-infra.lighten(30%), radius: 0.15)
      content((14.25, 5.5), text(size: 7.5pt, weight: "bold", [Virtual]))
      content((14.25, 5.2), text(size: 7.5pt, weight: "bold", [Infrastructure]))
      content((14.25, 4.9), text(size: 7.5pt, weight: "bold", [Manager]))
      content((14.25, 4.5), text(size: 6.5pt, "(VIM)"))

      // Virtual Network Functions (VNFs) - sinistra in alto
      rect((0, 7.5), (10.5, 10.5), stroke: blue + 1.5pt, fill: white, radius: 0.2)
      content((5.25, 10.1), text(size: 8pt, weight: "bold", [Virtual Network Functions (VNFs)]))

      // EMS boxes dentro VNFs
      let ems-y = 9.3
      for i in range(3) {
        let x-start = 0.8 + i * 3.2
        rect((x-start, ems-y - 0.7), (x-start + 2.8, ems-y + 0.3), stroke: black + 0.8pt, fill: color-vnf, radius: 0.1)
        content((x-start + 1.4, ems-y + 0.05), text(size: 7pt, weight: "bold", [EMS #(i + 1)]))
        content((x-start + 1.4, ems-y - 0.35), text(size: 6pt, [VNF #(i + 1)]))
      }

      // Network Function Virtualization Infrastructure
      rect((0, 0.5), (10.5, 7), stroke: green + 1.5pt, fill: white, radius: 0.2)
      content((5.25, 6.6), text(size: 8pt, weight: "bold", [Network Function Virtualization Infrastructure]))

      // Risorse Virtualizzate
      rect((0.5, 4.8), (10, 6.2), stroke: black + 1pt, fill: color-virtual, radius: 0.15)
      content((5.25, 5.9), text(size: 7.5pt, weight: "bold", [Risorse Virtualizzate]))
      
      let virt-items = ([Virtual\ CPUs], [Virtual\ Storage], [Virtual\ Network])
      for (i, item) in virt-items.enumerate() {
        let x-pos = 1.5 + i * 3.0
        rect((x-pos - 0.7, 5.0), (x-pos + 0.7, 5.6), stroke: black + 0.6pt, fill: white, radius: 0.1)
        content((x-pos, 5.3), text(size: 6pt, item), anchor: "center")
      }

      // Strato Virtualizzazione
      rect((0.5, 3.9), (10, 4.6), stroke: black + 1pt, fill: color-infra, radius: 0.15)
      content((5.25, 4.25), text(size: 7pt, weight: "bold", [Strato Virtualizzazione]))

      // Risorse Hardware
      rect((0.5, 1.0), (10, 3.6), stroke: black + 1pt, fill: color-hardware, radius: 0.15)
      content((5.25, 3.3), text(size: 7.5pt, weight: "bold", [Risorse Hardware]))
      
      let hw-items = ([CPUs], [Storage], [Network])
      for (i, item) in hw-items.enumerate() {
        let x-pos = 1.5 + i * 3.0
        rect((x-pos - 0.7, 1.4), (x-pos + 0.7, 2.8), stroke: black + 0.6pt, fill: white, radius: 0.1)
        content((x-pos, 2.1), text(size: 8pt, item), anchor: "center")
        // Icone stilizzate
      }

      // Connessioni e frecce
      // BSS to Orchestrator
      line((11, 11.6), (12.5, 9.3), stroke: black + 0.8pt, mark: (end: ">", fill: black))

      // Orchestrator to VNFM
      line((14.25, 8.8), (14.25, 8.3), stroke: black + 0.8pt, mark: (end: ">", fill: black))

      // Orchestrator to VIM
      line((14.25, 8.8), (14.25, 6.0), stroke: (paint: black, dash: "dashed", thickness: 0.8pt), mark: (end: ">", fill: black))

      // VNFM to VNFs
      line((12.5, 7.4), (10.5, 9.0), stroke: black + 0.8pt, mark: (end: ">", fill: black))

      // VIM to Infrastructure
      line((12.5, 4.8), (10.5, 5.5), stroke: black + 0.8pt, mark: (end: ">", fill: black))

      // VNFs to Infrastructure
      line((5.25, 7.5), (5.25, 6.2), stroke: (paint: blue, dash: "dotted", thickness: 0.8pt), mark: (end: ">", fill: blue))
    })
  ],
  caption: [Architettura NFV ETSI],
)

L'architettura NFV ETSI è composta da $3$ strati principali: 
- *Network Function Virtualization Infrastructure*. A sua volta comprende:
  - _Risorse Hardware_: Cpu, Storage, Network
  - _Risorse virtualizzate_: Rene le risorse hardware virtualizzate (ad esempio possibilità di usare GPU ecc).

- *Virtual Network Function (VNFs)*
  - _EMS_: Serve per gestire le Virtual Network Function. Ad esempi: crea diverse istanze, le ellimina ecc


- *NFV MANO*: Si tratta di un modulo che esegue *orchestrazione* e controllo, a sua volta contiene:
  - _Virtual Infrastracture manager (VIM)_: Conosce lo stato dei link, lo stato delle risore ecc $dots$

  - _Virtual Manager (VNFM)_: gestisce le virtual network function

  - _Orchestratore_: gestisce le istanze, decide dove allocare le funzionalità, ecc. Ha collegamenti con le interfacce sottostanti per prendere decisioni in base allo stato della rete:
    - VIM: Sa quali sono le risorse disponibili
    - VNFM: sa quali sono le istanze attive

Caratteristiche:
- *Flessibilità massima*: le varie funzionalità virtuali possono essere mappate dove vogliamo (ovviamente l'hardware deve essere disponibile)

- *Indipendenza* hardware software

- La prototipazione di nuovi servizi è molto più veloce. 

- *Uso delle risorse condiviso e ottimizzato*:
  - *Multiprovider*: a seconda della necessità dell'applicazione, uso servizi di rete che offrono caratteristiche diverse

  - *Multi-tenant*: ad ogni utente della rete devono essere assegnate le risorse richieste. Gli utenti non sanno con chi stanno condividendo le risorse

=== Cloud + NFV + SDN

La rete 5G nasce con l'idea di situarsi nell'intersezione tra Cloud, NFV e SDN. 

*Cloud*: 5G sfrutta il cloud per offrire servizi scalabili e flessibili. 

*Cloud + NFV*: I servi di rete sono realizzati tramite funzioni di rete virtualizzate geograficamente sparse. Estrema flessibilità e scalabilità.

*Cloud + NFV + SDN*: 5G sfrutta *SDN* per *collegare tra di loro le varie funzioni di rete virtualizzate*, garantendo i requisiti desiderati (ad esempio latenza, banda, ecc.).

Ogni network function e ogni link presentano degli attributi ben definiti (banda, latenza, tempi computazionali). L'*orchestratore*, in base a questi attributi, decide dove allocare le varie funzioni di rete virtualizzate. Inoltre, grazie a SDN, istruisce i dispositivi di rete su come instradare il traffico tra le varie funzioni di rete virtualizzate, garantendo i requisiti desiderati.

#esempio()[
  Se una certa funzionalità richiede una latenza di $10 "ms"$, l'orchestratore deve allocare tale funzionalità su un nodo che garantisce quella latenza.
]

