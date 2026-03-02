#import "../template.typ": *

== LTE handover

Solo hard harad-handover in LTE. Non esiste un nodo centralizzato tra eNB. Siamo collegati a una solo base station per volta. In base al bearer in cui siamo possamo usare tipi di handover diversi

Esistono due tipi di handover (
Sono due approcci diversi e usati per traffici diversi)
- *Seamless handover*. Traffico voip, permette di perdere traffico ma garantisce una bassa latenza (frame persi ma bassa latenza).
  - Minore latenza
  - Ammette ritrasmissioni

- *Lossless handover*. Traffico HTTP/FTP. Garantisce che i pacchetti non vengano persi, se viene perso qualcosa deve essere ritrasmesso. A livello di handvoer non possiamo affidarci a nessun protocollo di radio link controller (perdità a livello 2). La perdità verrà individuata a livello 4. La perdità viene gestita tra le due eNB tramite un protocollo apposito.
- Maggiore latenza
- Riduce la perità dei pacchetti

=== LTE lossless handover S1

Si attua quando c'è un flusso di download. Il flusso di download va perso il basso. S-GW invia pacchetti alla posizione vecchia del dispositivo che però si è spostato. Tramite l'interfaccia x2 viene tenuto un buffer dentro la base station precedente. Dopo l'handover tutto il traffico che non ha ricevuto un ACK viene trasferito alla nuova base station in modo tale che raggiunga il dipsositivo che si è spostato.

Viene effettuato un *
cordinamento tra le due base station (partenza-arrivo)* sfruttando il collegamento. Se non sfruttassimo tale collegamento avremo una perdita

Sequence diagram (in rosso sono due moduli della rete RUN in blue due modili della rete CORE). Il source MME (modulo che gestisce la mobilità) gesiste l'EU corrente.

L'assunzione è che è già stato deciso di passare la gestione dello UE da nodeB target a nodeB sorgente:
+ Da `SRC NB` a `SRC MME` che sta gestendo quell'UE specifico. Si chiama `handover-request`. La base station che sta gestendo il dispositivo lo chiede di rillocare.

+ `SRC MME` inoltra la richiesta di handover all' `DEST MME`, si tratta del MME che avrà in carico il trafffico di controllo dell UE al termine della procedura

+ `DST MME` manda la `handover-request` al `DST NB`, ovvero al nodeB che avrà in gestione il dispositivo al termine della richiesta.

  #nota()[
    Tutti e 4 gli attori ora sono avvisati della procedura di handover.\
    Inoltre, vengono tenuti traccia dei bearer attivi e con quali QoS. Essi andranno ricreati alla fine dell'handover.
  ]
+ `Dst Nb` prepara le risorse, a livello di resource control, per ospitare il dispositivo (UE)

+ il `node B dst` manca una `handover-request ACK` a `DST MME`. Per confermare che le risorse sono state allocato. Tale messagio viaggia sulla rete back-bone dell'operatore (non viaggia via radio ma protocollo scp).


+ L'handover può avvenire in quanto `DST MME` sa che è tutto pronto. `DST MME` manda una `fw handover repsonse` alla `SORG MME`. Il comando di handover può essere inviato al dispositivo coinvolto

+ `SRC MME` manda un messaggio a `SRC NB`. Il messagio è di `handover command`.

+ il comando di handover viene inviato dal `soruce node-b` allo UE finale, si tratta di un messaggio `handover comando`.

+ Una volta avvisato lo Use equipment può essere iniziato il cambiamento di stato. Viene invitato l'MME che ha incatico lo EU uno *status transfer*.

+ la linea trattegiata viene effetuata per fare il trasferimento di dati (oozionale)

+ viene inviato un `MME status-transfer` da `DST NB` con l'ospitant `Source node B`.

+ La conferma del nuovo hand over viene inviato da UE a `DST NB`. Il messsaggio prende il nome di `DST nB`.

+ Una volta fatto l'handover può informare il suo $"MME"$ dell'avvenuta procedura di un handover con un messaggio `handover - notify`

+ `DEST MME` invia al vecchio `MME SRC` che la procedura di hadover è andato apposto. Infine l'MME sorgente invierà un ACK.

+ Lo UE chiede un `tracking area update`. Il messaggio va direttamente da `MME B` (in realtà passa da `SRC NodeB`).

+ Tutto quello che aveva in gestione dello UE può essere buttata via, deve avere la conferma del piano di controllo. Il `SRC MME` manda un messaggio al `SRC node B` (stazione che aveva i gestione il vecchio disposistivo) dicendo `release resource`

#nota()[
  Siccome la procedura è di handover non posso tenere i _piedi in due scarpe_ la risposta dell'handover viene data sulla nuova destinazione.
]

#attenzione()[
  La parte di gestione e preparazione è tutta affidata alla rete e non all'UE.

  è importante sapere che quando la decisione di hadover viene presa il dispositivo UE viene contattato all'ultimo e inoltre viene contattato solo quando si è sicuri che quando la procedura di hadover inizia vada a buon fine e che le risorse siano già pronte in modo da non avere interruzioni del servizio (fino a quando non viene ricevuto `handover request ACK` la procedura di handover non parte)

  La decisione dell'handover è presa dalla rete e non dal dispositivo
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
