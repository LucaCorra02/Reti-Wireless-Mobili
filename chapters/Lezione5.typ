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

