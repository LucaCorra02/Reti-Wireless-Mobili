#import "../template.typ": *

== L2CAP Canali logici

L2CAP supporta solo canali ACL. Offre tre tipi di canali logici:
- *Connectionless*: unidirezionale, se un'applicazione sopra vuole mandare qualcosa in broadcast a tutta la rete.
- *Connection-oriented*: bisogna prima stabilire il livello di qualità del servizio ed è bidirezionale, serve per operazioni di controllo all'interno nella piconet.
- *SOS*

I pacchetti di L2CAP si occupano di fare della segmentazione e frammentazione e riassemblaggio lato destinazione, in quanto un pacchetto non ci sta in un singolo pacchetto livello baseband. Un pacchetto fornito a L2CAP può occupare più pacchetti baseband, deve essere frammentato.

Viene nascosta la frammentazione a livello data-link. I 3 canali (servizi offerti da L2CAP) vengono riconosciuti da un channel ID (2 byte):
- Se ID = 2, Connectionless path.
- Se ID >= 64, Canale connection-oriented.
- Se ID = 1, canale di controllo + anche il controllo che dobbiamo eseguire.

=== SDP Service Discovery

Lato client, serve per ricercare un servizio e un browsing dei servizi. Si appoggia sui canali ACL.

= Bluetooth Low Energy

Dallo standard $4.0$. L'obiettivo è ridurre le risorse utilizzate da Bluetooth.

Cambia la procedura di inquiring, diventando più semplice (meno consumo di batteria).

A differenza del Bluetooth normale abbiamo differenti pattern di comunicazione:
- Piconet (stella)
- Broadcast
- Architettura Mesh
- Presenza, notifica la presenza
- Distanza, misura della distanza tramite radio frequenze
- Direction

Tutti i beacon Bluetooth sono dispositivi low energy.

Per quanto riguarda il protocollo cambiano alcuni livelli a differenza del Bluetooth base. In particolare l'architettura si va a semplificare.\

La banda rimane $2.4 "GHz"$. I canali diventano 40 canali:
- 37 usati come data packets
- 37, 38, 39 sono canali di advertising

Il frequency hopping è più semplice, in particolare il canale successivo viene calcolato come:
$
  "Channel" = ("curr_channel" + "hop") mod 37
$
dove $"hop"$ è stabilito all'atto della connessione. Viene utilizzata anche Gaussian Frequency Shift Keying con rate di modulazione a $1 "Mbps"$ (sufficiente per gli scopi di Bluetooth).

//aggiungere tabella
Lo spettro viene diviso nel seguente modo.

Un ricevitore conosce l'hop, il current channel capisce qual è perché sente trasmettere e calcola il canale successivo con queste informazioni.

I canali di advertising sono messi uno in mezzo all'inizio e alla fine dello spettro, questo per andare a ridurre le interferenze. Vengono spalmati in modo _equo_ all'interno dello spettro.

== BLE
Cambia la macchina a stati finiti, in particolare gli stati del link-layer.\
Gli stati sono diversi dal punto di vista dell'utilizzo che ne viene fatto

- Isochronous broadcasting: modo temporizzato di fare broadcasting. Il livello link layer mette a disposizione questo servizio che periodicamente invia sui 3 canali di advertising broadcasting.

- La parte di advertising: Si inverte (non c'è più un master che fa enquiring), è lo slave che dice _ci sono_ sui canali di advertising.

#nota()[
  Rimane la completa non sincronizzazione del sistema.
]

L'advertising viene fatto nel seguente modo:
- punto di inizio (dispositivo che vuole essere scoperto)
- il tempo di advertising è l'intervallo tra due advertising, composto da:
$
  T_"advEvent" = "advInterval" + "advDelay"
$
Dove:
- advInterval è interno al dispositivo. In base alla scelta del tempo intervallo di adv influisce anche sul consumo di batteria
- advDelay, numero random tra $0$ e $10"ms"$. In questo modo riduciamo la possibilità di collisioni (probabilità molto basse).

Non ci sono garanzie di latenza (a causa del delay random)
#nota()[
  Bluetooth energy non ha requisiti sulla latenza, no real time.
]

=== GATT

La gestione dei profili è gestita dal GATT, i profili sono specifici e dicono cosa fa il dispositivo, alcuni profili sono:
- BCS
- CSCP

#nota()[
  Un dispositivo può includere più profili, non sono esclusivi
]

=== GAP

Gestisce lo stato del dispositivo a un livello più alto. Si tratta di una versione più vicina al software. Possiamo accedere alla connessione Bluetooth tramite:
- Broadcaster: spedisce advertising Bluetooth packet
- Observer: il dispositivo si mette in ascolto sui canali di advertising, ascolta e basta
- Peripheral: un peripheral device opera in slave (advertiser) vuole essere scoperto da un central
- Central: un central device scopre i dispositivi slave

//aggiungere immagine e riguardare
(specchiato rispetto a Bluetooth). A livello link layer, durante la fase di connessione troviamo i seguenti stati (l'obiettivo è creare una comunicazione unicast per scambiare messaggi):
- il dispositivo che vuole essere scoperto (slave), usa periodicamente i canali advertise.
- il dispositivo scanner, ascolta questi canali.
- Una volta che ricevo un messaggio rispondo sempre su quel canale, se non ricevo risposta cambio canale.
- Dopo aver connesso lo slave, viene comunicato l'hop dall'initiator diventando un client

il master svolge il ruolo di client per capire se lo slave si è collegato.

=== Comunicazione broadcast

In questo caso abbiamo un host che vuole fare broadcasting (si tratta di un broadcaster). Il dispositivo viene identificato come broadcaster. Chi vuole ascoltare si mette in modalità observer ricevendo le informazioni, solamente chi è nel raggio di comunicazione le riceve.

L'observer scandaglia solamente i $3$ canali di observer. Non c'è risposta della ricezione delle informazioni, è solamente un ascolto passivo.

=== Passive and Active scanning

// riguardare

= ZigBee

Vogliamo affidabilità e basso costo. Inoltre vogliamo lunga durata della batteria (anni).\
Vogliamo avere una bassa complessità (tanti dispositivi che consumano poco), inoltre usiamo la banda ISM per non pagare licenze.

Vogliamo avere un alto numero di nodi (a differenza della piconet) e interoperabilità tra vendors.

Diversi tipi di funzionalità:
- FFD
- Router FFD
- EndDevice RFD

Scambi di dati permessi:
- Dati periodici: invio periodico di dati, tipo i sensori (come ad esempio dispositivi smart ecc)
- Dati intermittenti asincroni: tipo un'applicazione. Sono stimoli esterni (interruttore).
- Dati ripetitivi e a bassa latenza (Allocazione di time slot)

== Architettura

La parte rossa rimane fissa (segue lo standard).
Lo standard $802.15.4$ specifica la tipologia di modulazione e di spread spectrum per 3 bande:
- Spread factor: sequenza di bit casuale messa in xor con il bit che vogliamo trasmettere.
- chip rate: bit mandati effettivi su quelli utili
- la modulazione è $"BPSK"$, 1 chip per simbolo oppure $"O-QPSK"$ possiamo avere 2 chip per simbolo

Il data rate è al massimo $250 "Kbps"$ è $1/4$ del data rate di un Bluetooth, molto basso. Per l'utilizzo che ne andremo a fare è più che sufficiente.

== Livello MAC

Dobbiamo introdurre il concetto di *duty-cycle*. Specifico per ogni device
#informalmente()[
  Se l'obiettivo è di ridurre utilizzo della batteria, tanto vale mantenere la radio in ascolto e in trasmissione. Andiamo a scegliere dei tempi di spegnimento a seconda del tipo di dispositivo e in base al suo ruolo nella rete.
]
C'è sempre un coordinatore, ma in un caso:
- gestione basata su beacon. Non c'è TDMA ma usiamo CSMA/CA. In wireless non si può fare multiple detection non posso trasmettere e sentire cosa trasmetto, devo prevenire le collisioni.
- sorta di broadcast dal coordinatore.

Le possibilità di gestione di CSMA/CA sono:
- Unslotted CSMA/CA
- Slotted CSMA/CA richiede utilizzo dei beacon (il coordinatore emette messaggi di coordinazione periodicamente).

=== CSMA/CA

Il coordinatore invia periodicamente dei beacon. Deve essere concordata a priori la frequenza inoltre c'è una deriva del clock abbastanza importante. Serve per:
- sincronizzazione i vari dispositivi

- vogliamo organizzare la comunicazione nella rete, tenendo in considerazione che ci sono device che comunicano periodicamente, device che comunicano in modo asincrono ecc

- gestione della comunicazione indiretta. Problema, se io coordinatore devo inviare dei dati a dei dispositivi (avendo la lista di quelli mancanti), all'interno del beacon lo comunico. Il dispositivo che riceve il beacon sa se è dentro o no alla lista di dispositivi che deve ricevere, in tal caso deve lasciare la radio accesa. Se non devo ascoltare e non devo mandare nulla posso spegnere la radio

//aggiungere immagine
Il beacon ha la seguente struttura, viene detto *super-frame*. Esso va da un beacon a un altro beacon (copre tutto l'intervallo temporale). Il super-frame è diviso in due:
- La prima metà è attiva. A sua volta divisa in due:
  - CFP (contention free period) contiene GTS guaranteed time slot. Contiene tutti i time slot garantiti. Il coordinatore ha già allocato time slot per certi dispositivi. Se qualche dispositivo ha chiesto dei canali con garanzie sulla latenza vengono utilizzati questi canali.
  - CAP (contention access period). Diviso in time slot in contesa, tutti i dispositivi competono per accedere a questa parte di slot.

- La seconda metà è inattiva. Nessun messaggio viene comunicato, tanto è più grande la parte inattiva più risparmio energia. Prende il nome di slotted CSMA/CA

La durata delle varie parti viene comunicata la struttura del superframe attraverso il beacon, nel seguente modo:
- Beacon interval: quanto passa da beacon a beacon

- Durata minima detta aBaseSuperFrameDuration. Definito dallo standard come una trasmissione di $960$ simboli. Si tratta di una unità fondamentale, unità di durata di un super-frame.

- Durata della parte attiva indicata da $"aBSD" * 2^"SO"$, dove _SO_ è il super-frame order e sono $2$ byte massimo.

- Abbiamo un altro numero che è il beacon order $"BO"$. Esso determina quanto è il Beacon interval = $"aBSD" * 2^"BO"$. Anche questo è di $2$ byte.

All'interno del beacon dobbiamo comunicare $"BO"$ e $"SO"$. Dati questi due numeri possiamo capire quanto è lunga la parte attiva e quanto la parte inattiva. Il duty-cycle è dato da:
$
  "duty-cycle" = 2^"SO" / 2^"BO"
$

super-frame specification:
- Beacon Order: Serve sapere ogni quanto aspettarci un beacon, quanto devo aspettare per il prossimo beacon (o il primo beacon, riguardare)
- SO: quanto è grande la parte attiva
- Final Cap slot: indica in che punto termina il CAP. Il CAP non può sforare nel contention free period in quanto sono comunicazioni riservate già allocate.
- Reserved:
- PAN Coordinator: se il dispositivo è un coordinatore PAN.
- Association permit: bit di controllo

La grandezza di CAP e CFP è data dal numero totale di simboli (da $2^0$ a $2^14$) successivamente prendo il numero di simboli di SD e lo divido in 16 parti uguali. Quello è il tempo interno alla comunicazione, divido in slot la parte in contesa.

//aggiungere somma
Il GTS è un contratto che il coordinatore ha fatto con i dispositivi, per garantire di parlare senza interferenze in un certo slot. La durata degli slot condivisi dipende da quanti simboli ho diviso 16.

=== Come avviene l'accesso a CAP

Il livello fisico (CS) ascoltiamo la portante e sentiamo se qualcuno sta comunicando. Il livello fisico mette a disposizione la CCA per capire se il canale è libero (ascolta per intervalli brevi in quanto costa). Viene tenuta una sorta di variabili interne (ogni dispositivo):
- NB = numero di backoff, Inizialmente è a zero (ottimista) e al massimo è $4$. Se l'operazione non va a buon fine, viene comunicato al livello superiore che la connessione non è avvenuta dopo 4 tentativi

- BE: periodo di backoff per riprovare la connessione, numero di contention slot che dobbiamo aspettare per comunicare. Serve per disallinearsi in quanto tutti siamo allineati alla ricezione del beacon.

- CW: quante volte devo osservare il canale e quante luci verdi devo avere dal livello fisico per trasmettere (numero di slot consecutivi liberi)

#esempio()[
  Trasmissione con successo in contesa (CSMA/CA):
  - slot condivisi
  - ascoltiamo il canale
  - no collisioni (trasmissione assieme)

  Prima di chiedere se è libero, andiamo ad attendere un numero casuale [0,7] e lo moltiplichiamo per 20 simboli

  chiamiamo 2 volte CCA, se è libero entrambe le volte aspetto 5 slot da 20 simboli (CCA). La CW è a 1, dobbiamo ritestare con due CCA consecutive (nello slot di contesa successivo), siccome ottengo ok, allora CW = 0 e posso iniziare a trasmettere.

  Quando CW = 0 posso iniziare a trasmettere. Chi ascolta nel momento successivo sentirà il canale occupato.

  Canale occupato:
  - il secondo CCA non va a buon fine. La CW viene reimpostata a 2 e NB=1 e BE=4, viene aumentato l'esponente (scelgo tra un numero maggiore di numeri random per aumentare la probabilità di differenziarci).
  - Aspetto un altro numero di slot random
  - Non tengo accesa la radio. Se mi accorgo che il canale è occupato non ascolto per tutto il periodo di back-off ma calcolo un altro numero di slot spegnendo la radio.
  - il CS viene fatto solo per un periodo limitato di tempo (salva batteria ma perdo occasioni).

  #nota()[
    Non ho bisogno di bassa latenza o qualità di servizio
  ]

  Più in là nel tempo si va (dal beacon all'inizio del Contention free-period) potrei finire oltre al tempo messo a disposizione del CAP. Per evitare di continuare a sparare un numero random (molto alto) e sapendo che siamo oltre ai limiti del CAP, allora blocco il timer e al beacon successivo parto da quel numero (rimaniamo in una sorta di coda). Quando riprende il conteggio riparto da BE precedente altrimenti partendo da zero rischierei di avere una starvation del dispositivo.

]

//aggiungere tempo d Turn around
