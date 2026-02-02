#import "../template.typ": *

= Lezione 5

=== L2CAP Canali logici

L2CAP supporta solo canali ACL. Offre tre tipi di canali logici:
- *Conectionless*: unidirezionale, se un aplicazione sopra vuole mandare qualcosa in broadcast a tutta la rete.
- *Connection-oriented*: bisonga prima stabilire il livello di qualità del servizio ed e bidirezionale, serve per operazioni di controllo all'intero nella piconet.
- *Sos*

I pacchetti di L2CAP si occupa di fare della segmentazione e frammentazione e riassemblaggio lato destinazione. In quanto un pacchetto non ci sta in un singolo pacchetto livello basment. Un pacchetto fornito a L2CAP può occupare più pacchetti basment, deve essere frammentato.

Viene nascosta la frammentazione a livello data-link. I 3 canali (servizi offerti da L2CAP) vengono riconosciuti da un chanel ID (2 byte):
- Se ID = 2, Conectionless path.
- Se ID >= 64, Canale conntection-oriented.
- Se ID = 1, canale di controllo + anche il controllo che dobbiamo eseguire.

=== SDP service Descovery

Lato client, serve per ricercare un servizio e un browsing dei servizi. Si appoggia sui canali ACL.

== Bluethooth low energy

Dallo standard $4.0$. L'obbiettivo è ridirre le risorse utilizzate da Bluethooth.

Cambia la procedura di inquiring, diventando più semplice (meno consumo di batteria).

A differenza del Bluethooth normale abbbiamo differenti patter di comunicazione:
- Piconet (stella)
- Broadcast
- Architettura Mash
- Presenza, notifica la presenza
- Distanza, miusra della distanza tramite radio frequenze
- Direction

Tutti i beacon Bluethooth sono dispositivi low energy.

Per quando riguarda il protocollo cambiano alcuni livelli a differenza del Bluethooth base. In particolare l'Architettura si va a semplificare.\

La banda riamen $2.4 "Ghz"$. I canali diventato 40 canali:
- 37 usati come data packets
- 37,38,39 sono canali di advertising

Il freqeuncy hopping è più semplice, in particolare il canale succesivo viene calcolato come:
$
  "Channel" = ("curr_channel" + "hop") mod 37
$
dove $"hop"$ è stabilito all'atto della connessione. Viene utilizzata anche Gaussian Frequency shit keying con rate di moduluazione a $1 "Mbps"$ (sufficiente per li scopi di Bluethooth).

//aggiungere tabella
Lo spettro viene diviso nel seguente modo.

Un ricevitore conosce l'hop, il current Channel capisce qual'è perchè sente trasmettere e calcola il canale successivo con queste informazione.

I canali di advertising sono messi uno in mezzo all'inzio e alla fine dello spretto, questo per andare a ridurre le interferenze. Vengono spalmati in modo _equo_ all'interno dello spettro.

=== Ble
Cambia la machcina a stati finiti, in particolare gli stati del link-layer.\
Li stati sono diversi dal punto di vista dell'utilizzo che ne viene fatto

- Isochromuns broadcasting: modo temporizzato di fare broadcasting. Il livello link layer mette a disposizione questo servizio che periodicamente invia sui 3 canali di advertising broadcasting.

- La parte di advertising: Si inverte (non c'è più un master che fa enquiring), è lo slave che dice _ci sono_ sui canali di advertising.

#nota()[
  Rimane la completa non sincronizzazione del sistema.
]

L'advertising viene fatto nel seguente modo:
- punto di inizio (dispositivo che vuole essere scoperto)
- il tempo di advertising è l'intervallo tra due advertising, composto da:
$
  T_"advEvent" = "advinterval" + "advDelay"
$
Dove:
- advInterval è interno al dispositivo. In base alla scelta del tempo intervallo di adv influisce anche sul consumo di batteria
- advDelay, numero randomo tra $0 e 10"ms"$. In questo modo riduciamo la possibilità di collisioni (probabilità molto basse).

Non ci sono garanzie di latenza (a causa del dealay random)
#nota()[
  Bluethooth energy non ha requisiti sulla latenza, no real time.
]

=== GAT

La gestione dei profilo è gestita dal GAT, i profili sono specifici e dicono cosa fa il dispostivo, alcuni profili sono :
- BCS
- CSCP

#nota()[
  Un dispositivo può indurre più profili, non sono esclusivi
]

=== GAP

Gestisc lo stato del dispositivo a un livello più alto. Si tratta di una versione più vicina al software. Possiamo accedere alla connesione Bluethooth tramite:
- Broadcaster: spedisce advertising Bluethooth packet
- Observer: il dispositivo si mette in ascolto sui canali di advertising, ascolta e basta
- Peripheral: un perphel device opera in slave (advertiser) vuole essere scoperto da un central
- Central: un central device scopre i dispositivi slave

//aggiugnere imamgine e riguardare
(specchiato rispetto a Bluethooth). A livello link layer, durante la fase di connessione troviamo i seguenti stati (l'obbiettivo è creare una comunicazione unicast per scambiare messaggi):
- il dispositivo che vuole essere scoperto (slave), usa periodicamente i canali advertise.
- il dispositivi scanner, ascolta questi canali.
- Una volta che ricevo un messagio rispondo semrpe su quel canale, se non ricevo risposta cambio canale.
- Dopo aver connesso lo slave, viene comunicato l'hop dall'initietor diventando un client

il master svolge il ruolo di client per capire se lo slave di è collegato.

=== Comunicazione broadcast

In questo caso abbiamo un host che vuole fare broadcasting (si tratta di un broadcaster). Il dispositivo viene identificato come broadcaster. Chi vuole ascoltare si mette in modalità obsserver ricevendo le informazioni, solamente cho è nel raggio di comunicazione le riceve.

L'observer scandaglia solamente i $3$ canali di observer. Non c'è risposta della ricezione delle informazioni, è solamente un'ascolto passivo.

=== Passive and Active scanning

// riguardare

= ZigBee

Vogliamo affidabilità e basso costo. Inoltre vogliamo lunga durata della batteria (anni).\
Vogliamo avere una bassa complessità (tanti dispositivi che consumano poco), inolte usiamo la bassa ISM per non pagare licenze.

Vogliamo avere un altro numero di nodi (a differenza della piconet) e intereopabilità tra vendors.

Diversi tipi di funzionalità:
- FFD
- Router FDD
- EndDevice RFD

Scambi di dati permessi:
- Dati periodici: invio periodico di dati, tipo i sensori (come ad esempio dispositivi smart ecc)
- Dati intermittenti asincroni: tipo una applicazione. Sono stimoli esterni (interruttore).
- Dati ripetitivi e a bassa latenza (Allocazione di time slot)

== Architettura

La parte rossa rimane fissa (segue lo standard).
Lo standard $802.15.5$ specifica la tipologia di modulazione e di spread spectrum per 3 bande:
- Spred factor: sequenza di bit casuale messa in xor con il bit che vogliamo trasmetter.
- chip rate: bit mandati effettivi su quelli utili
- la moduazione è $1 "BPSK"$, 1 chip per singolo oppure $"O-BSK"$ possiamo avere 2 chip per simbolo

Il data rate è al massimo $250 "Kbps"$ è $1/4$ del data rate di un Bluethooth, molto basso. Per l'utilizzo che ne andremo a fare è più che sufficiente.

== Livello MAC

Dobbiamo introdurre il concetto di *duty-cycle*. Specifico per ogni device
#informalmente()[
  Se l'obbiettivo è di ridurre utilizzo della batteria, tantovale mantenere la radio in ascolto e in trasmissione. Andiamo a scegliere dei tempi di spegnimento a seconda del tipo di dispositivo e in base al suo ruolo nella rete.
]
C'è sempre un coordinatore, ma in un caso:
- gestione basata su beacon. Non c'è TDMA ma usiamo CSMA/CA. In wireless non si può fare multiple detection non posso trasmettere e senitre cosa trasmetto, devo prevenire le collisioni.
- sorta di broadcast dal coordinatore.

Le possibilità di gestione di CSMA/CA sono:
- Unslotted CSMA/CA
- Slotted CSMA/CA richiede utilizzo dei becon (il coordinare emette messagi di coordinazione periodicamente).

=== CSMA/CA

Il coordinatore invia periodicamente dei beacon. Deve essere concordata a priori la frequenza inoltre c'è una deriva del clock abbastanza importante. Server per:
- sincronizzazione i vari dispositivi

- vogliamo organizzare la comunicazione nella rete, tenendo in considerazione che ci sono devide che counicano periodicamente, device che comunicano in modo asincrono ecc

- gestione della comunicazione indiretta. Problema, se io coordinatore devo inviare dei dati a dei dispositivi (avendo la lista di quelli mancanti), all'interno del beacon lo comunico. Il dispositivo che riceve il beacon sa se è dentro o no alla lista di dispositivi che deve ricevere, in tal caso deve lasciare la radio accessa. Se non devo ascoltare e non devo mandare nulla posso spegnere la radio

//aggiungere imamgine
Il beacon ha la seguente struttura, viene detto *super-frame*. Esso va da un beacon a un altro beacon (copre tutto l'intervallo temporale). Il super-frame è diviso in due:
- La prima metà è attiva. A sua volta divisa in due:
  - CFP (contenction free period) contiene GTS garanteed time slot. Contiene tutti i time slot garantiti. Il coordinatore ha già allocato time slot per certe dispositivi. Se qualche dispositivi ha chiesto dei canali con garanzie sulla latenza vengono utilizzati questi canali.
  - CAP (contention access period). Diviso in time sloted in contesa, tutti i dispositivi competono per accedere a questa parte di slot.

- La seoconda metà è inattiva. Nessun messagio viene comunicatao, tanto è più grande la parte inattiva più risparmio energia. Prende il nome di slotted CSMA/CA

La durata delle varia parti viene comunicata la struttura del superframe attraverso il beacon, nel seguente modo:
- Beacon interval: quanto passa da beacon a beacon

- Durata minima detta aBaseSuperFrameDuration. Definito dalla standard come una trasmissione di $960$ simboli. Si trtta di una unità fondamentale, unità di durata di un super-frame.

- Durata della parte attiva indicata da $"aBSD" * 2^"SO"$, dove _SO_ è il super-frame order e sono $2$ byte massimo.

- Abbiamo un altro numero che è il beacon order $"BO"$. Esso determina quanto è il Beacon interval = $"aBSD * 2^BO"$. Anche questo è di $2$ byte.

All'interno del beacon dobbiamo comunicare $"BO"$ e $"SO"$. Dati questi due numeri possiamo capire quanto è lunga la parte attiva e quanto la parte inattiva. Il duty-cycle è dato da:
$
  "duty-cycle" = 2^"SO" / 2^"BO"
$

super-frame specification: 
- Beacon Order: Serve sapere ogni quanto aspettarci un beacon, quanto devo aspettare per il prossimo beacon (o il primo beacon, riguardare)
- SO: quanto è grande la parte attiva
- Final Cap slot: indica in che punto termina il CAP. Il CAP non può sforare nel contantion free period in quanto sono comunicazioni riservate già allocate. 
- Reserved: 
- Pan Coordinator: se il dispositivo è un coordinatore PAN. 
- Association permit: bit di controllo

La grandezza di CAP e CFP è data dal numero totali di simboli (da $2^0$ a $2^14$) succesivamente prendo il numero di simboli di SD e lo divido in 16 parti uguai. Quello è il tempo interno alla comunicazione, divido in slot la parte in contesa. 

//aggiungere somma
IL GTS è un contratto che il coordinatore ha fatto con i dispositivi, per garantire di parlare senza interferenze in un certo slot. La durata degli slot condivisi dipende da quanti simboli ho diviso 16. 

=== Come avviene l'accesso a CAP 

Il livello fisico (CS) ascoltiamo la portante e sentiamo se qualcuno sta comunicando. Il livello fisico mette a disposizione la CCA per capire se il canale è libero (ascolta per intervalli brevi in quanto costa). Viene tenuta una sora di variabili interne (ogni dispositivo):
- NB = numero di backoff, Inizialmente è a zero (ottimista) e al massimo è $4$. Se l'operazione non va a buon fine, viene comunicato al livello superiore che la connesione non è avvenuta dopo 4 tentativi

- BE: periodo di backoff per riprovare la connesione, numero di contation slot che dobbiamo aspettare per comunicare

- CW: quante volto devo osservare il canle e quante luci verdi devo avere dal livello fisico per trasmettere (numero di slot consecutivi liberi)

#esempio()[
  Trasmissione con successo in contesa (CSMA/CA):
  - slot condivisi 
  - acoltiamo il canale
  - no collisioni (tramissione assime)

  Prima di chiedere se è libero, adniamo ad attendere un numero casuale [0,7] e lo moltiplichiamo per 20 simboli 

  chiamiamo 2 volte CCA, se è libero entrambe ele volte aspetto 5 slot da 20 simboli (CCA). La CW è a 1, dobbiamo ritestrare con due CCA consecutive (nello slot di contesa successivo), siccome ottengo ok, allora CW = 0 e posso iniziare a trasmettere. 

  Quando CW = 0 posso iniziare a trasmettere. Chi ascolta nel momento successivo sentirà il canale occupato. 

  Canale occupato: 
  - il secondo CCA non va a buon fine. La CW viene reimpostata a 2 e NB=1 e BE=4, viene aumentato l'esponente (sceglo tra un numero maggiore di numeri randomo per aumentare la probabilità di diffierenziarci). 
  - Aspetto un altro numero di slot random
  - Non tengo acceso la radio. Se mi accorgo che il canale è occupato non ascolto per tutto il periodo di back-of ma calcolo un alro numero di slot spegndo la radio. 
  - il CS viene fatto solo per un periodo limitato di tempo (salva batteria ma perdo occasioni).

  #nota()[
    Non ho bisogno di bassa latenza o qualità di servizio
  ]

]
