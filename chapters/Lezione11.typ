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

+ Il segnale trasmesso era $phi$, quello ricevuto è $phi + psi$ (cambia di una certa sfasatura). Per capire quanto è *sfasato* rispetto al segnale originale, viene effettuata una *channel estimation*: Stima dello sfasamento dovuto alle condizioni del canale. Viene utilizzato un *pilota* (simbolo noto) per stimare lo sfasamento $psi$

+ Conversione da simbolo a bit tramite demodulazione inversa (QPSK, 16-QAM, 64-QAM)

Le codifiche utilizzate in LTE sono principalmente:
- *BPSK (Binary Phase Shift Keying)*: modulazione a 2 simboli. Utilizzata per alcuni *segnali di controllo* a basso livello (fondamentale riceverli)
- *QPSK (Quadrature Phase Shift Keying)*: modulazione a 4 simboli. Usata per *messaggi di controllo* e per la trasmissione dati in condizioni sfavorevoli, garantisce robustezza.
- *16/64-QAM (Quadrature Amplitude Modulation)*: modulazione a 16 simboli. Usata per la *trasmissione dati* in condizioni di canale migliori, offre maggiore efficienza spettrale.

#nota()[
  La scelta della modulazione e delal codifica è dinamica. Tale scelta è rappresentata da un numero su $4$ bit: *CQI (Channel Quality Indicator)*,  indica il numero di bit di informazione su $1024$ bit. Tale indice viene inviato dall'UE all'eNodeB. Un CQI più alto indica condizioni di canale migliori, permettendo l'uso di modulazioni più efficienti (16/64-QAM). Un CQI più basso indica condizioni peggiori, richiedendo modulazioni più robuste (QPSK).
]

=== Riuso frequenze

LTE adotta una strategia di *riuso delle frequenze* molto più aggressiva rispetto alle tecnologie precedenti. L'idea è utilizzare il $100%$ delle frequenze disponibili (come in 3G). La gestione delle interferenze è coordinata tra le celle attraverso l'*interfaccia X2*, permettendo un'efficiente condivisione dello spettro.

Le frequenze vengono coordinate ai bordi delle celle adiacenti. In particolare, la banda viene divisa in due:
- *Parte centrale* (centro cella): usata tutta la banda, in quanto l'interferenza è minima
- *Parte periferica* (bordo cella): diverse celle adiacenti usano frequenze diverse per ridurre l'interferenza. La *banda* è *divisa in parti* per celle adiacenti.

#esempio()[
  #figure[
    #align(center)[
      #cetz.canvas(length: 1cm, {
        import cetz.draw: *

        // Funzione per disegnare un esagono centrato in (x, y) con raggio r
        let hexagon(x, y, r, fill-color, label) = {
          let angle = 60deg
          let points = range(6).map(i => (
            x + r * calc.cos(angle * i),
            y + r * calc.sin(angle * i),
          ))

          // Disegna l'esagono
          line(..points, close: true, fill: fill-color, stroke: 2pt + black)

          // Label per la cella
          content((x, y + 0.5), text(size: 12pt, weight: "bold", label))
        }

        // Funzione per disegnare una zona interna (cerchio)
        let inner-zone(x, y, r, fill-color, label) = {
          circle((x, y), radius: r, fill: fill-color.lighten(40%), stroke: 1pt + black)
          content((x, y), text(size: 10pt, weight: "bold", label))
        }

        // Colori per le diverse bande
        let color-a = rgb("#FF6B6B") // Rosso
        let color-b = rgb("#4ECDC4") // Turchese
        let color-c = rgb("#FFE66D") // Giallo
        let color-all = rgb("#95E1D3") // Verde chiaro per il centro

        // Posizioni degli esagoni in configurazione a nido d'ape
        let h = calc.sqrt(3) * 4 // Altezza verticale tra centri
        let w = 3 // Larghezza orizzontale tra centri

        // Cella 1 (centro)
        hexagon(-1.5, 1.8, 2, color-a, "Cella 1")
        inner-zone(-1.5, 1.8, 1.2, color-all, "A+B+C+D")
        content((-1.5, 0.4), text(size: 9pt, fill: color-a.darken(40%), "Bordo: A"))

        // Cella 2 (destra)
        hexagon(4.5, 1.8, 2, color-b, "Cella 2")
        inner-zone(4.5, 1.8, 1.2, color-all, "A+B+C+D")
        content((4.5, 0.4), text(size: 9pt, fill: color-b.darken(40%), "Bordo: B"))

        // Cella 3 (alto-destra)
        hexagon(w / 2, h / 2, 2, color-c, "Cella 3")
        inner-zone(w / 2, h / 2, 1.2, color-all, "A+B+C+D")
        content((w / 2, h / 2 - 1.5), text(size: 9pt, fill: color-c.darken(40%), "Bordo: C"))


        // Legenda
        rect((-0.2, 0.0), (3.5, -2.2), stroke: 1.5pt + black)
        content((0.9, 0.2), text(size: 10pt, weight: "bold", "Legenda FFR"))

        circle((0.3, -0.4), radius: 0.2, fill: color-all.lighten(40%), stroke: 1pt + black)
        content((2, -0.4), text(size: 9pt, "Centro: Tutte le bande"))

        circle((0.3, -0.9), radius: 0.2, fill: color-a, stroke: 1pt + black)
        content((1.7, -0.9), text(size: 9pt, "Bordo: Banda A"))

        circle((0.3, -1.4), radius: 0.2, fill: color-b, stroke: 1pt + black)
        content((1.7, -1.4), text(size: 9pt, "Bordo: Banda B"))

        circle((0.3, -1.9), radius: 0.2, fill: color-c, stroke: 1pt + black)
        content((1.7, -1.9), text(size: 9pt, "Bordo: Banda C"))
      })
    ]
  ]




  // ...existing code...

  In una configurazione FFR con $3$ celle:
  - Banda totale: $20$ MHz divisa in $4$ parti (A, B, C, D)
  - Cella 1 centro: usa A+B+C+D a potenza normale
  - Cella 1 bordo: usa solo A a potenza elevata
  - Cella 2 bordo: usa solo B a potenza elevata
  - Cella 3 bordo: usa solo C a potenza elevata
  - Le celle vicine non interferiscono al bordo usando frequenze diverse
]


=== Durata Simboli

La struttura temporale di LTE è basata su *simboli OFDM* con *durata fissa*.

#nota()[
  In LTE, i dati non vengono inviati tutti in un unico _grande flusso_, ma vengono divisi in tanti _flussi più piccoli_ che viaggiano in parallelo, chiamati sottoportanti. L'OFDM (Orthogonal Frequency-Division Multiplexing) è la tecnica che crea e gestisce queste sottoportanti.
]

La durata di un simbolo è decisa in base a due parametri principali:
- *$Delta f$* (spaziatura tra le sottoportanti): $15$ kHz per evitare interferenze tra le sottoportanti
- *Punti $"FFT"$*: punti da campionare per la trasformata di Fourier, tipicamente $2048$ per una banda di $20$ MHz

La frequenza di campionamento è data da:
$
  f_s = 2048 * 15000 "Hz" = 30.72 "MHz"
$
Il processore del livello fisico compie $30.72$ milioni di operazioni al secondo. L'unita di tempo base *$T_s$* (la durata di un singolo campione) è quindi:
$
  T_s = 1 / (underbrace(2048 * 15000 "Hz", f_s)) s tilde.eq 32.6 "ns"
$
Un simbolo OFDM, necessita di $2048$ campioni, quindi:
$
  T_u = 2048 * T_s tilde.eq 66.67 mu s
$

*Cyclic Prefix (CP)*: Il CP è una *copia della parte finale* del simbolo OFDM inserita all'inizio dello stesso simbolo. Il suo scopo principale è quella di *prevenire l'interferenza inter-simbolo* (ISI) causata da riflessioni multiple del segnale (multipath) e di mantenere l'ortogonalità tra le sottoportanti.

#nota()[
  Il CP è un *overhead necessario*. Esso occupa tempo ma non trasporta informazione. Tipicamente rappresenta circa il $7%$ dell'overhead temporale. Tuttavia, senza CP, l'OFDM non funzionerebbe in ambienti con multipath.
]

Esistono anche due varianti del cyclic preficx, *normal* ed  *extended CP*:
- *Normal CP*: usato nella maggior parte dei casi
  - Minore overhead ($7%$)
  - Adatto per celle fino a $15$ km di raggio
- *Extended CP*: usato in ambienti con dispersione temporale elevata
  - Maggiore overhead ($25%$)
  - Necessario per celle grandi o ambienti con forte multipath

I simboli sono organizzati in *slot* da $0.5$ ms, che contengono $7$ simboli OFDM (con CP normale) o $6$ simboli (con CP esteso). A loro volta gli slot sono organizzati in *subframe* da $1$ ms (2 slot) e in *frame* da $10$ ms (10 subframe).


=== Duplex

Per la gestione della comunicazione bidirezionale, ogni eNodeB può essere configurato in $2$ modalità comunicate dall'utente (UE) al momento della fase di configurazione:
- *FDD* (Frequency Division Duplex): uplink e downlink usano bande di frequenza separate.
- *TDD* (Time Division Duplex): uplink e downlink condividono la stessa banda di frequenza

==== FDD (Frequency Division Duplex)

Tramite questa modalità è possibile trasmettere simultaneamente in uplink e downlink. Tuttavia, è necessario disporre di due bande di frequenza separate (paired spectrum), una per l'uplink e una per il downlink. Inoltre, è necessario inserire dei *gap di guardia* tra le bande per prevenire interferenze.

Un frame di $10$ ms è diviso in
- $10$ sub-frame da $1$ ms ciascuno
- ogni sub-frame contiene $2$ slot da $0.5$ ms
#figure[
  #align(center)[
    #cetz.canvas(length: 0.8cm, {
      import cetz.draw: *

      // Dimensioni
      let frame-width = 14
      let frame-height = 1
      let slot-width = frame-width / 20
      let subframe-width = frame-width / 10

      // Disegna il frame principale
      rect((0, 0), (frame-width, frame-height), stroke: 2pt + black)

      // Disegna i sub-frame (10 sub-frame per frame)
      for i in range(10) {
        let x = i * subframe-width
        if i > 0 {
          line((x, 0), (x, frame-height), stroke: 2pt + black)
        }
      }

      // Disegna gli slot (linee tratteggiate, 2 slot per sub-frame)
      for i in range(1, 20) {
        let x = i * slot-width
        line((x, 0), (x, frame-height), stroke: (paint: black, thickness: 1pt, dash: "dashed"))
      }

      // Etichetta frame principale (sopra)
      content((frame-width / 2, frame-height + 0.8), text(size: 11pt, [1 frame $(10 "ms" = 307 space 200 space T_s)$]))

      // Freccia sopra il frame
      line(
        (0, frame-height + 0.4),
        (frame-width, frame-height + 0.4),
        mark: (end: ">", start: ">"),
        stroke: 1.5pt + black,
      )

      // Etichetta sub-frame (sotto a sinistra)
      line((0, -0.4), (subframe-width, -0.4), mark: (end: ">", start: ">"), stroke: 1.5pt + black)
      content((subframe-width / 2, -0.8), text(size: 10pt, [1 sub-frame $(1 "ms" = 30 space 720 space T_s)$]))

      // Etichetta slot (sotto a destra)
      let slot-pos = frame-width - slot-width
      line((slot-pos, -0.4), (slot-pos + slot-width, -0.4), mark: (end: ">", start: ">"), stroke: 1.5pt + black)
      content((slot-pos + slot-width / 2, -0.8), text(size: 10pt, [1 slot $(0.5 "ms" = 15 space 360 space T_s)$]))
    })
  ]
]
Siccome ogni slot contiene dai $6$ ai $7$ simboli OFDM il numero totale di simboli per sub-frame è di $14$ (con CP normale) o $12$ (con CP esteso). Mentre il numero *totale di simboli per frame* è:
$
  underbrace(10, "subframe") * underbrace(2, "slot") * underbrace(7, "simboli" \ "per slot") = 140 "simboli" ("CP normale")
$

- *$mg("Vantaggio")$*: bassa latenza, trasmissione continua
- *$mr("Svantaggio")$*: richiede più spettro (due bande)
- *Uso tipico*: deployment commerciali più comuni (Europa, USA)


==== TDD (Time Division Duplex)

Tramite questa modalità, la trasmissione avviene in *momenti diversi* (time-multiplexed) sulla *stessa banda di frequenza*. Ciò permette di utilizzare una sola banda (unpaired spectrum), ma richiede una sincronizzazione temporale precisa tra le celle per evitare interferenze.

- *$mg("Vantaggio")$*: maggiore efficienza spettrale, una sola banda necessaria
- *$mr("Svantaggio")$*: richiede sincronizzazione temporale precisa tra celle
- *Flessibilità*: il rapporto DL/UL può essere configurato dinamicamente
- *Uso tipico*: Cina, India, alcuni paesi europei per bande specifiche

#informalmente()[
  La scelta tra FDD e TDD dipende principalmente da due fattori: lo spettro disponibile (paired vs unpaired) e il tipo di traffico previsto. FDD è più semplice ma richiede più spettro; TDD è più flessibile ma richiede sincronizzazione precisa.
]

LTE TDD definisce $7$ *configurazioni* UL/DL diverse:
#align(center)[
  #image("../assets/frame-TDD.png", width: 60%)
]

Le barre bianche nell'immagine rappresentano il *guard time*. Esso serve per:
- Permettere allo switch di cambiare tra TX (tramissione) e RX (ricezione)
- Compensare il propagation delay (distanza tra eNodeB e UE)
- Prevenire interferenze tra uplink e downlink

Il guard time tiene conto dell'*anticipo di trasmissione* in Uplink (Uplink Timing Advance): L'UE inzia a trasmettere in anticipo rispetto al tempo del frame stabilito per la ricezione. Questo fenomeno avviene in quanto la ricezione potrebbe avvenire in maniera disalineata: dispositivi lontani ci mettono più tempo a far arrivare il segnale.

Per questo motivo viene fornito un *timing advance* tra $0$ e $667 mu s$ per compensare la distanza. Il requisito è che *nessuno stia parlando in downlink*, altrimenti si avrebbero delle interferenze. Per questo motivo viene utilizzato il *guard time*: serve a permettere l'advance per l'uplink senza interferenze.

#nota()[
  Il *timing advance* garantisce che, anche con differenze dovute alla propagazione, i simboli arrivino entro il cyclic prefix, mantenendo la divisione in slot temporali.
]

=== Orthogonal Frequency Division Multiple Access (OFDMA)

In LTE gli eNodeB usano la tecnica di trasmissione e recezione chaiamta *OFDMA (Orthogonal Frequency Division Multiple Access)*. Si tratta di un'evoluzione di OFDM che permette l'accesso multiplo, permettendo a *più utenti* di trasmettere simultaneamente:

L'idea è dividere la banda in piccole *sotto-bande* (sub-carries) le cui frequenze non interferiscono tra loro (ortogonalità). In questo modo, è possibile trasmettere più flussi dati in parallelo, aumentando il throughput complessivo. LTE usa sotto-bande di ampiezza $15$ kHz, che corrisponde alla spaziatura minima per garantire l'ortogonalità tra le sottoportanti.

Le sotto-bande a loro volta vengono raggrupate in *Resource Block* (RB), essi rappresentano la *minima quantità di risorse* radio allocabili ad un singolo dipsositivo (UE). Solitamente un RB è composto da $12$ sottoportanti (180 kHz) e dura $0.5$ ms (1 slot) ovvero $7$ simboli OFDM.

#esempio()[
  Se sei l'Utente $A$ e deve mandare un semplice messaggio di testo, lo Scheduler darà come minimo $1$ Resource Block. Questo significa che in un simbolo OFDM ci saranno $12$ sottoportanti dedicate all'utente $A$.
]


Gli step per la trasmissione con OFDMA sono:
+ Ogni flusso di bit distinto viene trasformato in simboli tramite modulazione (QPSK, 16-QAM, 64-QAM)

+ I simboli vengono mappati sulle sottoportanti (sub-carriers) in base alla schedulazione dell'eNodeB

+ Viene applicata la IFFT (Inverse Fast Fourier Transform) per convertire il segnale da dominio della frequenza a dominio del tempo (dalle armoniche alle onde temporali, ovvero la sinusoide modulata)

+ I campioni temporali paralleli vengono ricombinati in un unico flusso seriale

+ Si aggiunge il prefisso ciclico

+ Il segnale viene convertito in analagoico e trasmesso

Lato *ricevitore* bisogna fare il processo contrario, estraendo il flusso di bit per l’UE che sta ricevendo (vengono considerati solo i resource block a lui dedicati), correggendo il flusso dal rumore e sfasamento (tramite channel estimation).

#align(center)[
  #image("../assets/OFDMA.png", width: 80%)
]

Il grafico presenta due assi:
- L'*asse delle frequenze* (orizonatale). Mostra come il segnale è strutturato in sottoportanti ortogonali:
  - Ogni onda a campana, rappresenta una sottoportante spaziate tra di loro di $15$ kHz in modo da garantire l'ortogonalità

  #nota()[
    Il picco massimo di una campana cade esettamente nei punti di zero delle campane vicine, garantendo così che *non* ci sia interferenza tra le sottoportanti.
  ]
  - *FFT bins* (barra): L'algoritmo FTT prende il segnale continuo e lo divide in campioni discreti, ognuno rappresentato da un bin (2048 punti). Ogni bin corrisponde alle informazioni di una sottoportante specifica.

  - Channel bandwidth (linea tratteggiata): rappresenta la banda totale disponibile (somma delle sottoportanti). Inoltre l'intera riga orrizontale forma esattamente un simbolo OFDM.

- L'*asse del tempo* (verticale). Qusta parte mostra come i simboli vengono trasmessi nel tempo:
  - $"Sym"0, "Sym"1, dots$: Rappresentano i simboli OFDM trasmessi in sequenza. Ogni simbolo contiene informazioni su tutte le sottoportanti (tutte le campane) in quel preciso istante di tempo. La durata dell'intera stricia dipende da $T_u = 66.7 mu s$

  - *Guard interval* (linee blue): Essi sono posizionati prima di ogni simbolo OFDM e rappresentano il *cyclic prefix*. La loro funzione è quella di prevenire l'interferenza *inter-simbolo (ISI)* causata da riflessioni multiple del segnale (multipath) e di mantenere l'ortogonalità tra le sottoportanti.

#nota()[
  Ogni FFT Bin rappresenta una *singola sottoportante* (una singola frequenza di 15 kHz). In un certo istante di tempo, sulla sottoportante corrispondente, viene impressa un'onda radio modificata (modulata). La singola onda trasporta un gruppetto di bit. A seconda di quanto è buono il segnale, una singola sottoportante in un singolo simbolo può trasportare 2 bit (modulazione QPSK), 4 bit (16-QAM), 6 bit (64-QAM) e così via, provenienti dallo stesso UE.

  Ogni *simbolo OFDM* è composto dalle onde provenienti da più *UE diversi*, che hanno trasmesso tutti nello stesso identico istante.
]

==== OFDMA Scheduling

Tutte le comunicazioni da e per i dipsositivi $"EUs"$ sono gestite dall'eNodeB. Ogni UE riceve un *sottoinsieme di sottoportanti* oragnizzate in *Resource Blocks* (RB)
- L'eNodeB scheduler assegna dinamicamente i RB agli UE
- Allocazione *sia in frequenza che in tempo*

#esempio()[
  Configurazione OFDMA in LTE $20$ MHz:
  - $1200$ sottoportanti totali ($20 "MHz" \/ 15 "kHz"$)
  - $100$ RB ($12$ sottoportanti ciascuno)
  - In un subframe ($1$ ms):
    - UE1 riceve PRB 0-9 (vicino alla cella, 64-QAM)
    - UE2 riceve PRB 10-14 (media distanza, 16-QAM)
    - UE3 riceve PRB 15-17 (bordo cella, QPSK)
    - PRB 18-99 allocati ad altri UE
]

*Obiettivi dello scheduler*:
- Massimizzare il *throughput* del sistema
- Garantire *fairness* tra gli UE
- *Rispettare i requisiti QoS* dei diversi bearer
- Ottimizzare l'uso dello spettro

Algoritmi di scheduling comuni:
- *Round Robin*: allocazione equa del tempo tra tutti gli UE
- *Max C/I* (Maximum Carrier to Interference): alloca risorse agli UE con il canale migliore
  - Massimizza il throughput totale
  - Può causare unfairness verso UE con canale scarso
- *Proportional Fair*: compromesso tra throughput e fairness
  - Alloca risorse considerando sia la qualità istantanea che quella media del canale:
  $
    text("priorità") = R_"istantaneo" \/ R_"medio"
    $
  - Evita starvation ma mantiene buon throughput

#nota()[
  L'algoritmo di scheduling *non* è specificato dallo standard LTE. Ogni vendor può implementare il proprio algoritmo, permettendo differenziazione e ottimizzazione in base alle esigenze.
]

=== Velocità per UE

La velocità dati effettiva per ciascun UE dipende da molteplici fattori: 
- Capacità del dipsositivo (modulazione supportata, numero di antenne)
- Qualità del segnale (*SINR*): interferenze e distanza dall'eNodeB alterano il coding rate e di conseguenza il throughput
- Larghezza della banda in $"Mhz"$: maggiore è la banda, maggiore è il numero di resource block allocabili
- Configurazaione *TDD* (time division duplex): a seconda della configurazione dell'enodeB, si possono avere differenti velocità in uplink e downlink
- Numero di dispositivi attivi nella cella: più UE attivi = meno risorse per ciascuno
- Altri fattori non dipendenti dal canale radio, come: congestione della rete di backhaul, congestione P-GW

#informalmente()[
  *Throughput*: quantità effettiva di dati che vengono trasmessi con successo attraverso un canale di comunicazione in un determinato periodo di tempo.
]

La massime velocità teoriche per UE in LTE sono:
- *Downlink* (DL): fino a $300$ Mbps con $20$ MHz
- *Uplink* (UL): fino a $75$ Mbps con $20$ MHz



#esempio()[
  Supponiamo di avere una *cella* LTE $20$ MHz con $10$ UE attivi.

  *Calcolo del throughput per UE*:  La formula generale per calcolare il throughput è:
  $
    "Throughput" = N_"RB" times 12 times N_"simboli" times "bit/simbolo" times 1000 times eta
  $
  dove:
  - $N_"RB"$: numero di Resource Block allocati
  - $12$: sottoportanti per RB
  - $N_"simboli"$: simboli OFDM utili per subframe ($14$ con Cycle Period normale)
  - $"bit/simbolo"$: dipende dalla modulazione (QPSK=$2$, 16-QAM=$4$, 64-QAM=$6$)
  - $1000$: subframe al secondo
  - $eta$: efficienza ($tilde.eq 0.75$ considerando overhead per segnali di riferimento e controllo)

  Supponiamo inoltre di avere una configurazione *$2 times 2$ MIMO* (Multiple Input Multiple Output), ovvero $2$ antenne trasmittenti e $2$ riceventi, che raddoppia il throughput in condizioni ottimali.
  
  *UE vicini* ($3$ UE, $15$ RB ciascuno, 64-QAM):
  $
    "Throughput" &= underbrace(mr(15),"RB") times 12 times underbrace(mb(14), "symbol") times underbrace(mg(6), "bit/simbolo") times 1000 times 0.75 \
    &= 15 times 12 times 14 times 6 times 750 \
    &= 11.34 "Mbps"
  $
  Con MIMO $2 times 2$: $11.34 times 2 tilde.eq 22.7 "Mbps"$ → arrotondiamo a $20$ Mbps
  
  *UE medi* ($5$ UE, $8$ RB ciascuno, 16-QAM):
  $
    "Throughput" &= 8 times 12 times 14 times 4 times 1000 times 0.75 \
    &= 8 times 12 times 14 times 4 times 750 \
    &= 4.03 "Mbps"
  $
  Con MIMO $2 times 2$: $4.03 times 2 tilde.eq 8 "Mbps"$
  
  *UE lontani* ($2$ UE, $5$ RB ciascuno, QPSK):
  $
    "Throughput" &= 5 times 12 times 14 times 2 times 1000 times 0.75 \
    &= 5 times 12 times 14 times 2 times 750 \
    &= 1.26 "Mbps"
  $
  Con MIMO $2 times 2$: $1.26 times 2 tilde.eq 2.5 "Mbps"$ → arrotondiamo a $2$ Mbps
  
  *Allocazione totale Resource Block*: 
  $
    (3 times 15) + (5 times 8) + (2 times 5) = 45 + 40 + 10 = 95 "RB"
  $ 
  Su un totale di $100$ RB disponibili
  
  *Throughput totale cella*: 
  $
    (3 times 20) + (5 times 8) + (2 times 2) = 60 + 40 + 4 = 104 "Mbps"
  $ 
]