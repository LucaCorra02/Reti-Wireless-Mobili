#import "../template.typ": *

== LTE handover

#attenzione()[
  In LTE esiste solo *hard-handover*
]

Non esiste un nodo centralizzato tra eNodeB. Ogni UE è collegato a una solo base station per volta. In base al bearer in cui siamo possamo usare tipi di handover diversi:

- *Seamless handover*: ammette la perdità di traffico ma garantisce una bassa latenza. Usato ad esempio per traffico _voip_. Caratteristiche:
  - Minore latenza
  - Ammette ritrasmissioni

- *Lossless handover*: Garantisce che i pacchetti *non* vengano persi, se viene perso un messaggio *deve essere ritrasmesso*. A livello di handover non possiamo fare riferimento a nessun protocollo di radio link controller (livello 2). La perdità verrà gestita a livello $4$. Un esempio di traffico è _HTTP/FTP_

=== LTE lossless handover

Supponiamo che un UE a cui sta venendo inviato un *flusso di download* da parte del S-GW, si sposti da un'eNodeB a un'altro. Il Service Gatawey continuera a mandare pacchetti alla vecchia posizione del dispostivo.

Tramite l'`interfaccia X2` viene tenuto un buffer dentro la base station precedente $"eNB" 1$ in modo da non perdere i pacchetti in download.

Una volta che l'handover è completato, la base station precedente manda i pacchetti bufferizzati alla nuova base station $"eNB" 2$ che li manda al dispositivo. In questo modo non si perdono pacchetti e il download può continuare senza interruzioni.

#nota()[
  L'handover viene effettuato tramite un *cordinamento tra le due base station (partenza-arrivo)*, sfruttando il collegamento tra di esse.
]

=== Handover S1 vs Handover X2

Prendiamo in considerazione il sequence diagram di una procedura di handover _vecchio_, ovvero quella che *coinvolge la rete core* (`interfaccia S1`).

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

Il source MME (modulo che gestisce la mobilita) gestisce l'UE corrente. L'assunzione è che sia già stato deciso di passare la gestione dell' UE da `eNodeB target` a `eNodeB sorgente`:

2. Da $mr("SRC")$ eNB a $mr("SRC")$ MME, viene fatta una `handover-request`. La base station che sta gestendo il dispositivo chiede al MME di rillocarlo.

+ $mr("SRC")$ MME inoltra la richiesta di handover all' $mb("DST")$ MME. La destinazione è l'MME che avrà in carico il traffico di controllo dell'UE al termine della procedura di handover.

+ $mb("DST")$ MME manda la `handover-request` al $mb("DST")$ eNB, ovvero al eNodeB che avrà in gestione il dispositivo al termine della richiesta.
  #nota()[
    Tutte le $4$ entità in gioco, sono ora avvisate della procedura di handover. Inoltre, si tiene traccia dei bearer attivi (con i QoS relativi). Essi andranno ricreati alla fine dell'handover.
  ]

+ $mb("DST")$ eNB prepara le risorse a livello di resource control, per ospitare il dispositivo (UE)

+ Il $mb("DST")$ eNB invia una `handover-request ACK` a $mb("DST")$ MME per confermare l'allocazione delle risorse. Tale messagio viaggia sulla rete *back-bone* dell'operatore (non viaggia via radio ma tramite protocollo scp).

+ $mb("DST")$ MME sa che è tutto pronto. $mb("DST")$ MME manda una `forward- handover-repsonse` alla $mr("SRC")$ MME. Il comando di handover può essere inviato al dispositivo coinvolto, raggiunge

+ $mr("SRC")$ MME manda un messaggio a $mr("SRC")$ eNB. Il messagio è di `handover command`.

+ il comando di handover viene inviato dal $mr("SRC")$ eNB all'UE finale, si tratta di un messaggio di `handover command`.

+ Una volta che l'UE è stato avvisato, può iniziare il cambiamento di stato. $mr("SRC")$ MME viene notificato del cambiamento di stato `status transfer` da parte del $mr("SRC")$ eNB.

  #nota()[
    La freccia tratteggiata serve in caso di *losless handover*, in questo caso il $mr("SRC")$ eNB deve trasferire anche i pacchetti bufferizzati al $mb("DST")$ eNB per evitare perdite di pacchetti.
  ]

+ Viene inviato un `MME status-transfer` da $mb("DST")$ MME a $mr("SRC")$ eNB.

+ l'`UE` invia una `handover confirm` a $mb("DST")$ eNB per confermare che è arrivato alla nuova base station.

+ Una volta fatto l'handover $mb("DST")$ eNB avvisa $mb("DST")$ MME dell'avvenuta procedura di un handover con un messaggio di `handover-notify`.

+ $mb("DST")$ MME invia al vecchio $mr("SRC")$ MME una conferma dell'avvenuta procedura di hadover. Inoltre, il $mr("SRC")$ MME invia un ACK.

+ L'`UE` chiede un `tracking-area-update`. Il messaggio va direttamente da `Target MME` (in realtà passa da $mr("SRC")$ eNB). Questo messaggio serve per *notificare alla rete core* che il dispositivo è ora sotto la *gestione di un nuovo MME*. In questo modo, la rete core sa che deve mandare i pacchetti al nuovo MME e non al vecchio.

+ Una volta che la procedura è completata $mr("SRC")$ MME (vecchio MME) manda un messaggio al $mr("SRC")$ eNB (stazione che aveva in gestione il disposistivo) per *rilasciare le risorse* `release-resource`

#nota()[
  Siccome la procedura è di handover è hard, L'UE *non* può tenere i _piedi in due scarpe_. La risposta dell'handover viene data sulla nuova destinazione.
]

#attenzione()[
  La parte di gestione e preparazione alla procedura di handover è *affidata interamente alla rete* e non all'UE.

  Prima di contattare il dispositivo UE per notificare l'handover, bisogna essere sicuri che, una volta iniziata la procedura di hadover, vada a buon fine. Inoltre, le risorse necessarie devono essere già pronte, in modo da non avere interruzioni del servizio (fino a quando non viene ricevuto un `handover-request-ACK`, la procedura di handover non parte)
]

=== Handover X2

Viene risolta tra le due base station e alla fine viene notificata la rete core. Condizioni necessarie:
- All'interno della stessa tracking area
- Interfaccia x2 attiva

Procedura (supponendo di aver scelto di fare handover):
+ La `BS source` dialoga direttamente con la futura `target enodeb`. *Non viene contatta la rete core*

+ Il traget node b deve essere pronto per ricevere n nuovo dispositivo

+ a questo punto viene inviato un `handover command` all'UE

+ c'è il passaggio di stato tra le due istazioni

+ UE manda un messagoio alla base station target un messaggio di `hand over complete`

+ A questo punto viene contattata la rete core per la prima volta, viene informata del cambio di percorso (nuova enodeB che gestisce lo UE).

#nota()[
  La rete core è coinvolta solo per cambiare i percorsi.

  Anche in questo caso la richiesta di handover parte dalla rete cellulare (eNodeB). Lo UE non può assolutamente far partire la richiesta ma si attiene alle direttive.
]

= 5G

Si tratta di usi della rete cellulare per calcoli molto complessi. L'idea è usare la rete internet per fa comunicare tanti dispositivi, in grad di eseguire calcoli e task complessi.

I casi d'uso vengono incastrati in alcune specifiche. In particolare esistono 3 macro categorie:
- emBB:
  - Servizi orientati alle persone
  - elevata banda
  - straming HD

- uRLLC:
  - Servizi orientati alle industrie
  - Bassisima latenza e affidabilità (sia perdità che realibity della rete $99.99%$)
  - Controllo remoto e guida autonoma

- mMTC:
  - Alta densità di connessioni
  - Smart Cities / Smart Agricuture

Principali direzioni di 5g:
- Maggiore efficienza spettare QUAM più alte
- Riuso spaziale (celle più dense)
- Softwarizzazione della rete. Abbiamo una convergenza tra ICT e IT.

Tecnologie principali di 5G:
- Software difined Network SDN
- Network Function Virtualizazion (NFV)
- Centralieze-RAN (C-RAN) e Virtual-RAN
- Edge computing

== Software Defined Networking

Abbiamo una rete con le seguenti caratteristiche:
- Sui dispostivi di rete c'è sia una parte di algoritmi di controllo (scambi dati con altri dispsotivi) sia le regole di forwarding (scambio di pacchetti)

- Tradizionalmente le parti dati e controllo sono sullo stesso dispositivo. Attraverso SDN togliamo la logica di controllo dai dispostivi e la meddiamo nel layer SDN  (algoritmi di controllo). Ha visione globale della rete ed è centralizzato. Ogni controller può controllare diversi dispositivi.

- C'è una unica network application per quello che è estenro alla rete. E uuna interfacia verso gli switch

#nota()[
  Tramite il software definiamo il corpontamento della rete.
]

=== Evouzioni SDN

Prima imamgine: Tradizionale, Control Plane e Data Plane assime. Possiamo configurare solo Control Plane

Seconda immagine: SDN ha staccato e separato il control plane rendendolo programabile. Tuttavia le funzionalità del Data plane sono fissate

Terza immagine: Data plane e control plane programmabile. Possiamo programmare e gestire il dataplane (creazione di header custom, attraverso parser ad hoc)

#esempio()[
  PISA: Possiamo programamre:
  - Parser
  - Mathc-action table
  - Traffic manager fa operazioni base della rete
  - programmare il deparser (serializza il pacchetto e lo manda in rete)
  Potrebbe essere mappato un random forest per fare inferneza in line sul tipo di traffico direttmente nello switch (training fuori dallo switch e inferenza sullo switch)
]

== SDN

Visione centralizzata -> ottimizzazione dei routing

Tesitng e configurazione di nuovi protocolli di rete più semplice e veloce

Le sfide sono:
- Controller punto debole dell'architettura
- Bisogna essere in grado di reagire in maniera real-time
- Ottimizzazione del numero di regole:
  - Gestione ottimizzata delle tabelle di forwarding
  - Gestione e faranzia dell'isolamento di reti. Il traffico di reti diverse deve essere separato (come se fossero delle VLAN diverse).

- Sicurezza:
  - Controllare il controller

== Network Function Virtualization

Abbiamo dei moduli standard che fanno quello per cui sono stati costruiti. Problematiche:
- Hardware costoso e viene poco utilizzato
- Hardware poco costoso ma rete molto utilizzata e non basta

Ora esistono i cloud as a service. Basta pagare l'abbonamento senza avere hardware specifico.

Tuttavia l'architettura precedente con hardware non prevede:
- *Scalabilità verticale*: rendiamo più potente un certo elemento
- *Scalabilità orizzontale*: repliche dello stesso servizio su macchine diverse. Se il trafffico su una macchina è intesa possiamo far partire un'altra istanza e bilanciare il traffico (vale anche per la compressione).


Abbiamo una radio. Non può essere virtualizzata

L'idea è separare quello che è il software (o il frimware) di un certo dispsositivo e ne creiamo una funzionalità software. L'idea è che tale software girerà su un hardware. L'idea è che in questo modo possiamo andare istanziare più servizi dedicati senza avere più dispositivi hardware dedicati.

In questo modo possiamo avere più *scalabilità* e *Flessibilità*.

Il problema è che nella rete cellulare non può essere tutti virtualizzato (troppo latenza di percorso se lo accentriamo in un unico datacenter).

L'ida è che vogliamo realizzare un certo data-plane in modo virtualizzato. Vogliamo servire degli utenti distributi geograficamente.

L'idea è utilizzatr un *NFV orchestrator*. Esso deve:
- Identificare quali template (servizi) servono alla comunicazione

- Vengono presi i template e vengono istanziati secondo i requisiti imposti dal data-plane. Ogni istanza possiede i requisiti necessari

- Inoltre vogliamo anche trovare il migliore placment per la funzionalità che vogliamo realizzare. Ovvero dove e come istanziare i vari servizi. Ci serve sapere lo *stato fisico delle risorse* distribuite geograficamente sulla rete.
  #nota()[
    I vari servizi possono essere condivise tra più catene o essere addirittura istanziate sullo stesso nodo.
  ]

=== NFV Architettura

- Network Function Virsualitazion Infrastructure:
  - Risorse Hardware
  - Risorse virtualizzate. Rende le risorse hardware virtualizzate (ad esempio possibilità di usare GPU ecc).

- Vitrual Network Functiom
  - EMS: Moduli che servono per monitorare lo stato delle macchhine virtuali. Creare diverse istanze, eliminarle ecc. Serve per gestire le Virtual network function


- NFV MANO. Fa sia gestione che orchestrazione. Contiene:
  - Virtual Infrastracture manager: Conosce lo stato dei link, lo stato delle risore, quali sono disponibili ecc..

  - Virtual Manger, gestisce le virtual networl function

  - Al di sopra abbiamo l'orchestratore. Ha collegamente sulle interfaccia di sotto:
  - VIM: Sa quali sono le risorse disponibili
  - VNFM: sa quali sono le istanze adattive

  Esso può prendere decisioni in base al servizion, NFV, infrastruttura, ecc..

Caratteristiche:
- Flessibilità massima: le varie funzionalità possono essere mappate dove vogliamo (ovviamente l'hardware deve essere disponibile)
- Indipendeza hardware software
- Prototipizzzare servizi
- Uso delle risorse condiviso ottimzzato:
  - Multiprovider: a secondo della necessità uso computazioni offerte diverse
  - Multitenet: offro un infrastruttura e chiedo di usare le risorse, ad ogni utente deve essere assegnato le risorse richieste. Gli utenti non sanno con chi stanno condividendo le risorse
  - SOluzione inride multi tenant-,ulti provider, tutti condividono con tutti (molti a molti)

=== Cloud

Ogni network function e ogni link ha degli attributi. Possediamo la :
- Banda
- Latenza
- Tempi computazionali

Se ad esempio la funzionalità $5$ richiede $10"ms"$ verranno dati sufficienti risorse hardware per garantire quei tempi.

Le Network function possono essere allocate un pò dove vogiamo. Per collegarle tra di loro usiamo SDN. L'orchestratore deve rispettare un certo flusso e istruisce alcuni degli switch w router SDN per mettere in collegamente le varie network function. Garantendo le latenze desiderate.

Unendo Cloud + NFV + SDN ho la flessibilità totale della rete.
