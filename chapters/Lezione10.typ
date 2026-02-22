#import "../template.typ": *

= Mobile Network

Le reti mobili nascono per garantire la connettività anche in movimento, superando i limiti delle reti fisse. L'obbiettivo principale è garantire un servizio alla parti di quello fisso, ma in movimento.

Linee guida progettuali:
- Utilizzare *molti ripetitori* con una potenza $< 100 W$ 
- Meno potenza significa minore raggio di copertura. La stessa area viene quindi divisa in tante piccole *celle*, ognuna coperta da una propria antenna

- Ogni cella è servita da una *base station* che svolge tre funzioni fondamentali:
  - Trasmettitore
  - Ricevitore
  - Unità di controllo

#nota()[
  Soprattutto nelle versioni recenti, c'è una *netta separazione* tra traffico di controllo e traffico dati (sia a livello architetturale che a livello di protocollo).
]

== Base station

Una base station è principalmente composta da un'antenna (remote radio head) e da un'unità di controllo. Le due parti sono indipendenti e possono essere posizionate in luoghi diversi.

Molto spesso le base station operano nello *spettro licenziato* (licenza privata).

I componenti principali sono:
- *Antenna* (remote radio head)
- *Radio unit* (modula e demodula i segnali radio)
- *Control unit* (gestisce il traffico di controllo e coordina le operazioni). La control unit è collegata alla radio unit tramite una connessione in fibra ottica (fronthaul).

I dati vengono modulati e trasmessi sulla portante in base alle frequenze licenziate. Le licenze si pagano sulla banda di frequenze utilizzata nelle telecomunicazioni e non sull'accesso alla rete.

Infine, la base station è collegata alla *rete core* tramite una connessione in fibra ottica (backhaul).

== Rete cellulare

Le *celle* sono progettate teoricamentee per fornire *equidistanza* da un qualsiasi punto della cella rispetto alla base station, senza considerare ostacoli. Nella pratica, la copertura dipende da vari fattori: ostacoli, posizionamento della base station, morfologia del terreno (le celle possono non essere degli esagoni perfetti).

Uno dei requisiti fondamentali della rete cellulare è *garantire la mobilità del dispositivo tra le celle mantenendo la connettività*. Tuttavia, questa mobilità può introdurre una serie di $mr("problemi")$, soprattutto a livello di *interferenze*, in quanto la rete cellulare non è progettata per la coordinazione tra celle vicine (non c'è coordinamento tra le base station).

#attenzione()[
  Un dispositivo situato sul *bordo* di una *cella* può ricevere segnali da più base station. Se queste usano le stesse frequenze, si verificano *interferenze* (mancanza di coordinazione). Per questo sono necessarie politiche di differenziazione delle frequenze tra celle vicine.
]

=== Approccio CDMA

Si usa la *stessa frequenza* utilizzando tecniche di *codifica* per evitare le interferenze tra celle vicine (codice ortogonale). 

- $mg("Vantaggi")$: *non* serve coordinamento e si sfrutta tutto lo spettro.
  
- $mr("Svantaggi")$: minore data rate disponibile per ogni utente.

=== Bande diverse

Si utilizzano *bande diverse* dello stesso spettro per celle vicine: celle adiacenti non hanno alcuna sovrapposizione. 

#attenzione()[
  Per garantire la stessa qualità del servizio è necessario:
  - *Aumentare* lo *spettro* complessivo disponibile, oppure
  - *Diminuire* la *banda* allocata in ogni cella

  Entrambe le soluzioni hanno delle conseguenze: più spettro da pagare o minore data rate per utente.
]

#import "@preview/cetz:0.3.2": canvas, draw

#figure(
  canvas({
    import draw: *
    
    // Funzione per disegnare un esagono
    let hex(x, y, label, color) = {
      let r = 1.2
      let points = ()
      for i in range(6) {
        let angle = 60deg * i
        points.push((x + r * calc.cos(angle), y + r * calc.sin(angle)))
      }
      line(..points, close: true, stroke: 2pt + black, fill: color.transparentize(70%))
      content((x, y), text(size: 14pt, weight: "bold", label))
    }
    
    // Celle centrali con frequenze diverse
    hex(0, 0, "F4", yellow)
    hex(2.1, 0, "F2", red)
    hex(1.05, 1.8, "F3", green)
    hex(-1.05, 1.8, "F1", blue)
    hex(-2.1, 0, "F2", red)
    hex(-1.05, -1.8, "F3", green)
    hex(1.05, -1.8, "F1", blue)
  }),
  caption: [Struttura esagonale delle celle con riuso delle frequenze]
)

=== Bande diverse solo sui bordi

Si tratta di una soluzione più _intelligente_ della precedente.

Al centro della cella viene utilizzata una certa frequenza, mentre si usano *bande* di frequenza *diverse per i bordi* tra celle vicine. In questo modo si garantisce l'assenza di interferenza.

#figure(
  canvas({
    import draw: *
    
    // Funzione per disegnare un esagono
    let hex(x, y, inner_color, border_color) = {
      let r = 1.2
      let r_inner = 0.7
      let points_outer = ()
      let points_inner = ()
      
      // Punti esagono esterno
      for i in range(6) {
        let angle = 60deg * i
        points_outer.push((x + r * calc.cos(angle), y + r * calc.sin(angle)))
      }
      
      // Punti esagono interno
      for i in range(6) {
        let angle = 60deg * i
        points_inner.push((x + r_inner * calc.cos(angle), y + r_inner * calc.sin(angle)))
      }
      
      // Disegna bordo
      line(..points_outer, close: true, stroke: 2pt + black, fill: border_color.transparentize(50%))
      
      // Disegna centro
      line(..points_inner, close: true, stroke: none, fill: inner_color.transparentize(30%))
    }
    
    // Celle con centro e bordo colorati
    hex(0, 0, gray, blue)
    hex(2.1, 0, gray, red)
    hex(1.05, 1.8, gray, green)
    hex(-1.05, 1.8, gray, yellow)
    hex(-2.1, 0, gray, red)
    hex(-1.05, -1.8, gray, green)
    hex(1.05, -1.8, gray, yellow)
    
    // Freccia
    line((3.5, 0), (5, 0), mark: (end: "stealth"), stroke: 2pt + black)
    
    // Box esplicativo a destra
    let box_x = 7
    let box_y = 1.5
    let box_width = 3
    let box_height = 0.8
    
    // Nel centro
    
    
    // Bordo - diviso in 3 parti
    let border_y = box_y - box_height - 0.3
    let part_width = box_width / 3
    
    rect((box_x, border_y), (box_x + part_width, border_y - box_height), 
         fill: yellow.transparentize(30%), stroke: black + 1pt)
    
    rect((box_x + part_width, border_y), (box_x + 2*part_width, border_y - box_height), 
         fill: red.transparentize(30%), stroke: black + 1pt)
    
    rect((box_x + 2*part_width, border_y), (box_x + box_width, border_y - box_height), 
         fill: blue.transparentize(30%), stroke: black + 1pt)
    
    content((box_x + box_width/2 + 1.0, border_y + 0.3), text(size: 9pt, "bordo", blue))

     content((box_x + box_width/2 - 0.5, border_y + 0.3), text(size: 9pt, "Centro"))
    
    // Annotazioni
    content((box_x + box_width/2, border_y - box_height - 0.7), 
            text(size: 8pt, fill: blue, [Maggiore bandwidth]))
    content((box_x + box_width/2, border_y - box_height - 1.1), 
            text(size: 8pt, fill: blue, [(per utenti interni)]))
  }),
  caption: [Allocazione delle frequenze: banda unica al centro, bande diverse sui bordi per evitare interferenze]
)

*Vantaggi*:
- Gli utenti al centro della cella hanno maggiore bandwidth disponibile
- Si evitano interferenze sui bordi dove più celle si sovrappongono

#attenzione()[
  Questa soluzione richiede:
  - Meccanismi di *posizionamento precisi* (OFDMA)
  - Hardware più sofisticato sia a livello di dispositivo che di base station
]

== Migliorare la Scalabilità

Per migliorare la scalabilità della rete, si possono adottare diverse strategie:
- *Cell Sectoring*: suddividere una celle in sotto-celle (settori) con antenne direzionali. Utile per aumentare la capacità in aree ad alta densità di utenti. Il prezzo da pagare è un maggiore traffico di controllo e frequenti *handoff* (cambi di cella).

- Aggiungere più canali radio e spettro (costoso)

- *Prestito di frequenze* (frequency borrowing): permettere a una cella di utilizzare temporaneamente le frequenze di una cella vicina quando è congestionata. Richiede *coordinamento tra le celle* e può introdurre interferenze se non gestito correttamente.


=== Cell Sectoring

Anziché utilizzare un'antenna omnidirezionale (che copre tutta la cella uniformemente), si impiegano *più antenne direzionali* che coprono varie parti della cella. Si ha quindi un'unica base station e una cella a sua volta suddivisa in settori:
- *$mg("Vantaggi")$*: Partizionando la cella in più parti si ha un *minor path loss* a parità di distanza (*antenna gain*). Le antenne direzionali coprono in modo settoriale la cella.
  
- *$mr("Svantaggi")$*: La parte di controllo diventa più complessa.

#nota()[
   Una base station di solito contiene $3$ antenne, ognuna di esse gestisce un settore. Ogni antenna gestisce una sotto-cella. Ogni sotto-cella usa frequenze diverse o i meccanismi visti in precedenza.
]

== Architettura ed operazioni

Struttura generale (rimane invariata in ogni generazione):

*Livello Servizi*: Internet, applicazioni, ecc.

*Core Network* (o anche MTSO - Mobile Telephone Switching Office): Il compito è portare la comunicazione in _rete_. Si occupa di mantenere le informazioni di controllo e di fare da tramite per i servizi esterni.

#nota()[
  La rete mobile non offre servizi direttamente: i servizi sono forniti da entità esterne alla rete.
]

*RAN (Radio Access Network)*: Modulo per l'accesso radio che trasporta le informazioni al controller. Contiene:
- *Base Station Controller*: coordina le base station
- *Dispositivi* mobili
- *Base station*

=== Control Plane e Data Plane

Esistono due tipi di canali che trasportano due tipologie di traffico:

- *Canali di controllo* (Control Plane): Definiscono _che cosa_ deve essere fatto per gestire la rete

- *Canali di dati* (Data Plane): Trasportano voce e dati (traffico dei servizi offerti), indicano _come_ deve essere fatto

#nota()[
  Con l'evoluzione delle tecnologie, i moduli sono stati sempre più separati: ci sono moduli dedicati al controllo e moduli dedicati al canale dati.
]

=== Inizializzazione e monitoraggio del segnale

Inizialmente il dispositivo deve scegliere la migliore cella e richiedere l'accesso a quella cella.

==== Segnali Pilot

Periodicamente vengono inviati dei *pilot*: segnali codificati in modo standard che contengono dati noti. 

#nota()[
  I pilot servono per misurare la qualità del canale:
  - Confrontando il segnale ricevuto con quello atteso si può valutare il degrado
  - Maggiore è la differenza, peggiore è la qualità del canale
  - Permettono di applicare trasformazioni correttive al segnale ricevuto
]

La frequenza di invio dei pilot dipende dal tempo di coerenza del mezzo radio (per quanto tempo le caratteristiche del canale rimangono costanti).

#informalmente()[
  I pilot permettono di avere informazioni aggiornate sullo stato del canale, consentendo di adattare la trasmissione.
]

#attenzione()[
  Queste operazioni sono svolte solamente dalla Radio Access Network.
]

=== Passaggio alla rete core

Deve essere allocato un canale radio dedicato all'utente, richiesto alla base station a cui il dispositivo è connesso. Tutta la comunicazione è gestita dalla base station (non c'è accesso casuale). 

#nota()[
  Si vuole avere un controllo rigido della rete: come nel Bluetooth, la base station è il master.
]

#esempio()[
  Se ci si trova in un luogo in cui non ci sono base station del proprio operatore, l'accesso viene negato e non è possibile trasmettere dati. Sono consentite solo le chiamate di emergenza.
]

=== Paging

Supponiamo che una chiamata arrivi dall'esterno verso un dispositivo mobile. Il MTSO non può tenere traccia in tempo reale di ogni dispositivo su ogni base station (troppi dispositivi).

#nota()[
  Le base station vengono divise in *aree* (gruppi di base station identificati da un codice). Il MTSO tiene traccia solo dell'area in cui si trova un dispositivo (es. area 100).
]

Per trovare la base station specifica viene effettuato il *paging*:
1. Il MTSO invia una richiesta a tutte le base station dell'area
2. Solo la base station che gestisce quel dispositivo risponde
3. Vengono poi trasferiti i dati

==== Vantaggi del Paging

#esempio()[
  I dispositivi possono essere messi in stato *idle*:
  - Rilasciano i canali radio ad altri utenti
  - I servizi in uso vengono salvati in memoria
  - Quando il dispositivo deve ricevere dati, i canali vengono riassegnati
]

#attenzione()[
  Il paging è un'operazione onerosa, quindi si cerca di minimizzarne l'uso.
  
  Esiste un canale specifico dedicato al paging.
]

=== Chiamata accettata

I canali devono essere accettati da entrambe le parti (chiamante e ricevente) e dalle base station coinvolte.

=== Handoff/Handover

*Handoff* è la possibilità di passare da una cella all'altra senza percepire l'interruzione del servizio.

La procedura di handover si articola in tre fasi:

1. *Decisione di una nuova associazione*: rilevamento dello spostamento verso una nuova cella

2. *Gestione nuova associazione*: 
   #attenzione()[
     Non si rilasciano le risorse della vecchia base station finché le nuove risorse non sono pronte nella nuova base station. Altrimenti si avrebbe una perdita di connessione.
   ]

3. *Riconfigurazione percorsi di comunicazione*: aggiornamento del routing, soprattutto verso la rete core

== Ambiente in ambito cellulare

L'ambiente può essere fondamentale nella diffusione del segnale cellulare. La rete è molto influenzata dalla topologia del terreno.

#nota()[
  Aspetti da considerare:
  - *Potenza del segnale*: non deve creare interferenza con le celle vicine ma deve superare gli ostacoli
  - *Variabilità*: rete mobile molto variabile a causa della mobilità degli utenti
  - *Fading*: attenuazione del segnale molto presente (più che nel Wi-Fi)
]

La rete cellulare ha un'attenuazione del Line of Sight molto marcata.

#informalmente()[
  Il *Network Planning* consiste nel prendere la topologia 3D di un sito e studiare come si propaga il segnale in quell'ambiente specifico.
]

== HandOff/HandOver

=== Modalità di decisione

La procedura viene decisa dalla rete osservando le misurazioni del segnale ricevuto per valutare la qualità del canale di comunicazione.

*Approccio 1 - Solo Base Station*:
- La base station osserva la qualità del canale di uplink mentre il dispositivo trasmette (non richiede informazioni aggiuntive)
- Se il canale degrada, può richiedere una procedura di handover

*Approccio 2 - Collaborativo*:
- Il dispositivo viene coinvolto nella decisione
- Il dispositivo invia feedback tramite il segnale di uplink
- Questi feedback descrivono ciò che il dispositivo _percepisce_ dalla base station (usando il downlink)

#nota()[
  La base station è molto veloce nell'eseguire queste operazioni grazie a hardware dedicato.
]

=== Strategie di Handoff


==== Potenza relativa

Dopo un certo punto potrebbe accadere che $"Rx"_B > "Rx"_A$. 

#attenzione()[
  Il *ping pong effect* consiste nell'effettuare handover continui dalla base station $A$ a $B$ e viceversa. Questo effetto è deleterio per le risorse: c'è solo traffico di controllo, non si trasmettono mai dati, si continuano ad allocare e deallocare risorse.
]

#informalmente()[
  L'obiettivo è sempre connettersi alla base station con la potenza massima offerta.
]

==== Potenza relativa + Threshold

Per evitare il ping pong effect si introduce una *threshold* (soglia). Si impone un valore assoluto di riferimento.



#nota()[
  L'handover da base station $A$ a base station $B$ avviene quando sono soddisfatte entrambe le condizioni:
  - $"Rx"_A < T$ (segnale di A minore della soglia in valore assoluto)
  - $"Rx"_B > "Rx"_A$ (segnale di B migliore di quello di A)
]

#attenzione()[
  La criticità è impostare correttamente la threshold: è difficile trovare un valore adeguato per tutti gli scenari.
]

==== Potenza relativa con Isteresi

#informalmente()[
  *Isteresi* = il valore di una funzione non dipende solamente dall'input ma anche dallo stato precedente del sistema.
]

#esempio()[
  Termostato con temperatura impostata a 20°C:
  - Il sistema si spegne quando raggiunge 20°C
  - Il parametro di isteresi determina quando riaccendersi
  - Il riscaldamento non si accende subito a 19.99°C ma, ad esempio, a 19.7°C
  - Questo evita accensioni/spegnimenti continui
]


#nota()[
  Funzionamento dell'isteresi:
  - Sull'asse $x$: potenza relativa $B - A$
  - $+H$: quando $B$ è migliore di $A$ di almeno $H$ si passa a $B$
  - $-H$: quando $A$ è migliore di $B$ di almeno $H$ si torna ad $A$
  - La BS associata (asse $y$) dipende dalla storia: da dove proveniamo
]

#informalmente()[
  L'isteresi fornisce un "buffer" contro le variazioni repentine di segnale, evitando cambi di cella troppo frequenti.
]

#attenzione()[
  Le condizioni per l'handover diventano:
  - $"Rx"_A < T$ (segnale assoluto minore della threshold)
  - $"Rx"_B - "Rx"_A > H$ (potenza relativa di $B$ sufficientemente maggiore rispetto al margine di isteresi)
  
  L'isteresi lavora a livello relativo, ma serve comunque una soglia assoluta ($T$) per garantire una qualità minima.
]

== Hard Handoff vs Soft Handoff

#nota()[
  Esistono due approcci fondamentali:
  
  *Hard Handoff* (dal 2G in avanti):
  - Il dispositivo è associato a una sola BS alla volta
  - Si rilascia la vecchia connessione prima di stabilire la nuova
  - Minore consumo di risorse
  
  *Soft Handoff*:
  - Il dispositivo mantiene la connettività con entrambe le BS contemporaneamente
  - Si rilascia la vecchia BS solo quando il segnale della nuova è chiaramente dominante
  - Maggiore affidabilità ma richiede più risorse
]

== FDD e TDD

In 2G la connessione avveniva in FDD (Frequency Division Duplex).

*FDD - Frequency Division Duplex*:
- Frequenze diverse per uplink e downlink
- #nota()[Vantaggi:
  - Si può trasmettere e ricevere contemporaneamente (nessun delay)
  ]
- #attenzione()[Svantaggi:
  - Richiede maggiori risorse spettrali
  - Metà del datarate disponibile (bisogna dividere lo spettro)
  ]

*TDD - Time Division Duplex*:
- Utilizza una sola frequenza sia per uplink che per downlink
- #nota()[Vantaggi:
  - Migliore efficienza spettrale
  ]
- #attenzione()[Svantaggi:
  - Maggiore ritardo (bisogna aspettare il proprio turno)
  ]

#informalmente()[
  In 4G (LTE) sono presenti entrambe le soluzioni: LTE-FDD e LTE-TDD.
]

== GSM Mobile Station

Il GSM è diviso in due parti distinte:
- *Mobile Equipment* (ME): il dispositivo fisico
- *SIM Card*: la carta SIM che identifica l'utente

=== Mobile Equipment (ME)

Identificativo unico del dispositivo, composto da:
- *TAC* (Type Allocation Code): identifica il costruttore
- *FAC* (Final Assembly Code): identifica dove viene assemblato il dispositivo
- *SN* (Serial Number): numero sequenziale
- *Check Digit*: bit di controllo

#nota()[
  Questo identificativo (chiamato IMEI) identifica in modo univoco un dispositivo mobile ed è utilizzato, ad esempio, in caso di furto per bloccare il dispositivo.
]

=== SIM Card

Identifica un abbonato (un utente). La SIM contiene:
- L'identificativo dell'utente
- La chiave segreta per l'autenticazione
- I dati per la generazione delle chiavi di cifratura

L'identificativo della SIM è chiamato *IMSI* (International Mobile Subscriber Identity) ed è composto da:
- *MCC* (Mobile Country Code): codice dello Stato dell'operatore
- *MNC* (Mobile Network Code): codice dell'operatore, unico a livello nazionale
- *MSIN* (Mobile Subscriber Identification Number): identificativo dell'abbonato

#attenzione()[
  L'IMSI della SIM *non* ha nulla a che vedere con il numero di telefono!
]

=== Numero di telefono (MSISDN)

Il numero di telefono è chiamato *MSISDN* (Mobile Station International Subscriber Directory Number). 

#informalmente()[
  ISDN sta per Integrated Services Digital Network, la rete digitale precursore della DSL.
]

Il numero di telefono è composto da:
- *CC* (Country Code): codice del paese
- *NDC* (National Destination Code): codice di destinazione nazionale
- *Subscriber Number*: numero dell'abbonato

#nota()[
  Oggi *non* esiste più un'associazione 1:1 tra SIM e numero di telefono. Una SIM può avere associati più numeri di telefono. Questa funzionalità è stata introdotta a metà degli anni 2000.
]

= GSM // non in esame

L'idea iniziale di GSM era trasmettere solo voce. Successivamente furono aggiunti gli SMS (che all'inizio erano messaggi di controllo della rete).

#nota()[
  Oggi GSM è essenzialmente un sistema circuit-switched virtualizzato su IP. L'obiettivo è supportare un numero elevato di utenti cambiando il meno possibile l'infrastruttura esistente.
]

GSM è stato standardizzato dall'ETSI (European Telecommunications Standards Institute).

== Caratteristiche tecniche

GSM funzionava con *FDD* (Frequency Division Duplex):
- Due bande di frequenza (uplink e downlink)
- Ogni banda: $25$ MHz
- Ogni banda divisa in $125$ canali da $200$ kHz

#esempio()[
  Specificando il canale 2, si può risalire al dispositivo associato. Ad ogni dispositivo veniva assegnato un canale e un time-slot. Si trasmetteva sempre a intervalli regolari (constant bit rate) in 2G.
]

#informalmente()[
  L'infrastruttura richiedeva un grande investimento per installare le base station e gestire il traffico voce.
]

= GPRS & EDGE

GPRS (General Packet Radio Service) ed EDGE (Enhanced Data rates for GSM Evolution) rappresentano l'integrazione di GSM con la rete Internet.

#nota()[
  L'obiettivo era mantenere l'infrastruttura radio esistente (base station) modificando solamente la parte software e di core network.
  
  In questo modo si poteva riutilizzare l'investimento fatto per il 2G aggiungendo capacità di trasferimento dati a pacchetto.
]

