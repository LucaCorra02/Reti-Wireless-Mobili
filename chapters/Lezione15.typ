#import "../template.typ": *

== 5G network slice

Grazie alla network slicing, è possibile creare più reti virtuali indipendenti sulla stessa infrastruttura fisica. Ogni slice può essere configurata per soddisfare i requisiti specifici di un servizio o di un'applicazione, come ad esempio bassa latenza per i servizi di gaming o alta affidabilità per i servizi di emergenza.

#esempio()[
  Ad esempio, per una rete IOT possiamo piazzare l'UPF dietro la base station, in modo da uscire direttamente su internet, meno latenza.
]

L'idea è quella di andare a configurare la rete in modo dinamico, sia a livello di parametri (caratteristiche del servizio) che a livello di NF (Network Function) che compongono il servizio.

Possiamo quindi andare a personalizzare le componenti in termini di moduli del control plane e data plane.

=== Identificativo della slice

Per l'identificazione della slice, viene utilizzato uno slice identifier a $32$ bit, chiamato *Single Network Slice Selection Assistance Information* (S-NSSAI):
- I primi $8$ bit, rappresentato la *macro tipologia* della slice:
  - eMBB, URLLC, ecc
  - Reserveed per permettere allo standard di crescere
  - Operator specific, l'operatore può personalizzare le macro-classi di slice

- I restanti $24$ servono come *slice differentation*. Identificano l'istanza specifica della slice.

I vari codici vengono forniti all'UE al momento della registrazione. I componenti che dialogano a livello core sono: UE , AMF, NSFF, UDM.\
In questo modo il dispositivo è a conoscenza della slice a cui è assegnato e inserirà l’identificativo della slice all’interno dei pacchetti.

#nota()[
  I bearer utilizzati in 4G rimangono. Le slice sono un' ulteriore livello di astrazione da mettere _sopra_ ai bearer.
]

== 5G e MEC

L'integrazione di 5G con i servizi di edge computing (MEC) è una delle caratteristiche distintive.

L'*integrazione di MEC viene realizzata attravero il modulo UPF* (User Plane Function) che si occupa di instradare il traffico verso la destinazione corretta (cloud o edge). L'UPF può essere configurato dinamicamente per instradare il traffico verso un MEC server.

#esempio()[
  Supponniamo di avere un UE che accede a una slice. La slice collega un UPF a un Data Network (DN) che può essere il cloud o un MEC server.

  L'applicazione richiede accesso a un servizio di edge computing. L'orchestratore capisce che deve istanziare un nuovo servizio, in particolare:
  - Deve soddisfare i requisiti della richiesta, trovando l'edge giusto (vicino all'utente, con le risorse necessarie, ecc)

  - La MEC application configura il servizio richiesto.

  A livello di rete, invece, bisogna configurare il data plane, in modo che l'UE possa raggiungere la MEC application richiesta. A tale scopo, viene aggiunto un UPF class link classifier appositamente configurato (nuovo o già esistente o riconfigurato). Ovviamente il tutto avviene in modo trasparente per l'utente, che non si accorge di nulla.

  il traffico dell'UE viene instradato verso l'UPF class link classifier, che lo instrada verso la MEC application. Se invece l'applicazione è sul cloud, il traffico viene instradato verso il cloud.

]

#attenzione()[
  Senza la network function virtualization (NFV), questa flessibilità *non* sarebbe stata possibile.
]

=== Edge Resource Placement

Vogliamo capire dove posizionare i MEC server all'interno della rete. Ci sono diverse opzioni, ognuna con i suoi vantaggi e svantaggi:

+ Mettere il MEC server in un data center vicino all'utente, ad esempio in una base station. In questo modo si riducono le latenze, ma è più costoso e complesso da gestire

+ Invece di mettere un server sotto ogni antenna, se ne mette uno più grande in un nodo che raccoglie il traffico di $20-50$ antenne (ad esempio, a livello di quartiere o di città). In questo modo si riducono i costi e si semplifica la gestione, ma le latenze sono maggiori

+ Posizionare il MEC server nella backhaul (es. a livello regionale o nazionale), ad esempio in un nodo di aggregazione. In questo modo si riducono i costi e si semplifica la gestione, ma le latenze sono maggiori

+ Metterlo nella rete core. In questo caso si può usare una slice dedicata per il traffico verso il MEC server, in modo da garantire le prestazioni necessarie. Latenze simili a quelle del cloud

#nota()[
  Le scelte non sono mutualmente esclusive, ma possono essere combinate in base alle esigenze specifiche del servizio e alla topologia della rete. Ad esempio, si potrebbe avere un MEC server vicino all'utente per i servizi che richiedono bassa latenza, e un altro più centralizzato per i servizi che possono tollerare latenze maggiori.
]

== 5g RAN - 5G NR

In 4G avevamo un frame di simboli OFDMA che durava $10 "ms"$, con $10$ subframe da $1 "ms"$ ciascuno.

L'idea in 5G è quella di *ridurre la latenza* (portarla sotto 1ms), *senza ridurre il numero di simboli trasmessi* (sempre 14 simboli OFDMA).

La soluzione è quella di *ridurre la durata del simbolo*, aumentando di conseguenza la velocità di trasmissione.

#nota()[
  La diminuzione della durata del simbolo comporta un *aumento della distanza tra le sotto-portanti*, altrimenti si violerebbe l'ortogonalità tra di esse.
]

Lo standard 5G NR definisce $5$ diverse durate, indicate come *numerology* $mu$. Definisce anche due possibili intervalli di frequenze:
- FR1: $410-7125 "Mhz"$
- FR2: $24250-52600 "Mhz"$

Per una numerology $mu$, si ha una distanza tra le sotto-portanti $Delta f$ pari a:
$
  Delta f = 2^mu dot 15 "Khz"
$
Con $mu = 0$ le sotto-portani sono distanziate come in 4G, mentre con $mu = 4$ un singolo resource block occupa molta più banda per mantenere lo stesso numero di sotto-portanti.


La durata di uno slot ($14$ simboli OFDM) su una sotto portante può essere vista nel seguente modo: Se riduciamo la durata del simbolo dobbiamo aumentare lo spazio fra le sotto-portanti.\
In figura vediamo come variano la durata dello slot e la distanza tra le sotto-portanti al variare della numerology $mu$.

#align(center)[
  #figure(
    cetz.canvas(length: 0.9cm, {
      import cetz.draw: *

      let bar-color = rgb("#5B9BD5")
      let label-size = 0.3cm

      // mu = 0
      rect((0, 6.6), (9.6, 7.1), fill: bar-color, stroke: none)
      content((10.0, 6.85), text(size: label-size, fill: black)[$1 "ms"$])
      content((10.0, 6.35), text(size: label-size, fill: black)[$15 "KHz"$])

      // mu = 1
      rect((0, 5.2), (4.8, 5.9), fill: bar-color, stroke: none)
      content((5.4, 5.6), text(size: label-size, fill: black)[$0.5 "ms"$])
      content((5.5, 5.1), text(size: label-size, fill: black)[$30 "KHz"$])

      // mu = 2
      rect((0, 3.4), (2.4, 4.5), fill: bar-color, stroke: none)
      content((3.2, 4.0), text(size: label-size, fill: black)[$0.250 "ms"$])
      content((3.1, 3.5), text(size: label-size, fill: black)[$60 "KHz"$])

      // mu = 3
      rect((0, 1.1), (1.2, 2.9), fill: bar-color, stroke: none)
      content((2.15, 2.1), text(size: label-size, fill: black)[$0.125 "ms"$])
      content((2.15, 1.6), text(size: label-size, fill: black)[$120 "KHz"$])

      // mu = 4
      rect((9.0, 1.1), (9.6, 5.8), fill: bar-color, stroke: none)
      content((10.4, 3.2), text(size: label-size, fill: black)[$0.0625 "ms"$])
      content((10.4, 2.7), text(size: label-size, fill: black)[$240 "KHz"$])
    }),
    caption: [Durata dello slot e spaziatura tra sotto-portanti al variare della numerology],
  )
]

#attenzione()[
  Anche se le sotto-bande sono più larghe, 5G NR *non* riduce il numero di utenti che possono essere serviti contemportaneamente (sempre 14 simboli OFDM), per le seguenti ragioni:
  - La durata della frame è ridotta, il canale si libera più velocemente. La stazione assegna le risorse agli utenti con una frequenza più alta.

  - Canali più ampi a differenza di 4G, permettono un numero alto di sotto-portanti, quindi più utenti possono essere serviti contemporaneamente.
]

Lo scheduling con questa configurazione è più complesso, in quanto deve tenere conto della banda disponibile, della numerology scelta e dei requisiti di latenza e throughput dei servizi.

== Standalone vs Non-Standalone

Per quanto riguarda la rete 5G, esistono due modalità di implementazione: *Standalone* (SA) e *Non-Standalone* (NSA).

La modalità *Standalone* prevede che una stazione radio (un'antenna) si collega direttamente alla Core Network e fa tutto da sola. Gestisce sia la _burocrazia_ (il Control Plane, ovvero l'autenticazione, la mobilità) sia il traffico dati puro (User Plane). Esistono diverse configurazioni possibili per lo standalone:

- *gNB + 5Gc*: in questo caso abbiamo una rete core 5G e una base station 5G. Questa è la configurazione ideale per sfruttare tutte le potenzialità del 5G, ma è più costosa e complessa da implementare.

- *eNB + EPC*: in questo caso abbiamo una rete core 4G e una base station 4G. Configurazione classica per il 4G.

- *eNB + 5Gc*: in questo caso abbiamo una rete core 5G e una base station 4G. Questa configurazione è un compromesso tra le due precedenti, in quanto permette di sfruttare alcune delle potenzialità del 5G, ma non tutte.

Nella modalità *Non-Standalone*, invece, si usa una tecnica chiamata *Dual Connectivity*. L'utente si collega a due antenne diverse contemporaneamente:

- Una fa da *Master* ($M$): gestisce la segnalazione e fa da _ancora_. Si occupta della parte di *managment e controllo*

- L'altra fa da *Secondary* ($S$): si aggiunge per trasmettere o ricevere più dati e aumentare la velocità. Si cocupa della parte di *data plane*

#nota()[
  Ad oggi 5G viene implementato principalmente in modalità *Non-Standalone*, in particolare: L'operatore mantiene il vecchio Core 4G (EPC). L'antenna 4G fa da Master ($M$) e gestisce la connessione dell'UE. Tuttavia, quando c'è bisogno di un traffico in UL o DL  maggiore, si accende anche l'antenna 5G (gNB) che fa da Secondary ($S$).
]

#part("Comunicazione satellitare")

= Terminologia

I piani *orbitali*, sono i cerchi su cui orbitano i satelliti. Generalmente viene indicato attraverso l'inclinazione dell'orbita rispetto all'equatore.

La *costellazione* è l'insieme dei satelliti che orbitano su un piano orbitale. Ad esempio, la costellazione di Starlink è composta da migliaia di satelliti che orbitano su diversi piani orbitali. Un certo satellite può essere identificato attraverso il piano orbitale su cui orbita e la posizione all'interno di quel piano, in particolare usiamo $3$ punti di riferimento:

- *Angolo di Azimuth*: angolo che indica la direzione del satellite rispetto al nord. Viene misurato in gradi, con $0°$ che indica il nord, $90°$ l'est, $180°$ il sud e $270°$ l'ovest.

- *Angolo di elevazione*: angolo che indica quanto il satellite è alto rispetto all'orizzonte. Viene misurato in gradi, con $0°$ che indica l'orizzonte e $90°$ che indica il punto direttamente sopra la testa.

#align(center)[
  #image("../assets/angoli-satellite.png", width: 55%)
]

- *Angolo di copertura*: angolo che indica la copertura del satellite rispetto alla superficie terrestre. Viene misurato in gradi, con $0°$ che indica la superficie terrestre e $90°$ che indica il punto direttamente sopra la testa.

#nota()[
  Tendenzialmente, più il satellite è alto, maggiore è l'angolo di copertura e quindi la porzione di terra che può coprire.
]

La *lunghezza fisica del link* tra il satellite e un utente a terra dipende dalla posizione del satellite rispetto all'utente. In particolare, dipende dall'angolo di elevazione e dalla distanza del satellite dalla terra.

#nota()[
  La lunghezza fisica del link può varriare soprattuto per orbite *non geostazionarie* (ruotano con diversa velocità rispetto alla terra).
]

#align(center)[
  #image("../assets/lungezza-link-satellite.png", width: 45%)
]


La distanza minima è quando il satellite è direttamente sopra la testa ($h$). Il punto $d_max$ è quando il satellite è all'orizzonte, in questo caso la distanza è data da:
$
  d_max = sqrt((R+h)^2 - R^2)
$
La latenza diventa *non più trascurabile* dopo il punto $d_max$, sono necessari handover tra satelliti. Per calcolare quanto ci mettiamo a trasmettere dei dati, dobbiamo calcolare la *latenza di propagazione*:
$
  t = d/c
$
dove $d$ è la distanza e $c$ è la velocità della luce.

Un *angolo di elevazione molto basso* comporta una *latenza molto alta*, in quanto il segnale deve attraversare molta atmosfera (il satellite è all'orizzonte, link molto lungo). Il segnale perde molta potenza. Tale fenomeno viene accentuato in caso di maltempo, in quanto il segnale deve attraversare più nuvole e pioggia.

Consideriamo ora il seguente grafico:
- Sull'asse $y$ abbiamo il periodo di delay (RT)
- Sull'asse $x$ abbiamo l'altezza dell'orbita

Nel *punto geostazionario* il satellite ruota alla stessa velocità della terra, non è necessario fare handover, in quanto è sempre sopra la stessa posizione.

#align(center)[
  #image("../assets/delay-satellitare.png", width: 60%)
]


Il grafico mostra 3 curve:
- Curva $mb("blu")$ rappresenta il *periodo*: Indica quanto tempo impiega il satellite a compiere un'orbita completa. Più è lontano pià tempo ci mette.

- Curva $mr("rossa")$ rappresenta il *delay*: Indica il ritardo di propagazione del segnale radio. Le onde radio viaggiano alla velocità della luce, ma su distanze spaziali questo tempo diventa percepibile. all'aumentare dell'altitudine, il segnale deve percorrere più strada per fare andata e ritorno, quindi il ritardo si impenna. A quota geostazionaria, il ritardo supera i $250$ millisecondi.

- Curva $mg("verde")$ rappresenta la *copertura*: Indica la porzione di terra che il satellite può coprire. Più è lontano più copre, ma più è lontano più il segnale è debole, quindi c'è un trade-off tra copertura e potenza del segnale.

= Geo stazionario (GEO)

Si tratta di satelliti che seguono l'orbita geostazionaria:
- *periodo dell’orbita*: $24h$. Ruota alla stessa velocità della terra.
- visibilità: permanente
- *angolo di elevazione*: fisso, il satellite è sempre sopra la stessa posizione
- *elevata copertura*: $3$ satelliti sfalsati di $120$ gradi coprono la maggior parte delle zone abitate
- *qualità del segnale bassa* a causa della distanza
- elevato delay $tilde 250"ms"$

Siccome il satellite è sempre sopra la stessa posizione, non è necessario fare handover, in quanto l'utente si collega sempre allo stesso satellite. Tuttavia, a causa dell'elevato delay, questa tipologia di satellite è adatta solo per servizi che non richiedono bassa latenza.

== Low Earth Orbit (LEO)

Si tratta di satelliti che orbitano a bassa quota:
- *periodo dell’orbita*: $90-120 "min"$. Ruotano molto più velocemente della terra, quindi non sono sempre sopra la stessa posizione. È necessario fare handover tra satelliti, in quanto quando un satellite si allontana, l'utente deve collegarsi a un altro satellite che sta arrivando.
- *angolo di elevazione*: vari
- *copertura*: limitata, è necessario avere una costellazione di satelliti per coprire una vasta area.
- *qualità del segnale elevata* a causa della distanza ridotta, anche il delay è molto basso (sotto i $50 "ms"$).

== Medium Earth Orbit (MEO)

Si tratta di satelliti che orbitano a media quota:
- *periodo dell’orbita*: $2-12 "h"$. Ruotano più lentamente della terra, ma non sono sempre sopra la stessa posizione. È *necessario fare handover*, tuttavia è ridotto rispetto ai satelliti LEO, in quanto il satellite rimane sopra la stessa posizione per un periodo più lungo.

- Per coprire una vasta area, è necessario avere una costellazione di satelliti, ma è meno densa rispetto ai satelliti LEO.

== Costellazione

I satelliti LEO e MEO richiedono una costellazione di satelliti per coprire una vasta area. La costellazione è l'insieme dei satelliti che orbitano su un piano orbitale.

Le costellazioni differiscono per numero di piani orbitali e numero di satelliti.

== Architettura di rete satellitare

Sono presenti 3 segmenti:
- *Space segment*
- *Ground segment*
- *User segment*
#align(center)[
  #image("../assets/architettura-satellitare.png", width: 60%)
]

*Space segment*: è composto dai satelliti che orbitano nello spazio. Possono essere di diversi tipi (LEO, MEO, GEO) e possono avere diverse funzioni (comunicazione, osservazione, navigazione, ecc).

*Ground segment*: Contiene la _parte di controllo_ del sistema, include il gateway, ovvero ciò che connette le stazioni di terra con i satelliti, oltre che le stazioni di terra e tutto ciò che riguarda controllo, telemetria e tracking.

*User segment*: è composto dagli utenti che utilizzano i servizi offerti dai satelliti. Possono essere di diversi tipi (utenti mobili, utenti fissi, utenti marittimi, ecc).

== Topologia di rete satellitare

Le topologie di rete satellitare possono essere varie:

- *Punto-Punto*: il satellite funge da ponte tra due stazioni di terra. Ad esempio, una stazione di terra invia un segnale al satellite, che lo trasmette a un'altra stazione di terra.\

  L'uplink è da stazione di terra a satellite, mentre il downlink è da satellite a stazione di terra.

  #nota()[
    Permette un’area di copertura molto maggiore rispetto alla rete wireless terrestre con un elevata banda, ma richiede elevata potenza di trasmissione e ha un delay di propagazione elevato.
  ]

- *Broadcast*: il satellite trasmette un segnale a tutte le stazioni di terra all'interno della sua copertura. Ad esempio, un satellite meteorologico trasmette dati a tutte le stazioni di terra che si trovano nella sua area di copertura.

- *Mesh*: Si creano dei link tra stazioni, usando i satelliti come ripetitori. Ad esempio, una stazione di terra invia un segnale a un satellite, che lo trasmette a un'altra stazione di terra, che a sua volta lo trasmette a un'altra stazione di terra, e così via. Non è necessario un Gateway, in quanto le stazioni di terra possono comunicare direttamente tra loro attraverso i satelliti.

- *Stella*: Non esistono link diretti tra stazioni, ma tutto passa tramite il *gateway*. Ogni stazione comunica, passando dal satellite, con il gateway, il quale provvederà a _smistare_.

- *Hybrid*: Combina Star e Mesh, alcune comunicazioni passano attraverso il gateway ma sono presenti anche link diretti tra stazioni, in questo modo si riduce il carico sul gateway e si aumenta la resilienza della rete.

== Livello MAC

I protocolli di livello MAC per le comunicazioni satellitari. Possono essere:
- *Contention-free*: FDMA, CDMA, TDMA. In questo caso, le risorse sono assegnate in modo statico o dinamico. *Non ci sono collisioni* (vengono evitate attraverso la pianificazione), ma c'è un overhead maggiore per la gestione delle risorse.

- *Contention-based*: ALOHA, Slotted ALOHA, CSMA. In questo caso, gli utenti competono per accedere al canale, e *possono verificarsi collisioni*. Ad esempio, in una rete ALOHA, gli utenti trasmettono i loro dati in modo casuale, e se due utenti trasmettono contemporaneamente, si verifica una collisione e i dati vengono persi.

=== TDMA

Viene diviso il tempo in slot, e ogni utente trasmette durante il suo slot:

- Per quanto riguarda il downlink, il satellite trasmette un'*unico pacchetto* che contiene i dati di tutti gli utenti. Ogni utente estrae i dati a lui destinati.

- Per quanto riguarda l'uplink, ogni utente trasmette durante il suo slot, e il satellite riceve i dati da tutti gli utenti.

Richiede una precisa sincronizzazione tra satellite e dispositivo, oltre che un’elevata potenza di trasmissione.

=== FDMA

In FDMA, il canale è diviso in *sotto-bande di frequenza*, e ogni utente trasmette su una sotto-banda diversa. Richiede un'accurata pianificazione delle frequenze per evitare interferenze tra utenti.

Si tratta della prima modalità utilizzata per la trasmissione satellitare. Offre una minore eﬀicienza spettrale, quindi può essere combinata con TDMA per migliorarne le prestazioni.

=== CDMA

In CDMA, ogni utente trasmette su tutta la banda di frequenza, ma utilizza un *codice di spreading* unico per distinguere i suoi dati da quelli degli altri utenti. Richiede una complessa gestione dei codici e una potenza di trasmissione elevata.

=== OFDMA

In OFDMA, il canale è diviso in sotto-portanti di frequenza, e ogni utente trasmette su un *insieme di sotto-portanti*.

Richiede una complessa gestione delle risorse per assegnare le sotto-portanti agli utenti in modo efficiente, per questo mottivo non è molto utilizzato nelle comunicazioni satellitari, ma è stato proposto per le future generazioni di satelliti.

= Integrazione di satelliti nella rete 5G

L'integrazione di satelliti nella rete 5G è un argomento di grande interesse, in quanto i satelliti possono estendere la copertura della rete 5G in aree remote o difficili da raggiungere, come ad esempio le zone rurali, le aree montuose o le regioni marittime.

Tale integrazione prende il nome di *Non-Terrestrial Networks* (NTN). Le motivazioni per integrare i satelliti nella rete 5G sono molteplici:
- migliorare il lancio delle tecnologie 5G/6G anche in aree remote: aree rurali, aerei, navi
- continuità di servizio (ubiquitous connectivity): garantire connettività anche in casi di movimento _estremo_.

- migliorare l’aﬀidabilità della rete, sia in termini di capacità che in caso di catastrofi naturali

- aumentare la scalabilità della rete; servizi multicast e broadcast sono diﬀicili da implementare con protocolli unicast, con il satellitare è molto più facile

=== Modalità di integrazione

Esistono diverse modalità di integrazione dei satelliti nella rete 5G, a seconda del *ruolo che il satellite svolge nella rete*:

=== Relay

Il relay è una tecnica che permette di estendere la copertura di una rete wireless, utilizzando un satellite come ponte tra due stazioni di terra.

L'UE è connesso al relay che a sua volta è conesso al satellite. Esso trasmette i dati a un gateway a terra, che a sua volta li trasmette alla rete core. In questo modo, è possibile estendere la copertura della rete wireless anche in aree remote o difficili da raggiungere.

=== Backhaul

La rete satellirare può essere utilizzata come backhaul per connettere le stazioni di terra alla rete core. In questo caso, il satellite funge da ponte tra:
- La rete di backhaul terrestre, che collega più BSraggruppate in un'area geografica.

- La rete core, che gestisce la parte di controllo e instradamento del traffico. Essa è posta dietro ad un gateway a terra, che è connesso al satellite.


=== Diret Access

La rete satellitare può essere utilizzata per fornire connettività diretta agli utenti, senza passare attraverso una stazione di terra. In questo caso, il satellite funge da base station, riceve i segnali dagli utenti e li trasmette a terra.

In questo caso il satellite inoltra i dati direttamente al gatwway, il quale li trasmette alla rete core.


== Opzioni di integrazione

*NTN Transparent Payload*: Il satellite fa solo da relay e dialoga con l'antenna a terra e il gateway, senza interagire con la rete core. Il satellite non è a conoscenza della rete 5G, e non partecipa alla gestione della connessione.

Sara il gataway a comunicare con i gNB, e a gestire la connessione con l'UE. Il satellite si limita a trasmettere i dati tra il gateway e l'antenna a terra.

Questa è la soluzione più semplice, adottata dalle prime release NTN.

*NTN Regenerative Payload*: Questa soluzione è più complessa perchè richiede che il satellite svolta le funzionalità di gNB.

Il satellite è a conoscenza della rete 5G, e partecipa alla gestione della connessione. Il satellite riceve i dati dagli utenti, li elabora e li trasmette al gateway, che a sua volta li trasmette alla rete core.

*NTN Regenerative Payload with Functional Split*: Il satellite svolge solo le funzionalità del modulo distributed unit del gNB. Ovvero, il satellite si occupa solo della parte di data plane, mentre la parte di control plane è gestita dal gateway a terra.

Il livelli di protocolli che il satellite deve implementare dipendono dall’opzione di
splitting scelta dall’operatore

