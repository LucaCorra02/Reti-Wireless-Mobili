#import "../template.typ": *


=== E-UTRAN collegamento core network

Le varie base station possono non usare la rete core per comunicare, ma possono comunicare in modo peer to peer.

Si tratta di *comunicazione logiche* dipende dal deployment della rete. Nell'immagine può essere realizzata tramite punti radio (canale diretto fisico) oppure usa la tranform network ip. Che è la stessa che porta da rete random a ip.

=== Tracking area

Ogni base station deve sapere i pull che gestiscono la base station.

=== Interfaccia X2

L'interfaccia idue permette la comunicazione diretta tra E-Nodeb, si tratta di un modolo che aggiunge computazionalità aggiuntiva.

Le funzionalità aggiunte sono:
+ Gestione degli handover (convolgere moduli rete core o meno). Tutto il traffico di controllo di un utente da una BS all'altro se la smazzano le due BS direttamente senza rete core.
+ Self-Organized-Network
  - Load balancing
  - Gestione delle interferenze. Se il dipsositivo sul bordo sente male chiede alla base station di finaco di cambiare le frequenze che usa sulo bordo

+ Evitare effetto ping-pong. Viene tenuto uno storico dei dispositivi già visti. Se accetto di nuovo un dispositivo giù visto in precedenza nona avvio la fase di handover.

== Control Plane: Stack Protocollare

Il *control plane* gestisce tutta la segnalazione e il controllo della rete. Lo stack protocollare è organizzato in diversi livelli, ciascuno con funzionalità specifiche.

=== Livelli del Control Plane

*SCTP (Stream Control Transmission Protocol)*:
- Gestisce il trasporto affidabile delle informazioni di controllo a livello L4
- Trasporta i messaggi S1-AP tra eNodeB e MME
- Invia misurazioni, richieste di risorse e comandi di gestione della mobilità
- Fornisce affidabilità e supporto multi-homing

*S1-AP (S1 Application Protocol)*:
- Protocollo a livello applicativo per l'interfaccia S1-MME
- Gestisce procedure di: attach, detach, handover, paging, context management

*PDCP (Packet Data Convergence Protocol)*:
- Permette la convergenza tra diverse applicazioni di livello superiore
- Mappa i flussi applicativi sui canali radio sottostanti
- Esegue compressione degli header IP (ROHC - Robust Header Compression)
- Gestisce la cifratura e l'integrità dei dati

*RLC (Radio Link Control)*:
- Gestisce il link radio (ma non le risorse fisiche)
- *Correzione degli errori* tramite ARQ (Automatic Repeat Request)
- *Segmentazione e riassemblaggio* dei pacchetti in unità di dimensione appropriata
- *Gestione della ritrasmissione* di segmenti persi o corrotti

*MAC (Medium Access Control)*:
- Gestisce l'accesso al canale fisico condiviso
- Esegue lo *scheduling* delle risorse radio (allocazione PRB)
- Multiplexa traffico dati e controllo
- Gestisce l'HARQ (Hybrid ARQ) per ritrasmissioni rapide

#nota()[
  Il mezzo radio è condiviso tra più utenti in modo ortogonale (OFDMA). Lo stack protocollare deve coordinare l'accesso di utenti con canali eterogenei e requisiti QoS diversi.
]

=== Stack Protocollare dell'eNodeB

L'eNodeB implementa un *dual stack*:
- *Stack verso la rete core*: protocolli IP standard (S1-AP/SCTP/IP)
- *Stack radio verso gli UE*: protocolli LTE (PDCP/RLC/MAC/PHY)

L'eNodeB funge da *gateway* tra i due domini, convertendo i messaggi tra le due interfacce.

*Interfaccia S1-MME*:
- Utilizza il protocollo S1-AP sopra SCTP/IP
- Gli indirizzi IP sono *interni alla rete dell'operatore* (IP dell'MME e IP dell'eNodeB)
- Non c'è visibilità dall'esterno: si tratta di una rete privata gestita dall'operatore


=== SCTP: Motivazioni

Perché LTE utilizza *SCTP* invece di TCP per il control plane? Analizziamo le limitazioni di TCP nel contesto LTE.

*Problemi di TCP per il control plane*:

+ *Stream-oriented vs Message-oriented*:
  - TCP è *stream-oriented*: i dati sono visti come un flusso continuo di byte
  - Le applicazioni devono aggiungere *marker* (delimitatori) per identificare i confini dei messaggi
  - Questo introduce *overhead superfluo* in termini di processing e banda
  - Nel control plane LTE, i messaggi hanno confini ben definiti (es. "Handover Request", "Attach Request")

+ *Mancanza di Multi-homing*:
  - TCP crea una connessione univoca tra due endpoint (IP:porta sorgente ↔ IP:porta destinazione)
  - Se uno degli endpoint fallisce, la connessione si interrompe
  - In LTE, un'area è servita da *più MME* per ridondanza e bilanciamento del carico
  - Vogliamo che l'eNodeB possa connettersi a più MME simultaneamente per *fault tolerance*

+ *Head-of-Line (HOL) Blocking*: problema critico per il multiplexing di messaggi di controllo

#nota()[
  Non è possibile usare UDP perché non fornisce *affidabilità*. Il control plane deve garantire la consegna corretta di tutti i messaggi di segnalazione.
]

==== Problema del HOL Blocking in TCP

Il *Head-of-Line (HOL) Blocking* è una limitazione fondamentale di TCP quando si multiplexano messaggi indipendenti.

#esempio()[
  Scenario: trasmissione di 3 segmenti TCP
  + Il segmento $1$ viene perso durante la trasmissione
  + I segmenti $2$ e $3$ arrivano correttamente a destinazione
  + I segmenti $2$ e $3$ *non possono essere consegnati* all'applicazione finché il segmento $1$ non viene ritrasmesso e ricevuto
  
  *Problema*: TCP garantisce la consegna *in ordine* → tutto ciò che segue un segmento perso viene bloccato nel buffer
]

*Impatto in LTE*:

Supponiamo di avere 3 UE diversi (A, B, C) con messaggi di controllo multiplexati su un unico stream TCP:
- UE A: messaggio di handover
- UE B: messaggio di context setup  
- UE C: messaggio di bearer modification

Se il pacchetto TCP contenente il messaggio di A viene perso, *anche i messaggi di B e C sono bloccati*, anche se sono completamente indipendenti!

*Possibili soluzioni con TCP*:

*Soluzione 1*: Una connessione TCP per ogni UE
- *Problema*: overhead insostenibile
- Un eNodeB serve centinaia di UE → centinaia di connessioni TCP
- L'MME serve decine di eNodeB → migliaia di connessioni TCP
- *Non scala*: troppo overhead di memoria e processing

*Soluzione 2*: Usare SCTP → *approccio adottato da LTE*

==== SCTP: Multi-Streaming

SCTP risolve il problema HOL attraverso il *multi-streaming*.

*Concetto*:
- Una singola connessione SCTP può contenere *più stream logici* indipendenti
- Ogni stream ha il proprio *ordinamento FIFO* interno
- I messaggi di stream diversi *non si bloccano a vicenda*
- L'ordine è *parziale* tra stream, ma *totale* all'interno di ogni stream

#esempio()[
  Configurazione SCTP con 3 stream:
  - Stream 0: messaggi per UE A
  - Stream 1: messaggi per UE B  
  - Stream 2: messaggi per UE C
  
  Se un messaggio nello Stream 0 viene perso:
  - Stream 0 attende la ritrasmissione (HOL blocking *locale*)
  - Stream 1 e 2 continuano a consegnare i loro messaggi normalmente
  
  Risultato: i messaggi degli UE B e C non sono bloccati dal problema dell'UE A
]

*Implementazione*:
- SCTP aggiunge un *Stream ID* nell'header di ogni messaggio
- Il ricevitore mantiene buffer separati per ogni stream
- Consegna indipendente per stream

==== SCTP: Multihoming

SCTP supporta il *multihoming*: un endpoint può avere *più indirizzi IP* associati alla stessa connessione.

*In TCP*:
- Connessione identificata da: (IP_src, Port_src, IP_dst, Port_dst)
- Se IP_dst diventa irraggiungibile → connessione fallisce

*In SCTP*:
- Connessione identificata da: ({IP_src1, IP_src2, ...}, Port_src, {IP_dst1, IP_dst2, ...}, Port_dst)
- Se IP_dst1 fallisce → SCTP passa automaticamente a IP_dst2
- *Failover trasparente*: l'applicazione non si accorge del cambio

*Applicazione in LTE*:
- Un eNodeB può avere una connessione SCTP verso *più MME*
- MME primario: gestisce il traffico normale
- MME secondario: subentra in caso di failure del primario
- Ridondanza e alta disponibilità

#nota()[
  Il multihoming introduce un piccolo *overhead nell'header* SCTP per specificare gli indirizzi multipli, ma i benefici in termini di affidabilità superano ampiamente questo costo.
]

==== SCTP: Message-Oriented

A differenza di TCP, SCTP è *message-oriented*:

*TCP (stream-oriented)*:
- Applicazione scrive: "MessageA", "MessageB", "MessageC"
- TCP invia: "MessageAMessageBMessa" | "geCM" | ... (segmentazione arbitraria)
- Ricevitore deve ricostruire i confini dei messaggi

*SCTP (message-oriented)*:
- Applicazione scrive: "MessageA", "MessageB", "MessageC"
- SCTP garantisce: ogni messaggio viene consegnato *intero* e *delimitato*
- Ricevitore riceve esattamente: "MessageA", poi "MessageB", poi "MessageC"
- *Nessun overhead* per delimitazione applicativa

*Vantaggi in LTE*:
- Ogni messaggio S1-AP è un'unità atomica (es. "Handover Request")
- Processing più efficiente: non serve parsing per trovare i confini
- Riduzione delle risorse computazionali richieste

=== Confronto TCP vs SCTP

#align(center)[
  #table(
    columns: 3,
    align: (left, center, center),
    table.header([*Caratteristica*], [*TCP*], [*SCTP*]),
    [Affidabilità], [✓], [✓],
    [Controllo di flusso], [✓], [✓],
    [Controllo di congestione], [✓], [✓],
    [Orientamento], [Stream], [Message],
    [Multi-streaming], [✗], [✓],
    [Multi-homing], [✗], [✓],
    [HOL Blocking], [Sì (globale)], [No (tra stream)],
    [Consegna fuori ordine], [✗], [✓ (tra stream)],
  )
]

#informalmente()[
  SCTP combina i *vantaggi di TCP* (affidabilità, controllo di flusso) con i *vantaggi di UDP* (message-oriented, consegna non bloccante), aggiungendo funzionalità uniche come multi-streaming e multi-homing.
]

== User Plane: Stack Protocollare

L'*user plane* trasporta il traffico dati vero e proprio degli utenti. A differenza del control plane, utilizza il *tunneling GTP* per mantenere la sessione dati indipendente dalla mobilità.

=== Livelli IP nell'User Plane

Nell'architettura LTE esistono *tre livelli di indirizzamento IP* distinti:

*Primo livello - IP dell'utente (UE ↔ P-GW)*:
- Indirizzi IP assegnati agli UE tramite *DHCP* o configurazione statica
- Gestiti dal P-GW con *NAT* (Network Address Translation)
- Utilizzati per la comunicazione tra UE e Internet/servizi esterni
- *Visibili solo* all'interno del tunnel GTP tra UE e P-GW
- Esempio: `10.x.x.x` o `172.16.x.x` (IP privati)

*Secondo livello - IP pubblici (P-GW ↔ Internet)*:
- Indirizzi IP pubblici del P-GW verso Internet
- Utilizzati per il traffico verso servizi esterni all'operatore
- Soggetti a NAT se gli UE hanno IP privati
- Visibili su Internet

*Terzo livello - IP interni della rete operatore*:
- Indirizzi IP utilizzati per il routing *interno* tra elementi della rete EPC
- Esempi: IP degli eNodeB, IP degli S-GW, IP dei P-GW, IP degli MME
- Utilizzati per stabilire i tunnel GTP (S1-U, S5/S8)
- *Non visibili* dall'esterno: rete privata dell'operatore
- Gestiti dall'operatore come rete privata separata

#nota()[
  La separazione tra i tre livelli IP permette *mobilità trasparente*: l'IP dell'UE (livello 1) rimane costante anche quando cambiano gli elementi della rete (livello 3) durante la mobilità.
]

== GTP: GPRS Tunneling Protocol

Il *GTP (GPRS Tunneling Protocol)* è il protocollo fondamentale che permette di *incapsulare* il traffico dell'utente in tunnel logici attraverso la rete dell'operatore.

*Motivazione*:
- Lo User Equipment (UE) ha una *sessione dati* con un P-GW specifico
- Durante la mobilità, l'UE cambia eNodeB e potenzialmente anche S-GW
- Senza tunneling, dovremmo aggiornare *tutte le tabelle di routing* della rete ad ogni movimento
- Con GTP: solo gli endpoint del tunnel vengono aggiornati

*Vantaggi del tunneling*:
- *Mobilità trasparente*: l'IP dell'UE rimane fisso durante tutta la sessione
- *Routing semplificato*: i router intermedi inoltrano solo in base all'IP del tunnel
- *Isolamento*: il traffico di ciascun UE è isolato nel proprio tunnel
- *QoS end-to-end*: ogni tunnel può avere classi di servizio diverse

#informalmente()[
  Il tunnel GTP è come un "tubo virtuale" che collega l'UE al P-GW, passando attraverso eNodeB e S-GW. Anche se l'UE si muove, il tubo viene semplicemente "riattaccato" al nuovo eNodeB, senza dover ricostruire tutto.
]

=== Uplink: Incapsulamento GTP

Vediamo nel dettaglio come funziona l'incapsulamento GTP per il traffico *uplink* (UE → Internet).

*Step 1: UE → eNodeB*

Il pacchetto che parte dall'UE ha la seguente struttura:
```
+----------------+
|  Applicazione  | (es. dati HTTP)
+----------------+
|   UDP/TCP      | (porta src/dst applicativa)
+----------------+  
|      IP        | (IP_UE → IP_Server)
+----------------+
|   PDCP/RLC     | (livelli LTE)
+----------------+
|      MAC       |
+----------------+
```

L'UE trasmette il pacchetto via radio all'eNodeB. *Non c'è routing* a livello UE: tutto va all'eNodeB.

*Step 2: eNodeB → S-GW (Interfaccia S1-U)*

L'eNodeB riceve il pacchetto, rimuove i livelli radio (PDCP/RLC/MAC) ed *incapsula* il pacchetto IP in un tunnel GTP:

```
+----------------+
|  Applicazione  |
+----------------+
|   UDP/TCP      |
+----------------+
|      IP        | (IP_UE → IP_Server) ← Pacchetto originale
+----------------+
| --- GTP-U ---  | (Tunnel ID)
+----------------+
|      UDP       | (porta 2152)
+----------------+
|      IP        | (IP_eNodeB → IP_SGW) ← Tunnel esterno
+----------------+
```

*Campi del tunnel GTP*:
- *IP esterno*: `IP_eNodeB → IP_SGW` (livello 3: IP interni operatore)
- *UDP*: porta 2152 (porta standard GTP-U per user plane)
- *GTP Header*: contiene il *Tunnel ID* (TEID - Tunnel Endpoint Identifier)
  - TEID univoco per identificare la sessione UE specifica
  - Permette al S-GW di demultiplexare i pacchetti di diversi UE
  - Mapping: `(eNodeB, TEID) ↔ (UE, Bearer)`

*Step 3: S-GW → P-GW (Interfaccia S5/S8)*

Il S-GW riceve il pacchetto, rimuove il tunnel GTP esterno e *crea un nuovo tunnel* verso il P-GW:

```  
+----------------+
|  Applicazione  |
+----------------+
|   UDP/TCP      |
+----------------+
|      IP        | (IP_UE → IP_Server) ← Pacchetto originale (invariato)
+----------------+
| --- GTP-U ---  | (Tunnel ID 2)
+----------------+
|      UDP       | (porta 2152)
+----------------+
|      IP        | (IP_SGW → IP_PGW) ← Nuovo tunnel
+----------------+
```

*Nota*: il pacchetto IP originale dell'UE *non viene mai modificato* finché non raggiunge il P-GW.

*Step 4: P-GW → Internet*

Il P-GW:
1. Riceve il pacchetto GTP
2. *Decapsula*: estrae il pacchetto IP originale (IP_UE → IP_Server)
3. Applica *NAT* se necessario: traduce IP_UE (privato) in IP_pubblico
4. Applica *policy* (firewall, QoS)
5. Inoltra il pacchetto verso Internet

*Gestione della mobilità*:

Se l'UE si sposta da eNodeB1 a eNodeB2:
- Il *pacchetto IP interno* (IP_UE → IP_Server) rimane *identico*
- Cambia solo l'*IP del tunnel esterno*: (IP_eNodeB2 → IP_SGW)
- Il S-GW aggiorna il mapping: nuovo TEID per eNodeB2
- Il P-GW *non* è coinvolto → l'IP dell'UE rimane stabile

#attenzione()[
  *Senza GTP*, ad ogni cambio di eNodeB dovremmo aggiornare tutte le tabelle di routing della rete dell'operatore per instradare i pacchetti verso il nuovo punto di attacco. *Con GTP*, basta aggiornare il Tunnel ID: il routing si basa sugli IP degli endpoint (che cambiano raramente).
]


== EPS Bearer: Gestione della QoS

Gli *EPS Bearer* (Evolved Packet System Bearer) sono i meccanismi attraverso cui LTE garantisce la *qualità di servizio* (QoS) end-to-end tra l'UE e la rete esterna.

=== Architettura degli EPS Bearer

Un EPS Bearer è un *canale logico* con parametri QoS specifici che attraversa tutta la rete, dal dispositivo dell'utente fino al servizio esterno.

*Componenti dell'EPS Bearer*:

*1. External Bearer* (P-GW ↔ Servizio Esterno):
- Connessione tra P-GW e server/servizio su Internet
- QoS gestita tramite accordi con provider esterni o best-effort
- Fuori dal controllo diretto dell'operatore mobile

*2. EPS Bearer interno* (UE ↔ P-GW):
A sua volta suddiviso in tre segmenti:

a) *Radio Bearer* (UE ↔ eNodeB):
  - Gestisce la QoS a livello *radio*
  - Allocazione dinamica di PRB (Physical Resource Blocks)
  - Priorità di scheduling
  - Modulazione adattiva in base al canale

b) *S1 Bearer* (eNodeB ↔ S-GW):
  - Tunnel GTP attraverso la rete di backhaul
  - QoS garantita tramite DiffServ o MPLS
  - Interfaccia S1-U

c) *S5/S8 Bearer* (S-GW ↔ P-GW):
  - Tunnel GTP nella rete core
  - QoS end-to-end all'interno della rete dell'operatore

#nota()[
  Tutti i segmenti del bearer devono *cooperare* per garantire la QoS richiesta. Se il Radio Bearer è lento, gli altri segmenti devono compensare o bufferizzare. La QoS effettiva è limitata dal segmento più debole ("collo di bottiglia").
]

=== Tipi di Bearer

Ogni UE può avere *al massimo 8 bearer attivi contemporaneamente*. I bearer si dividono in due categorie:

==== Default Bearer

Il *Default Bearer* viene creato automaticamente durante la procedura di *attach* (connessione iniziale alla rete).

*Caratteristiche*:
- Creato durante l'attach dell'UE alla rete
- Associato a una *PDN connection* (connessione a un P-GW specifico)
- All'UE viene assegnato un *indirizzo IP* per questa PDN
- Tipicamente ha QoS *best-effort* (QCI 9)
- Rimane attivo finché l'UE è connesso alla rete
- *Sempre presente*: non può essere rimosso senza disconnettere l'UE

#esempio()[
  Quando accendi il telefono e ti connetti alla rete 4G:
  + L'UE esegue la procedura di *attach*
  + Viene creato un *Default Bearer* verso il P-GW dell'operatore
  + Ti viene assegnato un IP (es. `10.123.45.67`)
  + Puoi navigare su Internet con QoS best-effort
]

==== Dedicated Bearer

I *Dedicated Bearer* sono bearer aggiuntivi creati *su richiesta* per fornire QoS garantita a specifiche applicazioni.

*Caratteristiche*:
- Vengono creati *dopo* l'attach, quando necessario
- Sono "fork" (derivazioni) del Default Bearer sulla stessa PDN connection
- Utilizzano lo *stesso IP* del Default Bearer
- Hanno *QoS superiore*: GBR (Guaranteed Bit Rate), latenza garantita, priorità
- Vengono rilasciati al termine della sessione applicativa

*Procedure di creazione*:
- *Network-initiated*: la rete (PCRF/P-GW) decide di creare un Dedicated Bearer
  - Esempio: chiamata VoLTE → IMS richiede al PCRF un bearer con QCI 1
- *UE-initiated*: l'UE richiede QoS specifica (raro, spesso negato per policy)

#esempio()[
  Scenario: videochiamata VoLTE
  + Hai già un *Default Bearer* attivo per navigazione web (QCI 9)
  + Avvii una videochiamata VoLTE
  + L'IMS richiede al PCRF un *Dedicated Bearer* con:
    - QCI 1 (voce, priorità 2, latenza < 100 ms, GBR)
  + Il PCRF invia i comandi a P-GW, S-GW, eNodeB
  + Viene creato un nuovo bearer sullo *stesso IP* del Default Bearer
  + Il traffico VoLTE usa il Dedicated Bearer (bassa latenza)
  + Il traffico web continua sul Default Bearer (best-effort)
  + A fine chiamata, il Dedicated Bearer viene *rilasciato*
]

==== Multiple PDN Connections

È possibile avere *più Default Bearer* contemporaneamente, ciascuno associato a una PDN connection diversa (P-GW diverso).

*Motivazioni*:
- Accesso a *servizi diversi*: Internet pubblica + APN aziendale privato
- Separazione del traffico: dati personali vs dati aziendali
- Multi-homing: connessione a più reti contemporaneamente

*Allocazione IP*:
- Ogni PDN connection ha il proprio *Default Bearer*
- Ogni Default Bearer ha un *indirizzo IP diverso*
- L'UE può avere quindi più IP simultanei

#esempio()[
  Smartphone aziendale:
  + *PDN 1*: Internet pubblica → Default Bearer con IP `10.x.x.x`
  + *PDN 2*: VPN aziendale → Default Bearer con IP `192.168.x.x`
  + *PDN 2.1*: Dedicated Bearer per VoIP aziendale (QCI 1)
  
  Totale: 3 bearer attivi (2 default + 1 dedicated)
]

*Limitazioni*:
- Massimo *8 bearer totali* per UE (somma di default e dedicated)
- Ogni Default Bearer può avere più Dedicated Bearer associati
- Configurazione tipica:
  - 1-2 Default Bearer (Internet + eventuale APN privato)
  - 0-6 Dedicated Bearer per applicazioni specifiche

#nota()[
  In 5G, il concetto di bearer viene sostituito dai *Network Slices*, che permettono una gestione ancora più granulare e flessibile della QoS, con la possibilità di creare "reti virtuali" dedicate per specifici servizi.
]

=== QoS Class Identifier (QCI)

Ogni bearer è caratterizzato da un *QCI* che definisce i parametri di QoS:

#align(center)[
  #table(
    columns: 6,
    align: (center, center, center, center, center, left),
    table.header([*QCI*], [*Tipo*], [*Priorità*], [*Delay*], [*Loss Rate*], [*Applicazione*]),
    [1], [GBR], [2], [100 ms], [$10^(-2)$], [VoLTE],
    [2], [GBR], [4], [150 ms], [$10^(-3)$], [Video call],
    [3], [GBR], [3], [50 ms], [$10^(-3)$], [Gaming real-time],
    [4], [GBR], [5], [300 ms], [$10^(-6)$], [Video streaming],
    [5], [Non-GBR], [1], [100 ms], [$10^(-6)$], [IMS signaling],
    [6], [Non-GBR], [6], [300 ms], [$10^(-6)$], [Video TCP],
    [7], [Non-GBR], [7], [100 ms], [$10^(-3)$], [Voice, gaming],
    [8], [Non-GBR], [8], [300 ms], [$10^(-6)$], [Web, email],
    [9], [Non-GBR], [9], [-], [-], [Internet default],
  )
]

== Procedure di Gestione EPS

=== Attach Procedure

Quando un UE si connette alla rete LTE, esegue la *procedura di attach*:

*Step*:
+ L'UE invia un *Attach Request* all'eNodeB
+ L'eNodeB lo inoltra all'MME (l'eNodeB non può decidere autonomamente di accettare o rifiutare)
+ L'MME verifica con l'HSS:
  - Autenticazione dell'utente
  - Profilo di abbonamento
  - Servizi autorizzati
+ L'MME contatta il P-GW appropriato
+ Viene creato il *Default Bearer*
+ All'UE viene assegnato un *indirizzo IP*
+ L'UE diventa *mobility registered* e *connected*

*Stati dell'UE*:
- *EMM-DEREGISTERED*: non connesso alla rete
- *EMM-REGISTERED*: connesso, può ricevere paging
  - *ECM-IDLE*: connesso ma senza risorse radio allocate
  - *ECM-CONNECTED*: risorse radio attive, può trasmettere/ricevere

=== Idle Mode e Paging

Quando l'UE è inattivo (nessun traffico dati), passa in *Idle Mode* per risparmiare energia:

*Caratteristiche Idle Mode*:
- Le risorse radio vengono *rilasciate*
- Il Default Bearer rimane *attivo logicamente*
- L'MME sa in quale Tracking Area si trova l'UE
- L'UE monitora i canali di *paging*

*Procedura di Paging*:
+ Arriva traffico per l'UE (es. chiamata in arrivo)
+ Il P-GW inoltra i pacchetti all'S-GW
+ L'S-GW notifica l'MME
+ L'MME invia *paging* a tutti gli eNodeB della Tracking Area
+ L'UE risponde al paging
+ Viene riattivato l'ECM-CONNECTED
+ Le risorse radio vengono riallocate
+ Il traffico può fluire

#informalmente()[
  L'Idle Mode è come "mettere il telefono in standby": la connessione logica rimane attiva (ricevi paging), ma non consumi risorse radio (batteria). Quando arriva una notifica o una chiamata, la rete ti "sveglia" tramite paging.
] 