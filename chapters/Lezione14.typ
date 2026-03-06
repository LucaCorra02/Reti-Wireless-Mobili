#import "../template.typ": *

== Dataset di Base Station

Possiamo raggruppare la gestione di remote radio head, in modo da gestirne di più attraverso un certo data center.

I vantaggi di questa soluzione sono:
- Riduzione CAPEX (Investimento di capitale): meno radio head, meno antennte meno cavi. Capitale investito per costruire la rete.

- Riduzione OPEX (Investimento di esercizio, quando cosata far funzionare la rete): meno manutenzione, meno consumi, meno spazio occupato. Ottimizzazione risorse BBU remote. Capitale investito per mantenere la rete (farla funzionare)

L'idea è che posso accendere tutte le antenne se il traffico in una certa cella aumenta.

La densificazione è più sostenbilie. Mettia più siti radiomobili di qualsiasi dimensione e usiamo la scalabilità orizzontale per istanziare le basement unit. Sfruttiamo la tecnolgia dei cloud dataset. Istanziamo basement unit per un certo gruppo di rafdio head.

= Cloud Computing

Offre diverse tipo di servizi. é presente una scalabalità dinamica in base al traffico (traffico più alto aumento le istanze).

Vengono ridotto CAPEX e OPEX. Non faccio spese in anticipo ma pago solo per quello che consumo.

Alta affidabilità e disponibilità. Se un server si guasta, le istanze vengono spostate su altri server. Inoltre garantisce anche la ridondanza e replica dei dati.

Altri livelli di virtualizzazione e hardware. L'hardware è utilizzato in quanto i core delle varie macchine possono essere utilizzati per più istanze.

Tra internet ci mettiamo la nostra rete mobile (che è di fatto un ISP). Di mezzo c'è la rete mobile core e la mobile edge. Dobbiamo arrivare al gataway della nostra rete e poi arrivare ad un AS (Autonomous System) che contiene gli internet service provider (ISP) che offrono servizi di cloud computing.

Problemi:
- elevata latenza (distanza tra utente e data center). Già solo per attreversare la rete mobile. Solitamente i servizi sono lontani
- elevato jitter (variazione della latenza). Non c'è molta stabilità della latenza, che è un problema per applicazioni real time (es. gaming, videochiamate, ecc.). Il round trip time (RTT) è elevato e variabile. Applicazioni buffer stram permettono di nascondere l'effetto del jitter (ad esempio video straming). Ma per applicazioni real time è un problema.

Utenti in prossimità utilizzando cloud e non in modalità peer.

== MEC (ETSI)
*MEC* (Mobile edge computing):
*MEC* (Multi-access edge computing):

#informalmente()[
  L'obbiettivo è avvicinare la computazione all'utente finale, in quanto il cloud è lontano
]

Data una rete geogrficamente distribuita e eterogenea (diversi tipi di capacità computazionale) man mano che ci trasferiamo dall'edge (da far edge, vicino all'utente a cloud e rete core) la capacità computazionale aumenta, ma aumenta anche la latenza.

Più vicino siamo all'utente minore è la latenza, ma minore la capacità computazionale.

//aggoungere immagine
Dato un certo servizio, con un Direct cylic graph che ci descrive la dipendenza tra i vari componenti. L'idea è dove installare questi componenti e come gestire la mobibilità.

Dipende da:
- Requisiti dei moduli ( requisiti hardware, requisiti di latenza, ecc.)
- Requisiti dei linl, requisiti di latenza per mandare un dato da un modulo all'altro.

Sui link abbiamo la latenza richiesta (arancio è real time) mentre in tabella abbiamo i requisiti di risorse. Infine, la gradezza delle freccie indica il data rata.

La domanda è dove istanziare ciascuno dei moduli con l'obbiettivo di soddisfare le loro richieste e sfruttare la rete che ho a disposizione.

Ad esempio il dispositivo $A$ lo mettiamo vicino all'edge o sul dispositivo, in quanto è real time ma le risorse richieste sono basse.

Si tratta di un problema di *assegnamento* (combinatorio). Tipicamente è che $A$ sono dei microservizi, chiesto al sistema di istanziare l'applicazione. L'orchestratore capisce dove istanziare i vari microservizi, per avere l'applicazione funzionante e soddisfare i requisiti.

== Esti MEC

Si tratta dello standatd proposto da ETSI

MEC = visione su titti i dataset distribuiti geograficamente

MEC HOST Level = Uno per ogni mini-datacenter

NFVI = virtualizza le risorse dei mini-datacenter

sotto abbiamo la parte di rete (fuori dalla rete)

Version NFV:
- Data plane: gestisce il traffico dati (forwarding, routing, ecc.)
- NFVI: virtualizza le risorse dei mini-datacenter
- MEC APP: è vero che sono un sistema distributo, ma esiste un interfaccia che permette a un MAC host di dialogare con altri MAC host anche in moilità. L'idea è creare una macchina virtuale da una parte e dall'altra parte, in modo che possano dialogare tra loro.

== 3GPP

Network slicing: è un'estensione di radio bearer. Si tratta di un concetto che trasforma la rete da un paradigma statico ad un paradigma dinamico dove le reti logiche vengono create dinamicamente con risorse e topologie ottimizzate per uno scopo specifico.

Se prima con i bearer era creare un tunnel (canale) con una certa determinata di QoS  ma mantenendo lo stesso sistema qui possiamo andare a camiare diversi aspetti della rete:
- topologia
- quali nodo contengono
- ecc

Un istanza di una network slice è un insieme di risorse di rete sia virtuali che fisiche che sono organizzate e configurate per fornire una rete logica che soddisfa certi servizi. Abbiamo un template configurato per un certo servizio o utente.

//aggiugnere immagine
In 5g creiamo delle fette che attraversano la rete, ciascuno con delle caratteristiche diverse. Per farlo usiamo le seguenti tecnologie:
- SDN
- NFV
- MEC

= LTE CUPS

I PGW e i SGW vengono spezzati in due parti, data-plane e control-plane. Separiamo le operazioni di data palne a quello di controllo (traffico a template, gestione della mobilità, ecc.). In questo modo possiamo scalare in modo indipendente le due parti. Ad esempio se abbiamo un aumento del traffico dati, possiamo scalare solo la parte di data plane, senza dover scalare anche la parte di controllo.

= 5G

Il control plane deve garantire le seguenti funzionalità:
- Gestione della mobilità
- Gestione dei template
- Gestione dell'accesso

Lo user plane deve:
- Garantire connettività cloud
- Garantire scambia sia con cloud che con dispositivi edge

== Dataplane

In 5G abbiamo dei moduli che prendono il nome di UPF (user plane function). Essi possono essere configurati in modi diversi e possono aderire a compiti diversi.

- UPF ULCL: (Uplink Classifier) decide il traffico in uplink che fa su un UPF cloud e quello che va verso un UPF edge.

Il vantaggio è che abbbiamo il tempalte ULCL istanziato vicino alla base station in modo tale che tramite UPF edge usciamo verso il dataser (più vicino) mentre i bearer mappati sul cloud proseguono. Il traffico in uplink viene quindi smistato, generando due possibili percorsi dataplane.

Il dataplane ha un unica modulo, ovvero UPF.

== Control Plane

C'è un nuovo modulo che deve gestire i network sliding.

Ciascuno dei moduli UPF e core sono delle network servercing.

N9 = interfaccia che permette di realizzare l'upf che si collega con un altro UPF. Anche in queesto caso abbiamo delle intergacce che si collgano uno a uno. TIpo N1 e N2

I moduli AMF e SMF sono il vecchio MME. Prmettono di gestire la mobilità e la sessione.

La comunicazinone non è punto a punto, ma è pub e server. Avviene un evento e chi deve gestire un evento lo serve (abbiamo un unico bus).

Esiste il 5G standalone e il 5G non standalone:
- Non standalone: la parte di rete dopo la (R)AN  compreso di user plane e controllo è uguale all'architettura di LTE.
- Standalone è invecee quella dell'immagine sopra.

Per ottenere i vantaggi di 5G serve 5G standalone

La separazione permette di scalare, in modo tale da avere scalabilità orizzonatale sui singoli moduli.

=== AMF (Access and Mobility Management Function)
//aggiunger

=== SMF (Session management function)
Comunica direttamente lo USER plane. Il compito di questo modulo è gestire le sessioni, ovvero gestire i template

=== PCF (Policy Control Function)
Vecchio PRF, gestise le policy chi può fare che cosa
=== AUSF (Authentication Server Function)
Vecchio HSS, gestisce l'autenticazione degli utenti

=== NSSF (Network Slice Selection Function)
Permette di selezionare le network slice, ovvero selezionare la rete logica più adatta per un certo servizio o utente

=== NEF (Network Exposure Function) & AF (Application Function)
Sono due funzionalità nuove. Permettono al servizio esterno di entrare nella rete operatore e all'operatore di esporre le funzionalità della rete al servizio esterno.

Possono essere messi in dialogo i due mondi. NEF (cosa la rete mostra) AF (come l'esterno comunica con la rete).

#esempio()[
  Chiamata truffa. L'operatore sa che si sta avendo una chiamata con la banca. L'applicazione della banca è esterna. Se questi due mondi potessero comunciare la rete potrebbe dire se l'utente che usa il dataplane per arrivare all'applicazione della banca potrebbero essere bloccate operazioni sospette.
]

== UserPlane

Possiamo avere più UPF attivve (tanto è una network function). La parte di dialogo è il SMF che istriusice ogni UPF.

Il downlink classifier non serve in quanto sappiamo già da non arriva, l'uplink classifier serve per capire dove instradare il traffico correttamente.

UPF rende componibile un servizio di rete che sia in grado di rispettare dei requisiti specifici di alcuni servizi. Dobbiamo poi capire come portare traffico da una parte all'altra
