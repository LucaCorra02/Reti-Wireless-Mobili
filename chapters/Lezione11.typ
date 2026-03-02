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
      Negli anni, come si può vedere, la seprazione tra modulo di trasmssione $"Node" B$ e modulo di controllo $"RNC"$ è sempre meno marcata. In 4G LTE, ad esempio, questi due moduli vengono condensati in un unico elemento chiamato *eNodeB*.
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

LTE (Long Term Evolution) rappresenta la *quarta generazione* (4G) delle reti mobili cellulari. L'obiettivo principale è fornire prestazioni significativamente superiori rispetto a UMTS, sia in termini di velocità che di latenza.

*Caratteristiche principali*:
- *All-IP architecture*: eliminazione del dominio circuit-switched, tutto il traffico (voce e dati) viene trasportato su IP
- *Efficienza spettrale*: utilizzo ottimizzato dello spettro radio
- *Mobilità elevata*: supporto per velocità fino a $350$ km/h
- *Accesso al canale*: LTE rappresenta una rottura rispetto alle tecnologie precedenti: abbandona completamente il CDMA in favore di *OFDMA* (Orthogonal Frequency Division Multiple Access) per il downlink e *SC-FDMA* (Single Carrier FDMA) per l'uplink.


#figure[
  #align(center)[
    #cetz.canvas(length: 0.7cm, {
      import cetz.draw: *

      // Stile per i box dei componenti
      let component-box(pos, width, height, label, color: rgb("#87CEEB")) = {
        rect(pos, (pos.at(0) + width, pos.at(1) + height), fill: color, stroke: 1.5pt + black)
        content((pos.at(0) + width / 2, pos.at(1) + height / 2), text(size: 11pt, weight: "bold", label))
      }

      // Posizioni dei componenti
      let ue-pos = (0, 2)
      let enodeb-pos = (3, 2)
      let mme-pos = (7, 4)
      let hss-pos = (10, 5.5)
      let sgw-pos = (9, 2)
      let pgw-pos = (12, 2)
      let pcrf-pos = (15, 4)
      let services-pos = (18, 2)

      // Disegna i componenti
      component-box(ue-pos, 2, 1.2, "UE")
      component-box(enodeb-pos, 2.5, 1.2, "eNodeB")
      component-box(mme-pos, 2, 1.2, "MME")
      component-box(hss-pos, 2, 1.2, "HSS")
      component-box(sgw-pos, 2, 1.2, "S-GW")
      component-box(pgw-pos, 2, 1.2, "P-GW")
      component-box(pcrf-pos, 2, 1.2, "PCRF")

      // Ellisse per i servizi
      circle(
        (services-pos.at(0) + 2.5, services-pos.at(1) + 0.6),
        radius: (2.5, 1),
        fill: rgb("#87CEEB"),
        stroke: 1.5pt + black,
      )
      content((services-pos.at(0) + 2.5, services-pos.at(1) + 0.8), text(size: 9pt, weight: "bold", "Operator's"))
      content((services-pos.at(0) + 2.5, services-pos.at(1) + 0.4), text(
        size: 9pt,
        weight: "bold",
        "IP services (for example,",
      ))
      content((services-pos.at(0) + 2.5, services-pos.at(1) + 0), text(size: 9pt, weight: "bold", "IMS, PSS)"))

      // Linee di connessione (interfacce)
      // LTE-Uu
      line((ue-pos.at(0) + 2, ue-pos.at(1) + 0.6), (enodeb-pos.at(0), enodeb-pos.at(1) + 0.6), stroke: 2pt + black)
      content(((ue-pos.at(0) + enodeb-pos.at(0) + 2) / 2, ue-pos.at(1) - 0.4), text(
        size: 9pt,
        style: "italic",
        "LTE-Uu",
      ))

      // S1-MME (tratteggiata)
      line((enodeb-pos.at(0) + 2.5, enodeb-pos.at(1) + 1), (enodeb-pos.at(0) + 2.5, mme-pos.at(1) + 1.2), stroke: (
        paint: black,
        thickness: 2pt,
        dash: "dashed",
      ))
      line((enodeb-pos.at(0) + 2.5, mme-pos.at(1) + 1.2), (mme-pos.at(0), mme-pos.at(1) + 0.6), stroke: (
        paint: black,
        thickness: 2pt,
        dash: "dashed",
      ))
      content((enodeb-pos.at(0) + 1.5, mme-pos.at(1) + 0.2), text(size: 9pt, style: "italic", "S1-MME"))

      // S1-U (solida)
      line((enodeb-pos.at(0) + 2.5, enodeb-pos.at(1) + 0.6), (sgw-pos.at(0), sgw-pos.at(1) + 0.6), stroke: 2pt + black)
      content(((enodeb-pos.at(0) + sgw-pos.at(0) + 2.5) / 2, sgw-pos.at(1) + 0.2), text(
        size: 9pt,
        style: "italic",
        "S1-U",
      ))

      // S11 (tratteggiata)
      line((mme-pos.at(0) + 1, mme-pos.at(1)), (sgw-pos.at(0) + 1, sgw-pos.at(1) + 1.2), stroke: (
        paint: black,
        thickness: 2pt,
        dash: "dashed",
      ))
      content((mme-pos.at(0) + 1.5, (mme-pos.at(1) + sgw-pos.at(1) + 1.2) / 2), text(size: 9pt, style: "italic", "S11"))

      // S6a (tratteggiata)
      line((mme-pos.at(0) + 1.5, mme-pos.at(1) + 1.2), (hss-pos.at(0), hss-pos.at(1) + 0.6), stroke: (
        paint: black,
        thickness: 2pt,
        dash: "dashed",
      ))
      content(((mme-pos.at(0) + hss-pos.at(0) + 1.9) / 2, hss-pos.at(1) - 0.2), text(size: 9pt, style: "italic", "S6a"))

      // S5/S8 (solida)
      line((sgw-pos.at(0) + 2, sgw-pos.at(1) + 0.6), (pgw-pos.at(0), pgw-pos.at(1) + 0.6), stroke: 2pt + black)
      content(((sgw-pos.at(0) + pgw-pos.at(0) + 2) / 2, sgw-pos.at(1) + 0.2), text(size: 9pt, style: "italic", "S5/S8"))

      // Gx (tratteggiata)
      line((pgw-pos.at(0) + 1.5, pgw-pos.at(1) + 1.2), (pcrf-pos.at(0), pcrf-pos.at(1) + 0.6), stroke: (
        paint: black,
        thickness: 2pt,
        dash: "dashed",
      ))
      content(((pgw-pos.at(0) + pcrf-pos.at(0) + 1.7) / 2, pcrf-pos.at(1) - 0.4), text(
        size: 9pt,
        style: "italic",
        "Gx",
      ))

      // Rx (tratteggiata)
      line((pcrf-pos.at(0) + 2, pcrf-pos.at(1) + 0.6), (services-pos.at(0), services-pos.at(1) + 0.6), stroke: (
        paint: black,
        thickness: 2pt,
        dash: "dashed",
      ))
      content(((pcrf-pos.at(0) + services-pos.at(0) + 2) / 2, pcrf-pos.at(1) + 0.2), text(
        size: 9pt,
        style: "italic",
        "Rx",
      ))

      // SGi (solida)
      line(
        (pgw-pos.at(0) + 2, pgw-pos.at(1) + 0.6),
        (services-pos.at(0), services-pos.at(1) + 0.6),
        stroke: 2pt + black,
      )
      content(((pgw-pos.at(0) + services-pos.at(0) + 2) / 2, pgw-pos.at(1) + 0.2), text(
        size: 9pt,
        style: "italic",
        "SGi",
      ))

      // Linee verticali di delimitazione (tratteggiate)
      line((6, 1), (6, 6), stroke: (paint: gray, thickness: 1pt, dash: "dashed"))
      line((6.2, 5.8), (6.2, 1.2), stroke: (paint: gray, thickness: 1pt, dash: "dashed"))
    })
  ]
]


#nota()[
  Si introduce una separazione a livelli di architettura più marcata rispetto a UMTS, con una *rete di accesso* (E-UTRAN) completamente *indipendente* dalla *rete core* (EPC).
]
L'architettura LTE è divisa in due componenti principali:
- *E-UTRAN* (Evolved UMTS Terrestrial Radio Access Network): rete di accesso radio. A differenza di 3G, non esistono più _Node B_ e _RNC_, tali moduli sono condensati in un unico elemento chiamato *eNodeB* (Evolved Node B).

- *EPC* (Evolved Packet Core): rete core completamente basata su IP

== Core Network

La rete core EPC (Evolved Packet Core) rappresenta un'architettura completamente basata su IP, progettata per gestire esclusivamente traffico a pacchetto. L'EPC è composta da diversi nodi funzionali che gestiscono routing, mobilità, QoS e policy.

#nota()[
  A differenza di UMTS, in LTE *non esiste più* il dominio circuit-switched. Anche la voce viene trasportata su IP tramite tecnologie VoLTE (Voice over LTE) o VoIP.
]

=== Mobility Management Entity (MME)

L'MME è il *nodo di controllo principale* della rete LTE. Si occupa di tutto quello che è il traffico di controllo e segnalazione all'interno della rete core.

#attenzione()[
  Il modulo MME *non* gestisce il traffico dati utente.
]

Funzioni principali:
- *Gestione della mobilità*: tracking dell'UE (User Equipment) e gestione degli handover
- *Autenticazione e sicurezza*: autenticazione dell'utente, generazione e distribuzione delle chiavi di cifratura
- *Gestione dei bearer*: setup, modifica e rilascio dei bearer EPS (Evolved Packet System)
- *Paging*: invio di messaggi di paging agli UE in idle mode
- *Gestione delle Tracking Area*: aggiornamento delle Tracking Area List

#informalmente()[
  L'MME è come il _cervello_ della rete LTE. Esso coordina tutto ciò che riguarda la connessione e la mobilità dell'utente, ma non tocca mai i dati utente che vengono scambiati.
]

=== Home Subscriber Server (HSS)

L'HSS è il *database centrale* che contiene tutte le informazioni relative agli abbonati della rete LTE:
- _Profilo dell'abbonato_: servizi sottoscritti, QoS autorizzata, APN (Access Point Name) consentiti
- _Informazioni di localizzazione_: MME corrente a cui l'utente è registrato
- _Dati di mobilità_: restrizioni di roaming, aree consentite

=== Packet Data Network Gateway (P-GW)

Il P-GW è il *punto di interconnessione* tra la rete LTE e le reti esterne (Internet, IMS per VoLTE, reti aziendali).

Funzioni principali:
- *_Assegnazione indirizzi IP_*: fornisce indirizzi IP agli UE tramite DHCPv4/v6
- *_Routing_*: instrada i pacchetti tra la rete LTE e le reti esterne
- *_Punto di ancoraggio_*: mantiene l'indirizzo IP dell'UE anche durante la mobilità (handover)
- *_Policy enforcement_*: applica le policy di QoS e charging ricevute dal PCRF. Inoltro esegue il *filtraggio dei pacchetti* in base alle regole di sicurezza e in barer differenti in base alle politche di QoS.
- *NAT*: traduzione degli indirizzi per UE con IP privati

#attenzione()[
  Il P-GW è un *punto critico* della rete: tutto il *traffico dati degli utenti* passa attraverso di esso. Per questo motivo, è un elemento che richiede elevate capacità di processing e throughput.
]

*Sessioni PDN* (Packet Data Network):
- Ogni UE può avere *multiple connessioni PDN* simultanee, ciascuna identificata da un diverso APN. Esempio: _una connessione per Internet generale e una per servizi IMS (voce)_
- Ogni PDN connection ha il proprio indirizzo IP e QoS

=== Serving Gateway (S-GW)

L'S-GW è il *gateway di routing locale* che gestisce il traffico dati dell'utente all'interno della rete di accesso. In particolare, si occupa di instradare i pacchetti tra l'eNodeB e il P-GW, mantenendo la connessione dati durante la mobilità dell'utente.

#nota()[
  Gestisce tutti i pacchetti IP degli utenti circolanti nella rete dell'operatore, ma *non* si occupa di instradare i pacchetti verso l'esterno (Internet). Quella è la funzione del P-GW.
]

Funzioni principali:
- *Routing del traffico utente*: instrada i pacchetti tra eNodeB e P-GW
- *Punto di ancoraggio locale*: mantiene il percorso dati durante handover intra-LTE
- *Buffering dei dati*: memorizza temporaneamente i pacchetti quando l'UE è in idle mode

#informalmente()[
  Se il *P-GW* è la _porta verso l'esterno_, l'*S-GW* è il _postino locale_ che si occupa di recapitare i pacchetti all'eNodeB giusto, seguendo l'utente nei suoi spostamenti all'interno della rete.
]

La mobilità del dispositivo all'interno della rete può avere diversi impatti sull'S-GW:

- Durante un *intra-eNB handover* (cambio di cella sotto lo stesso eNodeB): nessun impatto sull'S-GW

- Durante un *inter-eNB handover* (cambio di eNodeB): l'S-GW aggiorna il percorso dati

- Durante un *inter-S-GW handover*: il P-GW rimane l'anchor point, ma il percorso viene riconfigurato

#nota()[
  La separazione tra S-GW (routing locale) e P-GW (gateway esterno) permette di ottimizzare la gestione della mobilità: il P-GW non deve essere cambiato durante la maggior parte degli handover, mantenendo *stabile l'indirizzo IP dell'utente*.
]

=== Policy Control and Charging Rules Function (PCRF)

Il PCRF è il *motore delle policy* che determina come il traffico di ciascun utente deve essere gestito in termini di *QoS* e *charging* in base al profilo HSS dell'utente e alle richieste delle applicazioni.

Funzioni principali:
- *Policy control*: definizione delle regole di QoS (bandwidth, latenza, priorità) per ogni servizio
- *Charging control*: definizione delle regole di tariffazione (flat rate, pay-per-use, ecc.)


#esempio()[
  Quando un utente inizia una videochiamata VoLTE:
  + L'IMS (Application Function) invia una richiesta al PCRF via interfaccia Rx
  + Il PCRF verifica il profilo dell'utente dall'HSS
  + Il PCRF genera delle PCC rules che garantiscono bassa latenza e banda sufficiente
  + Le rules vengono inviate al P-GW
  + Il P-GW configura il traffico secondo le rules ricevute
]

=== Servizi operatore

LTE supporta diversi tipi di servizi attraverso l'architettura EPC:
*Servizi dati*:
- *Internet access*: connessione a Internet tramite APN dedicato
- *Private networks*: accesso a reti aziendali private tramite VPN
- *IMS services*: servizi multimediali (voce, video, messaging)

*VoLTE (Voice over LTE)*:
- Voce trasportata su IP tramite l'IMS (IP Multimedia Subsystem)
- QoS garantita tramite dedicated bearer

*Quality of Service (QoS)*:
- *QoS Class Identifier (QCI)*: 9 classi predefinite (1-9) con caratteristiche diverse
  - QCI 1: VoLTE (GBR, priorità 2, latenza $100$ ms)
  - QCI 2: Video call (GBR, priorità 4, latenza $150$ ms)
  - QCI 9: Internet best effort (non-GBR, priorità 9)
- *GBR* (Guaranteed Bit Rate): bandwidth garantita per traffico real-time
- *Non-GBR*: bandwidth non garantita per traffico best-effort

== E-UTRAN

L'E-UTRAN (Evolved UMTS Terrestrial Radio Access Network) rappresenta la rete di accesso radio di LTE. La principale innovazione è la *flat architecture*: viene eliminato il controller (RNC) presente in 3G.

#nota()[
  In LTE, le funzioni del RNC vengono spostate direttamente negli eNodeB, semplificando l'architettura e riducendo la latenza.
]

=== Evolved-NodeB (eNodeB)

L'eNodeB è la *base station* di LTE, che integra tutte le funzioni di gestione radio.

Funzioni principali:
- *Gestione delle risorse radio*: scheduling di uplink e downlink. Inclusa anche la gestione di più UE (accesso multiplo).
- *Radio Resource Management*: controllo di potenza, ammissione, handover
- *Compressione degli header*: riduzione dell'overhead per i pacchetti IP
- *Cifratura*: encryption dei dati utente
- Connessione con S-GW e MME per traffico dati e controllo

#informalmente()[
  L'eNodeB è come un _orchestratore autonomo_: prende decisioni locali su come allocare le risorse radio senza dover consultare un controller centrale, riducendo così i tempi di risposta.
]

=== Modulazione e Codifica Trasmissione

LTE utilizza tecniche di modulazione e *codifica adattive* per massimizzare l'efficienza spettrale in base alle condizioni del canale radio.

La procedura di *codifica* è la seguente:
+ Codifica dei bit in simboli tramite uno schema di modulazione (QPSK, 16-QAM, 64-QAM)

+ Modulazione usando una *frequenza intermedia* $"IF"$. In LTE questa frequenza viene utilizzata per modulare leggermente la frequenza portante, permettendo di trasmettere più simboli contemporaneamente (OFDMA)

+ Conversione in analogico (DAC)

+ Modulazione della portante RF (Radio Frequency), da banda base a banda traslata sulla portante.

+ Trasmissione

#nota()[
  Il sistema *adatta dinamicamente* la modulazione e il coding rate in base a:
  - *CQI* (Channel Quality Indicator): report inviato dall'UE all'eNodeB sulla qualità del canale
  - *BLER* (Block Error Rate): tasso di errore sui blocchi ricevuti
  - *SINR* (Signal to Interference plus Noise Ratio): rapporto segnale/interferenza
]

In *ricezione* avvengono i seguenti passaggi:
+ Si misura il segnale ricevuto. La misurazione comprende il rumore e lo sfasamento indotto dalla mobilità $psi$.

+ *Demodulazione*: viene rimossa la sequenza portante, tornando così in banda base.

+ Vine rimosso il rumore termico attraverso un filtro passa basso, ottenendo così il segnale digitale (ADC).







*Modulation and Coding Scheme (MCS)*:
- LTE definisce $29$ diversi MCS (da MCS-0 a MCS-28)
- Ogni MCS specifica la combinazione di:
  - Schema di modulazione (QPSK/16-QAM/64-QAM)
  - Code rate (rapporto tra bit informativi e bit totali)
  - Efficienza spettrale risultante

*HARQ* (Hybrid Automatic Repeat Request):
- Ritrasmissione automatica dei blocchi errati
- Combina ARQ (ritrasmissione) con FEC (correzione errori)
- *Soft combining*: i tentativi di ritrasmissione vengono combinati per migliorare la decodifica
- Riduzione della latenza rispetto ad ARQ tradizionale

#nota()[
  HARQ opera a livello MAC, quindi le ritrasmissioni sono gestite direttamente tra eNodeB e UE senza coinvolgere la rete core, minimizzando la latenza.
]

=== Riuso frequenze

LTE adotta una strategia di *riuso delle frequenze* molto più aggressiva rispetto alle tecnologie precedenti.

*Riuso frequenze $= 1$* (Hard Frequency Reuse):
- Tutte le celle utilizzano la stessa banda di frequenza
- Possibile grazie all'ortogonalità delle sottoportanti OFDMA
- *Interferenza inter-cella* gestita tramite:
  - Coordinamento tra eNodeB via interfaccia X2
  - Tecniche di mitigazione dell'interferenza
  - Allocazione intelligente delle risorse

*Fractional Frequency Reuse (FFR)*:
- Tecnica avanzata per gestire l'interferenza al bordo cella
- La banda viene divisa in:
  - *Parte centrale*: usata con piena potenza, riuso $= 1$
  - *Parte periferica*: diversi settori usano frequenze diverse, riuso $> 1$
- Gli UE vicini alla cella usano tutte le frequenze
- Gli UE al bordo cella usano frequenze coordinate per ridurre l'interferenza

#esempio()[
  In una configurazione FFR con $3$ celle:
  - Banda totale: $20$ MHz divisa in $4$ parti (A, B, C, D)
  - Cella 1 centro: usa A+B+C+D a potenza normale
  - Cella 1 bordo: usa solo A a potenza elevata
  - Cella 2 bordo: usa solo B a potenza elevata
  - Cella 3 bordo: usa solo C a potenza elevata
  - Le celle vicine non interferiscono al bordo usando frequenze diverse
]

*Soft Frequency Reuse (SFR)*:
- Variante più flessibile di FFR
- Allocazione dinamica della potenza per sottoportante
- Le sottoportanti del bordo cella vengono trasmesse a potenza più elevata
- Coordinamento inter-cella più sofisticato via X2

*Inter-Cell Interference Coordination (ICIC)*:
- Gli eNodeB si scambiano informazioni via X2 su:
  - Utilizzo delle risorse (quali PRB sono occupati)
  - Livello di interferenza per banda
  - Indicatori di carico della cella
- Permette decisioni di scheduling coordinate per minimizzare l'interferenza

#attenzione()[
  Il riuso frequenze aggressivo (riuso $= 1$) massimizza l'efficienza spettrale ma richiede tecniche avanzate di gestione dell'interferenza. Gli UE al bordo cella sono i più penalizzati e richiedono protezione speciale tramite FFR/SFR.
]

=== Durata Simboli

La struttura temporale di LTE è basata su *simboli OFDM* con durata fissa.

*Parametri temporali*:
- *Durata simbolo OFDM utile*: $T_u = 66.67 \ mu s$
- *Cyclic Prefix (CP)*:
  - *Normal CP*: $4.69 \ mu s$ (primo simbolo), $5.21 \ mu s$ (altri simboli)
  - *Extended CP*: $16.67 \ mu s$ (tutti i simboli)
- *Durata simbolo totale*:
  - Normal CP: $71.35 \ mu s$ (primo), $71.88 \ mu s$ (altri)
  - Extended CP: $83.33 \ mu s$

*Cyclic Prefix (CP)*:
Il CP è una *copia della parte finale* del simbolo OFDM inserita all'inizio dello stesso simbolo.

*Funzioni del CP*:
- *Protezione dal multipath*: assorbe i ritardi dovuti a riflessioni multiple del segnale
- *Mantenimento dell'ortogonalità*: previene l'interferenza inter-simbolo (ISI)
- *Semplificazione dell'equalizzazione*: trasforma la convoluzione lineare in circolare

#nota()[
  Il CP è un overhead necessario: occupa tempo ma non trasporta informazione. Tipicamente rappresenta circa il $7\%$ dell'overhead temporale. Tuttavia, senza CP, l'OFDM non funzionerebbe in ambienti con multipath.
]

*Normal vs Extended CP*:
- *Normal CP*: usato nella maggior parte dei casi
  - Minore overhead ($\sim 7\%$)
  - Adatto per celle fino a $\sim 15$ km di raggio
- *Extended CP*: usato in ambienti con dispersione temporale elevata
  - Maggiore overhead ($\sim 25\%$)
  - Necessario per celle grandi o ambienti con forte multipath
  - Utilizzato anche per MBSFN (Multimedia Broadcast Single Frequency Network)

=== Struttura Slot

La struttura temporale di LTE è organizzata gerarchicamente in frame, subframe e slot.

*Gerarchia temporale*:
- *Radio Frame*: durata $10$ ms
  - Composto da $10$ subframe
- *Subframe*: durata $1$ ms
  - Composto da $2$ slot
  - Unità base per lo scheduling
- *Slot*: durata $0.5$ ms
  - Composto da $7$ simboli OFDM (Normal CP) o $6$ simboli (Extended CP)

*Resource Grid*:
Il *Resource Grid* è la struttura bidimensionale che rappresenta le risorse radio:
- *Asse del tempo*: slot ($0.5$ ms)
- *Asse delle frequenze*: sottoportanti ($15$ kHz di spaziatura)

*Resource Element (RE)*:
- *Unità minima* della griglia: $1$ sottoportante per $1$ simbolo OFDM
- Trasporta un singolo simbolo di modulazione (QPSK/16-QAM/64-QAM)

*Resource Block (RB)*:
- *Unità base di allocazione*
- Dimensioni: $12$ sottoportanti × $7$ simboli OFDM (Normal CP)
- Larghezza: $180$ kHz ($12 times 15$ kHz)
- Durata: $0.5$ ms (un slot)
- Contiene: $84$ RE (con Normal CP)

*Physical Resource Block (PRB)*:
- RB numerato in base alla posizione in frequenza
- L'eNodeB alloca ai diversi UE uno o più PRB
- Numero totale di PRB dipende dalla banda del sistema:
  - $1.4$ MHz: $6$ PRB
  - $3$ MHz: $15$ PRB
  - $5$ MHz: $25$ PRB
  - $10$ MHz: $50$ PRB
  - $15$ MHz: $75$ PRB
  - $20$ MHz: $100$ PRB

#esempio()[
  In un sistema LTE con banda $20$ MHz:
  - Disponibili $100$ PRB per subframe
  - Ogni PRB = $180$ kHz × $1$ ms
  - L'eNodeB scheduler decide quali PRB allocare a ciascun UE
  - Un UE vicino alla cella potrebbe ricevere $10$ PRB con 64-QAM
  - Un UE lontano potrebbe ricevere $5$ PRB con QPSK
]

*Reference Signals (RS)*:
- Alcuni RE all'interno del RB sono riservati per *segnali di riferimento*
- Funzioni:
  - *Stima del canale*: l'UE usa gli RS per misurare la qualità del canale
  - *Sincronizzazione*: aiutano a mantenere la sincronia temporale e di frequenza
  - *CQI measurement*: base per il calcolo del Channel Quality Indicator
- Tipi:
  - *Cell-specific RS*: broadcast da tutte le antenne, usati da tutti gli UE
  - *UE-specific RS*: dedicati a uno specifico UE (beamforming)

#nota()[
  In un RB, tipicamente $4$ RE per antenna sono dedicati ai reference signals. Questo rappresenta un overhead del $\sim 5\%$ delle risorse, ma è essenziale per il funzionamento del sistema.
]

=== Duplex

LTE supporta due modalità di duplexing per separare la trasmissione uplink e downlink.

*FDD (Frequency Division Duplex)*:
- Uplink e downlink utilizzano *bande di frequenza diverse*
- Trasmissione *simultanea* in entrambe le direzioni
- Richiede *due bande separate* (paired spectrum)
- Gaps di guardia tra le bande per prevenire interferenza

*Caratteristiche FDD*:
- *Vantaggio*: bassa latenza, trasmissione continua
- *Svantaggio*: richiede più spettro (due bande)
- *Uso tipico*: deployment commerciali più comuni (Europa, USA)

*Esempi di bande FDD*:
- Band 3: $1805$-$1880$ MHz (uplink), $1710$-$1785$ MHz (downlink)
- Band 7: $2620$-$2690$ MHz (uplink), $2500$-$2570$ MHz (downlink)

*TDD (Time Division Duplex)*:
- Uplink e downlink utilizzano la *stessa banda di frequenza*
- Trasmissione in *momenti diversi* (time-multiplexed)
- Richiede *una singola banda* (unpaired spectrum)

*Caratteristiche TDD*:
- *Vantaggio*: maggiore efficienza spettrale, una sola banda necessaria
- *Svantaggio*: richiede sincronizzazione temporale precisa tra celle
- *Flessibilità*: il rapporto DL/UL può essere configurato dinamicamente
- *Uso tipico*: Cina, India, alcuni paesi europei per bande specifiche

*Configurazioni TDD*:
LTE TDD definisce $7$ configurazioni UL/DL diverse:
- Configurazione 0: $2$ DL : $3$ UL (più uplink)
- Configurazione 1: $3$ DL : $2$ UL
- Configurazione 2: $4$ DL : $1$ UL
- ...
- Configurazione 6: $9$ DL : $1$ UL (più downlink)

#informalmente()[
  La scelta tra FDD e TDD dipende principalmente da due fattori: lo spettro disponibile (paired vs unpaired) e il tipo di traffico previsto. FDD è più semplice ma richiede più spettro; TDD è più flessibile ma richiede sincronizzazione precisa.
]

*Special Subframe (TDD)*:
In TDD, alcuni subframe sono *speciali* e divisi in tre parti:
- *DwPTS* (Downlink Pilot Time Slot): trasmissione downlink
- *GP* (Guard Period): periodo di guardia per lo switching
- *UpPTS* (Uplink Pilot Time Slot): trasmissione uplink

Il GP è necessario per:
- Permettere allo switch di cambiare tra TX e RX
- Compensare il propagation delay (distanza tra eNodeB e UE)
- Prevenire interferenze tra UL e DL

#attenzione()[
  In TDD, la dimensione del Guard Period limita il raggio massimo della cella. Con GP standard, il raggio massimo è circa $15$-$20$ km. Per celle più grandi è necessario usare configurazioni speciali con GP esteso.
]

=== Orthogonal Frequency Division Multiple Access (OFDMA)

OFDMA è la tecnologia di accesso multiplo utilizzata in LTE per il *downlink*. È un'evoluzione di OFDM che permette l'accesso multiplo.

*Principi base OFDM*:
- La banda disponibile viene divisa in molte *sottoportanti ortogonali*
- Spaziatura sottoportanti: $15$ kHz
- Ortogonalità: le sottoportanti non interferiscono tra loro
- Ogni sottoportante trasporta un flusso dati a basso rate
- La somma dei flussi dà il throughput totale elevato

*Vantaggi OFDM*:
- *Resistenza al multipath*: ogni sottoportante ha banda stretta, quindi è poco affetta dalla dispersione temporale
- *Equalizzazione semplice*: equalizzazione nel dominio della frequenza (un coefficiente per sottoportante)
- *Flessibilità*: allocazione granulare delle risorse
- *Efficienza spettrale*: grazie all'ortogonalità, spaziatura minima tra portanti

*OFDMA - Accesso Multiplo*:
OFDMA estende OFDM permettendo a *più utenti* di trasmettere simultaneamente:
- Ogni UE riceve un *sottoinsieme di sottoportanti* (PRB)
- L'eNodeB scheduler assegna dinamicamente i PRB agli UE
- Allocazione *sia in frequenza che in tempo*

#esempio()[
  Configurazione OFDMA in LTE $20$ MHz:
  - $1200$ sottoportanti totali ($20 "MHz" \/ 15 "kHz"$)
  - $100$ PRB ($12$ sottoportanti ciascuno)
  - In un subframe ($1$ ms):
    - UE1 riceve PRB 0-9 (vicino alla cella, 64-QAM)
    - UE2 riceve PRB 10-14 (media distanza, 16-QAM)
    - UE3 riceve PRB 15-17 (bordo cella, QPSK)
    - PRB 18-99 allocati ad altri UE
]

*Scheduling in Frequenza*:
L'eNodeB può sfruttare il *frequency selective scheduling*:
- Misura la qualità del canale per ogni PRB (tramite CQI)
- Alloca a ciascun UE i PRB dove ha il canale migliore
- *Multi-user diversity*: aumenta il throughput complessivo del sistema

#nota()[
  Frequency selective scheduling è particolarmente efficace in ambienti con fading selettivo in frequenza, tipico negli ambienti urbani con multipath ricco.
]

*SC-FDMA per Uplink*:
LTE utilizza *SC-FDMA* (Single Carrier FDMA) invece di OFDMA per l'uplink.

*Motivazione SC-FDMA*:
- *PAPR ridotto* (Peak-to-Average Power Ratio): il segnale SC-FDMA ha un PAPR inferiore rispetto a OFDM
- *Efficienza energetica*: amplificatore di potenza nell'UE può lavorare vicino alla saturazione
- *Durata batteria*: minor consumo energetico nell'UE

*Funzionamento SC-FDMA*:
- I simboli vengono prima *pre-codificati* con una DFT
- Poi mappati su sottoportanti contigue (non sparse)
- Infine, trasmessi usando OFDM

#informalmente()[
  SC-FDMA è come OFDMA ma con un "pre-processing" che rende il segnale più adatto per l'uplink: mantiene i vantaggi di OFDM (resistenza al multipath) ma riduce il PAPR, permettendo agli UE di trasmettere in modo più efficiente dal punto di vista energetico.
]

*Allocazione risorse uplink*:
- Gli UE devono utilizzare PRB *contigui* (non possono saltare frequenze)
- Limitazione necessaria per mantenere le proprietà "single-carrier" di SC-FDMA
- Riduce leggermente la flessibilità di scheduling rispetto al downlink

=== eNodeB Scheduler

Lo scheduler dell'eNodeB è il componente che *decide l'allocazione delle risorse radio* agli UE, sia in downlink che in uplink.

*Obiettivi dello scheduler*:
- *Massimizzare il throughput* del sistema
- *Garantire fairness* tra gli UE
- *Rispettare i requisiti QoS* dei diversi bearer
- *Ottimizzare l'uso dello spettro*

*Scheduling downlink*:
- Lo scheduler decide per *ogni subframe* ($1$ ms):
  - Quali UE trasmettere
  - Quanti PRB allocare a ciascun UE
  - Quale MCS utilizzare per ciascun UE
- Basato su:
  - *CQI reports*: qualità del canale percepita da ciascun UE
  - *Buffer status*: quantità di dati in attesa per ciascun UE
  - *QoS requirements*: priorità, GBR, latency bounds
  - *Fairness metrics*: evitare starvation di UE sfortunati

*Scheduling uplink*:
- Lo scheduler decide per ogni subframe:
  - Grant di risorse (PRB) per ciascun UE
  - MCS da utilizzare
- Basato su:
  - *BSR* (Buffer Status Report): l'UE informa l'eNodeB su quanti dati ha da trasmettere
  - *Power headroom*: potenza disponibile nell'UE
  - *CQI uplink*: stimato dall'eNodeB tramite SRS (Sounding Reference Signals)

*Algoritmi di scheduling comuni*:
- *Round Robin*: allocazione equa del tempo tra tutti gli UE
- *Max C/I* (Maximum Carrier to Interference): alloca risorse agli UE con il canale migliore
  - Massimizza il throughput totale
  - Può causare unfairness verso UE con canale scarso
- *Proportional Fair*: compromesso tra throughput e fairness
  - Alloca risorse considerando sia la qualità istantanea che quella media del canale
  - Formula: $text("priorità") = R_"istantaneo" \/ R_"medio"$
  - Evita starvation ma mantiene buon throughput

#nota()[
  L'algoritmo di scheduling *non* è specificato dallo standard LTE. Ogni vendor può implementare il proprio algoritmo, permettendo differenziazione e ottimizzazione in base alle esigenze.
]

*Scheduling real-time vs best-effort*:
- *Bearer real-time* (VoLTE, video): scheduling prioritario con GBR garantito
- *Bearer best-effort* (web browsing): scheduling opportunistico in base alle risorse disponibili

=== Velocità per UE

La velocità dati effettiva per ciascun UE dipende da molteplici fattori.

*Throughput teorico massimo*:
Per un UE con configurazione ottimale ($20$ MHz, 64-QAM, tutti i PRB allocati):
- $100 "PRB" times 12 "subcarrier" times 7 "symbols" times 6 "bit/symbol" = 50400 "bits/subframe"$
- Considerando 2 anten ne MIMO: $50400 times 2 = 100800 "bits/subframe"$
- Throughput: $100.8 "Mbps"$ per subframe di $1$ ms
- Con overhead e reference signals: throughput effettivo $\sim 75$-$80$ Mbps

*Fattori che influenzano il throughput*:
- *Qualità del canale* (SINR): determina MCS utilizzabile
- *Distanza dall'eNodeB*: path loss influenza SINR
- *Interferenza*: da celle adiacenti (ICIC mitiga questo)
- *Numero di PRB allocati*: dipende dallo scheduler e dal carico della cella
- *Carico della cella*: più UE attivi = meno risorse per ciascuno
- *MIMO configuration*: $2 times 2$, $4 times 4$ aumentano il throughput
- *Carrier Aggregation* (LTE Advanced): combinazione di più bande

*Throughput reale tipico*:
- *Cell center* (SINR alto): $50$-$70$ Mbps in downlink, $20$-$30$ Mbps in uplink
- *Cell edge* (SINR basso): $5$-$15$ Mbps in downlink, $2$-$5$ Mbps in uplink
- *Cell loaded*: throughput diviso tra tutti gli UE attivi

#esempio()[
  Scenario: cella LTE $20$ MHz con $10$ UE attivi
  - UE vicini (3 UE): ricevono $15$ PRB ciascuno, 64-QAM → $\sim 20$ Mbps
  - UE medi (5 UE): ricevono $8$ PRB ciascuno, 16-QAM → $\sim 8$ Mbps
  - UE lontani (2 UE): ricevono $5$ PRB ciascuno, QPSK → $\sim 2$ Mbps
  - Throughput totale cella: $\sim 150$ Mbps
]

*LTE Advanced Pro enhancements*:
- *256-QAM*: aumenta l'efficienza spettrale del $33\%$ rispetto a 64-QAM
- *4×4 MIMO*: raddoppia il throughput in condizioni ottimali
- *Carrier Aggregation*: combina fino a $5$ portanti (fino a $100$ MHz totali)
- Throughput teorico: oltre $1$ Gbps

=== Collegamento alla Core Network

Gli eNodeB si collegano alla rete core EPC attraverso due interfacce distinte.

*Interfaccia S1*:
L'interfaccia S1 connette l'E-UTRAN (eNodeB) alla rete core EPC. È divisa in due parti:

*S1-MME (Control Plane)*:
- Collega eNodeB all'MME
- Trasporta *signaling* (Non-Access Stratum messages)
- Funzioni:
  - Setup e release delle connessioni UE
  - Handover preparation
  - Paging
  - S1 context management
- Protocollo: S1-AP (S1 Application Protocol) over SCTP/IP

*S1-U (User Plane)*:
- Collega eNodeB all'S-GW
- Trasporta il *traffico dati* dell'utente
- Tunnel GTP per ogni bearer di ciascun UE
- Protocollo: GTP-U (GPRS Tunneling Protocol - User plane) over UDP/IP

#nota()[
  La separazione tra control plane (S1-MME) e user plane (S1-U) permette di scalare indipendentemente i due piani. Inoltre, un eNodeB può essere connesso a più MME e S-GW per bilanciamento del carico e ridondanza.
]

*Architettura S1*:
- Un eNodeB può connettersi a *più MME* (S1-flex)
  - Permette load balancing
  - Fornisce ridondanza in caso di failure dell'MME
  - L'eNodeB seleziona l'MME appropriato durante l'attach
- Relazione *many-to-many* tra eNodeB e MME/S-GW
  - Flessibilità nel deployment
  - Ottimizzazione del routing del traffico

*Protocollo Stack S1-MME*:
