#import "../template.typ": *

= GPRS & EDGE

GPRS (General Packet Radio Service) ed EDGE (Enhanced Data rates for GSM Evolution) rappresentano l'integrazione di GSM con la rete Internet.

#nota()[
  L'obiettivo era mantenere l'infrastruttura radio esistente (base station) modificando solamente la parte software e di core network.

  In questo modo si poteva riutilizzare l'investimento fatto per il 2G aggiungendo capacità di trasferimento dati a pacchetto.
]

== Limitazioni di GSM

La rete GSM era perfetta per trasportare il traffico voce:
- *Bit rate costante*
- *Risorse pre-allocate e riservate*, in quanto ad ogni dispositivo è assegnato un certo time slot. Inoltre, si ha anche un delay costante

Negli anni è stata adattata anche al trasporto di SMS (semplici). Tuttavia, la rete GSM *non* è idonea a supportare il *traffico internet*. Le principali *$mr("criticità")$* sono:
- *Traffico a burst*: il traffico internet è caratterizzato da picchi di attività seguiti da periodi di inattività. GSM alloca risorse in modo fisso, sprecandole durante i periodi di inattività
- *Bit rate variabile*: le applicazioni internet richiedono bit rate variabili in base al tipo di contenuto (video, immagini, testo)
- *Connection-oriented vs packet-switched*: GSM è circuit-switched (connessione dedicata), mentre internet è packet-switched (routing dinamico dei pacchetti)

== GPRS

GPRS introduce il *packet switching* nella rete GSM, permettendo la trasmissione dati su internet mantenendo l'infrastruttura radio esistente.

Caratteristiche principali:
- *Allocazione dinamica delle risorse*: gli slot temporali vengono assegnati solo quando necessario. Inoltre, se un dispositivo è in idle, il time-slot assegnatoli viene rilasciato
- *Condivisione delle risorse*: più utenti possono condividere gli stessi slot in momenti diversi
- *Always-on*: il dispositivo rimane connesso alla rete senza occupare risorse quando inattivo
- *Tariffazione a volume*: si paga per i dati trasferiti, non per il tempo di connessione
- *Connessione (logica)*: Essa non viene rilasciata, vengono rilasciati solo i time-solt radio. Inoltre, la connessione logica è indipendente dalla connessione fisica, la mobilità o la perdità di copertura non interrompe la connessione

#nota()[
  GPRS viene spesso chiamato *2.5G*, in quanto rappresenta un'evoluzione del 2G verso le reti di terza generazione.
]

L'*Architettura* è composta da due moduli principali:
- *SGSN* (Serving GPRS Support Node): gestisce la mobilità e il routing dei pacchetti nell'area locale
- *GGSN* (Gateway GPRS Support Node): punto di accesso alla rete esterna (internet), assegna indirizzi IP (virtuali e locali) ai dispositivi

=== Tunneling Protocol (GTP)

GTP (GPRS Tunneling Protocol) è il protocollo che permette di trasportare i pacchetti IP attraverso la rete GPRS.

#nota()[
  Siccome un dispositivo è libero di muoversi, è necessario un protocollo di tunneling (GTP) per trasportare i pacchetti IP attraverso la rete GPRS, mantenendo la connessione logica indipendente dalla posizione fisica del dispositivo.
]

La connessione logica tra dispositivo e GGSN è identificata da una sessione del protocollo *Packet Data Protocol* (PDP). Il dispositivo è libero di muoversi all'interno della rete. Esso possiede un proprio IP (unico all'interno della rete), assegnatoli tramite DHCP/NAT.

*Funzionamento*:
- L'IP del dispositivo mobile è unico per tutta la sessione PDP.
- I pacchetti IP del dispositivo mobile vengono *incapsulati* in pacchetti GTP.
- Il tunnel GTP viene creato tra SGSN e GGSN
- Permette la mobilità mantenendo lo stesso indirizzo IP anche cambiando cella

#informalmente()[
  Il tunnel GTP è come un _tubo virtuale_ che trasporta i dati del dispositivo attraverso la rete mobile, indipendentemente dalla posizione fisica.
]

*Componenti del tunnel*:
- *Tunnel Endpoint ID* (TEID): identifica univocamente il tunnel
- *Source/Destination IP*: indirizzi degli endpoint del tunnel (SGSN e GGSN)
- *Payload*: i pacchetti IP originali del dispositivo



= UMTS

UMTS (Universal Mobile Telecommunications System) rappresenta la *terza generazione* (3G) delle reti mobili. L'obiettivo principale è fornire un servizio dati ad alta velocità mantenendo la compatibilità con le reti 2G esistenti.

*Caratteristiche principali*:
- *Wideband CDMA* (W-CDMA): tecnologia di accesso radio completamente nuova
- *Data rate elevato*: fino a $2$ Mbps in condizioni ottimali
- *Supporto multimediale*: videochiamata, streaming, navigazione veloce
- *QoS differenziata*: diverse classi di servizio per traffico real-time e best-effort
- *Efficienza spettrale migliorata*: uso più efficiente dello spettro rispetto al 2G

== Architettura

L'architettura UMTS è divisa in tre parti principali:

*1. UE (User Equipment)*:
- USIM (UMTS Subscriber Identity Module): evoluzione della SIM
- ME (Mobile Equipment): il dispositivo mobile

*2. UTRAN (UMTS Terrestrial Radio Access Network)*:
- *Node B*: equivalente della base station in GSM, gestisce la trasmissione radio
- *RNC* (Radio Network Controller): coordina più Node B, gestisce handover e allocazione risorse
  - Controllo di ammissione
  - Gestione della mobilità a livello radio
  - Ottimizzazione delle risorse radio

*3. Core Network*:
- *Circuit-Switched domain*: per il traffico voce (eredità da GSM)
- *Packet-Switched domain*: per il traffico dati
  - SGSN: routing e mobilità
  - GGSN: gateway verso internet

#nota()[
  UMTS mantiene una netta separazione tra la rete di accesso radio (UTRAN) e la rete core, permettendo evoluzioni indipendenti delle due parti.
]

== CDMA in UMTS

UMTS utilizza *W-CDMA* (Wideband Code Division Multiple Access) come tecnologia di accesso multiplo.

*Caratteristiche W-CDMA*:
- *Bandwidth*: $5$ MHz per portante (molto più largo del GSM a $200$ kHz)
- *Chip rate*: $3.84$ Mchip/s
- *Spreading factor*: variabile da $4$ a $256$
  - SF più alto: maggiore robustezza, minor data rate
  - SF più basso: minor robustezza, maggior data rate

*Vantaggi di CDMA*:
- *Riuso di frequenza $= 1$*: tutte le celle possono usare la stessa frequenza
- *Soft handover*: il dispositivo può essere connesso a più celle contemporaneamente
- *Resistenza alle interferenze*: grazie ai codici ortogonali
- *Capacità variabile*: si adatta al carico di traffico

*Codici utilizzati*:
- *Channelization codes* (codici OVSF): separano gli utenti all'interno della stessa cella
- *Scrambling codes*: distinguono le diverse celle

#attenzione()[
  In W-CDMA, il fattore limitante è l'*interferenza*: più utenti trasmettono, maggiore è l'interferenza reciproca. Il sistema deve controllare la potenza di trasmissione per mantenere l'SIR (Signal to Interference Ratio) accettabile.
]

*Power Control*:
- *Fast power control*: aggiustamento della potenza $1500$ volte al secondo
- *Obiettivo*: mantenere tutti i segnali alla stessa potenza alla base station (problema near-far)
- *Closed-loop*: la base station invia comandi di aumento/riduzione potenza

*Data rate in UMTS*:
- *Release 99*: fino a $384$ kbps
- *HSDPA* (High Speed Downlink Packet Access): fino a $14.4$ Mbps in downlink
- *HSUPA* (High Speed Uplink Packet Access): fino a $5.76$ Mbps in uplink
- *HSPA+*: fino a $42$ Mbps in downlink

#nota()[
  HSDPA e HSUPA introducono tecniche avanzate come la *modulazione adattiva* (QPSK/16-QAM) e la *HARQ* (Hybrid Automatic Repeat Request) per migliorare le prestazioni.
]

