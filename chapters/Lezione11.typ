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
- *SGSN* (Serving GPRS Support Node): gestisce la mobilità e il routing dei pacchetti nell'area locale. Solitamente c'è un unico nodo locale per una specifica area geografica.
- *GGSN* (Gateway GPRS Support Node): punto di accesso alla rete esterna (internet), assegna indirizzi IP (virtuali e locali) ai dispositivi

=== Tunneling Protocol (GTP)

Siccome un dispositivo è libero di muoversi all'interno della rete può passare da una cella all'altra, questo causa un cambiamento del nodo SGSN di riferimento. Quando un dispostivio entra in una nuova cella, il nuovo SGSN deve comunicare con il GGSN per aggiornare la posizione del dispositivo, aggiornando la sessione *PDP* (Packet Data Protocol) e le tabelle di routing sul percorso. Tuttavia, tale processo di aggiornarmento è oneroso e inefficiente.

Per questo motivo, è necessario un protocollo di tunneling *GTP* (GPRS Tunneling Protocol) per trasportare i pacchetti IP attraverso la rete GPRS, mantenendo la connessione logica indipendente dalla posizione fisica del dispositivo.

#nota()[
  Il tunnel logico viene creato tra SGSN e GGSN.
]

La connessione logica tra dispositivo e GGSN è identificata da una sessione del protocollo *Packet Data Protocol* (PDP). Ogni dipsositivo possiede un proprio IP (unico all'interno della rete), assegnatoli tramite DHCP/NAT. Tale IP è inoltre unico per tutta la durta della sessione.

==== Funzionamento

Il dispostivo movile invia un pacchetto IP con i segunti campi:
- *_Source IP_*: l'indirizzo IP del dispositivo
- *_Destination IP_*: l'indirizzo IP del server di destinazione
- *_Payload_*: i dati da trasmettere

Quando il pacchetto raggiunge il primo nodo SGSN, questo incapsula il pacchetto IP in un pacchetto GTP, aggiungendo un header GTP con i seguenti campi:
- *_TEID_* (Tunnel Endpoint ID): identifica univocamente il tunnel. Composto da:
  - _TEID GGSN_
  - _TEID SSGN_
- *_Strato UDP_*: porta di origine e destinazione (SGSN e GGSN). Solitamente viene usata la porta $2123$ per il controllo e $2152$ per i dati.
- *_Source/Destination IP_*: indirizzi degli endpoint del tunnel (SGSN e GGSN)

Il pacchetto dati è come se viaggiasse incapsulato. I router intermedi non vedono il pacchetto IP originale, ma solo il pacchetto GTP (lo instradano al nodo successivo). Quando il pacchetto raggiunge il GGSN, questo* decapsula* il pacchetto GTP per estrarre il pacchetto IP originale e lo inoltra verso la destinazione finale.

= UMTS

UMTS (Universal Mobile Telecommunications System) rappresenta la *terza generazione* (3G) delle reti mobili. L'obiettivo principale è fornire un servizio dati ad alta velocità mantenendo la compatibilità con le reti 2G esistenti.

*Caratteristiche principali*:
- *Nuove base station*: miglioramento della loro capacità e copertura
- *Wideband CDMA* (W-CDMA): tecnologia di accesso radio completamente nuova
- *Data rate elevato*: fino a $2$ Mbps in condizioni ottimali
- *Supporto multimediale*: videochiamata, streaming, navigazione veloce
- *QoS differenziata*: diverse classi di servizio per traffico real-time e best-effort

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

    #nota()[
      Negli anni, come si può vedere, la seprazione tra modulo di trasmssione $"Node" B$ e modulo di controllo $"RNC"$ è sempre più marcata
    ]

*3. Core Network*:
- *Circuit-Switched domain*: per il traffico voce (eredità da GSM)
- *Packet-Switched domain*: per il traffico dati
  - SGSN: routing e mobilità
  - GGSN: gateway verso internet

#nota()[
  UMTS mantiene una *netta separazione* tra la rete di accesso radio (UTRAN) e la _rete core_, permettendo evoluzioni indipendenti delle due parti.
]

== CDMA in UMTS

UMTS utilizza *W-CDMA* (Wideband Code Division Multiple Access) come tecnologia di accesso multiplo. Tale tecnologia permette a più utenti di condividere la stessa banda di frequenza simultaneamente, distinguendoli tramite dei codici ortogonali univoci. Si ha quindi un *riuso totale delle frequenze* (frequenza unica per ogni cella).

Vengono utilizzati due tipi di *codici*:
- *Channelization codes* (codici OVSF): separano gli utenti all'interno della stessa cella
- *Scrambling codes*: distinguono le diverse celle

*$mg("Vantaggi")$ di CDMA*:
- *Riuso di frequenza*: tutte le celle possono usare la stessa frequenza
- *Soft handover*: il dispositivo può essere connesso a più celle contemporaneamente
- *Resistenza alle interferenze*: grazie ai codici ortogonali
- *Capacità variabile*: si adatta al carico di traffico

#attenzione()[
  In W-CDMA, il fattore limitante è l'*interferenza*: più utenti trasmettono, maggiore è l'interferenza reciproca. Il sistema deve controllare la potenza di trasmissione per mantenere l'SIR (Signal to Interference Ratio) accettabile.
]

== UMTS- Radio Access Bearer

Nel sistema GSM/GPRS, i canali erano definiti in base alla loro funzione e
la loro posizione nello scheduling era predefinita e statica. Ogni canale aveva
un compito specifico e non poteva essere adattato.

In UMTS, invece, i *canali radio sono dinamici* e vengono definiti attraverso una serie di parametri che ne determinano le caratteristiche:
- _Classe di servizio_
- _Velocità massima_
- _Velocità garantita_
- _Ritardo_
- _Probabilità di errore_

= Long Term Evolution 4G LTE

== Core Network . . . . . . . . . . . . . . . . . . . . . . . . . . . 124
=== Mobility Management Entity MME . . . . . . . . . . 124
=== Home Subscriber Server HSS . . . . . . . . . . . . . .
=== Packet Data Network Gateway P-GW . . . . . . . . . 125
=== Serving Gateway S-GW . . . . . . . . . . . . . . . . . 125
=== Policy Control and Charging Rules Function PCRF . 126
=== Servizi operatore . . . . . . . . . . . . . . . . . . . . . 126

== E-UTRAN . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 126
=== Evolved-NodeB eNodeB . . . . . . . . . . . . . . . . . 126
=== Modulazione e Codifica Trasmissione . . . . . . . . . . 126
=== Riuso frequenze . . . . . . . . . . . . . . . . . 129
=== Durata Simboli 129
=== Struttura Slot 129
=== Duplex 130
=== Orthogonal Frequency Division Multiple Access OFDMA13
=== eNodeB Scheduler . . . . . . . . . . . . . . . . . . . . 133
=== Velocità per UE . . . . . . . . . . . . . . . . . . . . . 133
=== Collegamento alla Core Network . . . . . . . . . . . . 134
=== Tracking Area . . . . . . . . . . . . . . . . . . . . . . 134
=== Interfaccia X2 . . . . . . . . . . . . . . . . . 135
