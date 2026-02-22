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

La struttura generale (rimane invariata in ogni generazione) è suddivisa in tre parti principali:

- *Livello Servizi*: Internet, applicazioni, ecc.
  #nota()[
    La rete mobile *non* offre servizi direttamente: i servizi sono forniti da entità esterne alla rete.
  ]

- *Core Network* (o anche *MTSO* - Mobile Telephone Switching Office): Il compito è portare la comunicazione in _rete_. Si occupa di mantenere le informazioni di controllo e di fare da tramite per i servizi esterni.

- *RAN (Radio Access Network)*: Modulo per l'accesso radio che trasporta le informazioni al controller. Contiene:
  - *Base Station Controller*: coordina le varie base station
  - *Dispositivi* mobili
  - *Base station*

=== Control Plane e Data Plane

Esistono due tipi di canali che trasportano due tipologie di traffico diverse:

- *Canali di controllo* (Control Plane): Definiscono _che cosa_ deve essere fatto per gestire la rete

- *Canali di dati* (Data Plane): Trasportano voce e dati (traffico dei servizi offerti), indicano _come_ deve essere fatto

#nota()[
  Con l'evoluzione delle tecnologie, i moduli sono stati sempre più separati: ci sono moduli dedicati al controllo e moduli dedicati al canale dati.
]

=== Inizializzazione e monitoraggio del segnale

Il dispositivo mobile, quando si accende, inizia a monitorare i segnali delle base station vicine per valutare la qualità del canale (sceglie la migliore).

Periodicamente ogni base station invia dei segnali di broadcast (*pilot*) che contengono informazioni sulla rete (es. ID della cella, potenza del segnale, ecc.). Il dispositivo mobile riceve questi segnali e valuta la qualità del canale per decidere a quale base station connettersi.

La *frequenza di invio* dei pilot dipende dal *tempo di coerenza* del mezzo radio (per quanto tempo le caratteristiche del canale rimangono costanti).

La *qualità del canale* può essere valutata in diversi modi:
  - Confrontando il segnale ricevuto con quello atteso, valutando il *degrado*. Maggiore è la differenza, peggiore è la qualità del canale.

  - La potenza del segnale ricevuto (RSSI - Received Signal Strength Indicator) è un indicatore diretto della qualità del canale: più è alto, migliore è la qualità.

#nota()[
  Inoltre, i pilot, possono essere inviati anche durante la comunicazione per monitorare continuamente la qualità del canale e *adattare la trasmissione* corregendola se necessario (es. per il handover).
]

#attenzione()[
  Queste operazioni sono svolte solamente dalla Radio Access Network.
]

=== Comunicazione iniziata dal dispositivo

Un dispositivo mobile può iniziare una comunicazione verso l'esterno (es. chiamata, invio dati) solo dopo essersi connesso a una base station. In particolare, deve essere *allocato un canale* radio dedicato all'utente, richiesto alla base station a cui il dispositivo è connesso. 

Una volta stabilita la comunicazione dispositivo-base station, la base station si occupa di instradare i dati verso la *rete core* (MTSO) che a sua volta li instrada verso la destinazione finale (es. Internet).

#nota()[
  Tutta la comunicazione è gestita dalla base station. Il dispositivo mobile è sempre connesso a una base station, anche quando è in idle (non sta trasmettendo dati). 

  L'idea è di avere un *controllo centralizzato* sulla rete, evitando comunicazioni dirette tra dispositivi mobili (come accadeva in Bluetooth, la base station è il master). 
]
 
#esempio()[
  Se ci si trova in un luogo in cui non ci sono base station del proprio operatore, l'accesso viene negato e non è possibile trasmettere dati. Sono consentite solo le chiamate di emergenza.
]

=== Paging

Supponiamo che una *chiamata arrivi dall'esterno* verso un dispositivo mobile. Il MTSO non può tenere traccia in tempo reale di ogni dispositivo connesso ad ogni base station (troppi dispositivi, prodotto cartesiano esplode).

Per questo motivo, le *base station* vengono *divise in aree* (gruppi di base station identificati da un codice). Il MTSO tiene traccia solo dell'area in cui si trova un dispositivo (es. area 100).

Per trovare la base station specifica a cui è collegato il dispositivo, viene effettuato il *paging*:
1. Il MTSO invia una richiesta a tutte le base station dell'area
2. Solo la base station che gestisce quel dispositivo risponde
3. Vengono poi trasferiti i dati

#figure(
  canvas({
    import draw: *
    
    let hex(x, y) = {
      let r = 1.0
      let points = ()
      for i in range(6) {
        let angle = 60deg * i
        points.push((x + r * calc.cos(angle), y + r * calc.sin(angle)))
      }
      line(..points, close: true, stroke: 2pt + blue.darken(30%), fill: blue.transparentize(85%))
    }
    
    // Funzione per disegnare un'antenna (triangolo)
    let antenna(x, y, highlight: false) = {
      let col = if highlight { red } else { blue.darken(50%) }
      let h = 0.25
      line((x - 0.15, y - h), (x, y + h), (x + 0.15, y - h), close: true, 
           fill: col, stroke: col.darken(20%) + 1pt)
    }
    
    // Funzione per disegnare un dispositivo (pallino rosso)
    let device(x, y) = {
      circle((x, y), radius: 0.12, fill: red, stroke: red.darken(30%) + 1pt)
    }
    
    // Disegna le celle in un pattern esagonale (area di paging)
    let cells = (
      (0, 0), (2, 0), (4, 0),
      (1, 1.7), (3, 1.7),
      (1, -1.7), (3, -1.7)
    )
    
    for cell in cells {
      hex(cell.at(0), cell.at(1))
      antenna(cell.at(0), cell.at(1))
    }
    
    // Aggiungi dispositivi (pallini rossi) in varie celle
    device(0.3, 0.2)
    device(1.7, 0.4)
    device(2.5, -0.3)
    device(3.2, 1.9)
    device(1.3, -1.5)
    device(3.8, -1.8)
    device(4.2, 0.3)
    
    // Evidenzia la cella che ha il dispositivo cercato
    antenna(2, 0, highlight: true)
    circle((2.5, -0.3), radius: 0.25, stroke: red + 2pt, fill: none)
    
    // MTSO (scatola a destra)
    let mtso_x = 7
    let mtso_y = 0
    rect((mtso_x - 0.6, mtso_y - 1.5), (mtso_x + 0.6, mtso_y + 1.5), 
         fill: rgb("#8B4513").transparentize(20%), stroke: black + 2pt)
    
    content((mtso_x, mtso_y + 0.7), text(fill: white, size: 11pt, weight: "bold", [M]))
    content((mtso_x, mtso_y + 0.2), text(fill: white, size: 11pt, weight: "bold", [T]))
    content((mtso_x, mtso_y - 0.3), text(fill: white, size: 11pt, weight: "bold", [S]))
    content((mtso_x, mtso_y - 0.8), text(fill: white, size: 11pt, weight: "bold", [O]))
    
    // Linee dalle base station al MTSO
    for cell in cells {
      let is_responding = (cell.at(0) == 2 and cell.at(1) == 0)
      let line_color = if is_responding { red } else { gray }
      let line_width = if is_responding { 2pt } else { 1pt }
      
      line((cell.at(0) + 0.3, cell.at(1)), (mtso_x - 0.6, mtso_y), 
           stroke: line_color + line_width,
           mark: (end: if is_responding { "stealth" } else { none }))
    }
    
    // Legenda
    content((mtso_x, -3), text(size: 8pt, fill: red, [← BS che risponde]))
    content((2, -3), text(size: 8pt, [Dispositivo cercato]))
  }),
  caption: [Processo di paging: il MTSO interroga tutte le base station dell'area, solo quella che gestisce il dispositivo risponde]
)

Inoltre, i dispositivi possono essere messi in stato *idle*:
  - Rilasciano i canali radio ad altri utenti. Inoltre viene risparmiata la batteria.
  - I servizi in uso vengono salvati in memoria

Quando il dispositivo deve ricevere dati, i canali vengono riassegnati, è la base station che si occupa di *risvegliare* il dispositivo attraverso il *paging*

#attenzione()[
  Il paging è un'operazione onerosa, quindi si cerca di *minimizzarne* l'uso.
  
  Esiste un canale specifico dedicato al paging.
]

=== Chiamata accettata

Il dispsitivo destinatario accetta la chiamata. MTSO crea un *circuito* virtuale tra le due base station (quella del chiamante e quella del ricevente) e instrada i dati attraverso la rete core.

Le base station coinvolte devono accettare la comunicazione (allocare risorse, ecc.) prima di stabilire la connessione.


=== Handoff/Handover

*Handoff* è la possibilità di passare da una cella all'altra (rispetto a dove è stata iniziata la comunicazione) senza percepire l'interruzione del servizio.

La procedura di handover si articola in tre fasi:
1. *Decisione di una nuova associazione*: rilevamento dello spostamento verso una nuova cella

2. *Gestione nuova associazione*: 
   
3. *Riconfigurazione percorsi di comunicazione*: aggiornamento del routing, soprattutto verso la rete core

#attenzione()[
  Il dispositivo *non* rilascia le risorse della vecchia base station finché le nuove risorse non sono pronte nella nuova base station. Altrimenti si avrebbe una perdita di connessione (interruzione del servizio).
]

== Ambiente in ambito cellulare

L'ambiente può essere fondamentale nella *diffusione* del segnale cellulare. La rete è molto influenzata dalla topologia del terreno. L'ambiente è molto più imprevedibile rispetto agli altri scenari wireless. 

Aspetti da considerare:
  - *Potenza del segnale*: non deve creare interferenza con le celle vicine ma deve superare gli ostacoli
  - *Variabilità*: rete mobile molto variabile a causa della mobilità degli utenti
  - *Fading*: attenuazione del segnale molto presente (più che nel Wi-Fi)

#nota()[
  La rete cellulare ha un'attenuazione del Line of Sight molto marcata. 
]

Il *Network Planning* consiste nel prendere la topologia 3D di un sito e studiare come si propaga il segnale in quell'ambiente specifico. In paricolare vengono studiati i *punti di interesse* (es. strade, edifici, ecc.) per garantire una copertura adeguata. Alcuni parametri da considerare:
- Posizionamento delle base station
- Dimensionamento delle Base Station (potenza, numero di antenne, ecc.)
- Rete di backhaul (collegamento tra base station e rete core)
- Bande da utilizzare (bande più basse penetrano meglio negli edifici, ma hanno meno capacità)


== HandOff/HandOver

La procedura di handover è fondamentale per garantire la continuità del servizio durante lo spostamento tra celle. Esistono due approcci principali:

*Approccio 1 - Solo Base Station*: La base station osserva la qualità del canale di *uplink* mentre il dispositivo trasmette (*non* richiede informazioni aggiuntive). Se il canale degrada, può richiedere una procedura di handover.

*Approccio 2 - Collaborativo*: Il dispositivo viene coinvolto nella decisione. Esso invia dei feedback tramite il segnale di uplink. Tali feedback descrivono ciò che il dispositivo _percepisce_ dalla base station (usando il *downlink*).

#nota()[
  La base station è molto veloce nell'eseguire queste operazioni grazie a hardware dedicato.
]

Il parametro principale per la decisione del cambiamento di cella è la *potenza del segnale* ricevuta a livello di base station (RSSI) e dal dispositivo (se coinvolto). La potenza del segnale è un indicatore diretto della qualità del canale: più è alto, migliore è la qualità.

=== Strategie di Handoff

#nota()[
  I grafici di handoff mostrano la potenza del segnale ricevuto da due base station ($A$ e $B$) in funzione della distanza. Il dispositivo si sposta da sinistra a destra, avvicinandosi a $B$ e allontanandosi da $A$.

  Come si può vedere, la potenza del segnale di $A$ diminuisce con la distanza, mentre quella di $B$ aumenta. Il punto di *intersezione* è quello in cui i segnali di $A$ e $B$ sono uguali.

]

//fix path
#align(center)[
  #image("..\assets\handoff-graph.png", width: 55%) 
]

#informalmente()[
  L'obiettivo è sempre connettersi alla base station con la potenza massima offerta (dove la potenza del segnale è più alta).
]


==== Potenza relativa

La prima strategia prevede di effettuare l'handover quando la potenza del segnale di $B$ supera quella di $A$ (*punto di intersezione* $L_1$ nell'immagine ). Dopo il punto di intersezione accade che:
$
  "Rx"_B > "Rx"_A 
$
Dopo questo punto viene effettuato l'handover da $A$ a $B$.

Il $mr("problema")$ principale di questo approccio è il *ping pong effect*: esso consiste nell'effettuare handover continui dalla base station $A$ a $B$ e viceversa. 

In questo scenario, il dispositivo si trova in una zona di *confine* tra le due celle, dove la potenza del segnale è simile. Piccole variazioni (es. ostacoli, fading) possono far cambiare rapidamente la potenza del segnale, causando handover continui.

#attenzione()[
  Tale effetto è *deleterio per le risorse*: c'è solo traffico di controllo, non si trasmettono mai dati, si continuano ad allocare e deallocare risorse.
]


==== Potenza relativa + Threshold

Oltre alla potenza relativa del segnale viene introdotta una *soglia* (threshold) $T$ per evitare il ping pong effect. L'handover da base station $A$ a base station $B$ avviene quando sono soddisfatte *entrambe* le condizioni:
  - $"Rx"_A < T$ (segnale di A minore della soglia in valore assoluto)
  - $"Rx"_B > "Rx"_A$ (segnale di B migliore di quello di A)

#esempio()[
  Nel grafico, l'handoff avviene in posizione $L_4$ ($T h_3$). In questo modo si evita il ping pong effect, ma si rischia di rimanere con un segnale di bassa qualità (tra $L_1$ e $L_3$) per un periodo di tempo più lungo.

  Il segnale di $A$ deve *rimanere sotto la soglia* $T_(h 3)$ per un lasso di tempo elevato prima di effettuare l'handover.
]

#attenzione()[
  La *criticità* è impostare correttamente la threshold: è difficile trovare un valore adeguato per tutti gli scenari.
]

==== Potenza relativa con Isteresi

*Isteresi*: il valore di una funzione non dipende solamente dall'input ma anche dallo stato precedente del sistema.

#informalmente()[
  L'isteresi fornisce un *_buffer_* contro le variazioni repentine di segnale, evitando cambi di cella troppo frequenti.
]

#esempio()[
  Termostato con temperatura impostata a 20°C:
  - Il sistema si spegne quando raggiunge 20°C
  - Il parametro di isteresi determina quando riaccendersi
  - Il riscaldamento non si accende subito a 19.99°C ma, ad esempio, a 19.7°C
  - Questo evita accensioni/spegnimenti continui
]

Funzionamento dell'isteresi:
- Sull'asse $x$: potenza relativa $P_B - P_A$

- Punto $+H$: quando $B$ è migliore di $A$ di almeno $H$ si passa a $B$

- Punto $-H$: quando $A$ è migliore di $B$ di almeno $H$ si torna ad $A$

- La BS associata (asse $y$) dipende dalla *storia*: da dove proveniamo

Nel grafico l'isteresi è rappresentata dalla curva tratteggiata sfalsata di $H$.

#figure(
  canvas(length: 0.7cm, {
    import draw: *
    
    let w = 8
    let h = 4
    
    // Assi
    line((-w/2, 0), (w/2, 0), mark: (end: "stealth"), stroke: black + 1.5pt)
    line((0, -0.5), (0, h+2), mark: (end: "stealth"), stroke: black + 1.5pt)
    
    // Etichette assi
    content((w/2 + 1.2, -0.7), text(size: 10pt, [$(P_B - P_A)$]))
    content((-1.5, h + 1.8), text(size: 10pt, [Assignment]))
    
    // Posizioni soglie
    let threshold = 2.2
    
    // Livelli di assegnazione
    let level_A = 1.2
    let level_B = 3.8
    
    // Rettangolo di isteresi (ciclo)
    // Linea orizzontale bassa (Assigned to A) - da sinistra fino a +H
    line((-w/2 + 0.5, level_A), (threshold, level_A), stroke: red + 3pt)
    
    // Linea verticale a +H (salto verso B)
    line((threshold, level_A), (threshold, level_B), stroke: red + 3pt)
    
    // Linea orizzontale alta (Assigned to B) - da +H fino a -H
    line((threshold+1.5, level_B), (-threshold, level_B), stroke: red + 3pt)
    
    // Linea verticale a -H (salto verso A)
    line((-threshold, level_B), (-threshold, level_A), stroke: red + 3pt)
    
    // Completa il ciclo
    line((-threshold, level_A), (-w/2 + 0.5, level_A), stroke: red + 3pt)
    
    // Soglie verticali tratteggiate
    line((-threshold, -0.3), (-threshold, 0.3), stroke: (dash: "dashed", paint: black, thickness: 1.5pt))
    line((threshold, -0.3), (threshold, 0.3), stroke: (dash: "dashed", paint: black, thickness: 1.5pt))
    
    content((-threshold, -0.7), text(size: 10pt, weight: "bold", [$-H$]))
    content((threshold, -0.7), text(size: 10pt, weight: "bold", [$+H$]))
    
    // Etichette assegnazione
    content((-w/2 + 0.5, level_A - 0.4), text(size: 10pt, [Assigned to A]))

    content((w/2 , level_B+0.5), text(size: 10pt, [Assigned to B]))

    content((-w/2 + 1.8, level_B+0.5), text(size: 10pt, [B]))

     content((w/2- 1.2, level_A - 0.2), text(size: 10pt, [A]))
    
    // FRECCE per le transizioni
    // Freccia a destra (handoff to B) - verso l'alto
    line((threshold + 0.4, level_A + 0.5), (threshold + 0.4, level_B - 0.5), 
         mark: (end: "stealth"), stroke: orange + 2.5pt)
    content((threshold + 1.3, (level_A + level_B)/2), text(size: 9pt, fill: orange, [Handoff]))
    content((threshold + 1.3, (level_A + level_B)/2 - 0.4), text(size: 9pt, fill: orange, [to B]))
    
    // Freccia a sinistra (handoff to A) - verso il basso
    line((-threshold - 0.4, level_B - 0.5), (-threshold - 0.4, level_A + 0.5), 
         mark: (end: "stealth"), stroke: green + 2.5pt)
    content((-threshold - 1.3, (level_A + level_B)/2), text(size: 9pt, fill: green, [Handoff]))
    content((-threshold - 1.3, (level_A + level_B)/2 - 0.4), text(size: 9pt, fill: green, [to A]))
  }),
  caption: [Funzione di isteresi per l'handoff: il ciclo mostra come l'assegnazione dipenda dalla storia. Handoff A→B avviene a $+H$, handoff B→A avviene a $-H$.]
)

Le *condizioni* per l'handover diventano:
- $"Rx"_A < T$ (segnale assoluto minore della threshold)
- $"Rx"_B - "Rx"_A > H$ (potenza relativa di $B$ sufficientemente maggiore rispetto al margine di isteresi)

#nota()[
  L'isteresi lavora a livello relativo, ma *serve comunque una soglia assoluta* ($T$) per garantire una qualità minima. Altrimenti, si potrebbe effettuare l'handover a $B$ anche quando il segnale di $A$ è ancora molto forte (es. tra $L_1$ e $L_3$), causando una degradazione della qualità del servizio.
]

=== Hard Handoff vs Soft Handoff

Esistono due approcci fondamentali:

-  *Hard Handoff* (dal 2G in avanti):
  - Il dispositivo è associato a *una sola Base Station* alla volta
  - Si rilascia la vecchia connessione prima di stabilire la nuova
  - Minore consumo di risorse
  
- *Soft Handoff*:
  - Il dispositivo mantiene la *connettività con entrambe le BS* contemporaneamente
  - Si rilascia la vecchia BS solo quando il segnale della nuova è chiaramente dominante
  - Maggiore affidabilità ma richiede più risorse

== FDD e TDD

=== FDD - Frequency Division Duplex

In 2G la connessione avveniva in FDD (Frequency Division Duplex). Ovvero si utilizzano *frequenze diverse* per uplink e downlink:

*$mg("Vantaggi")$*:
  - Si può trasmettere e ricevere contemporaneamente (nessun delay)
  
*$mr("Svantaggi")$*:
  - Richiede uno spettro più ampio
  - *Metà del datarate* disponibile (bisogna dividere lo spettro)
  

=== TDD - Time Division Duplex

Utilizza *una sola frequenza* sia per uplink che per downlink. In 4G (LTE) sono presenti entrambe le soluzioni: LTE-FDD e LTE-TDD.

*$mg("Vantaggi")$*:
  - Migliore efficienza spettrale
  
*$mr("Svantaggi")$*:
  - Maggiore ritardo (bisogna aspettare il proprio turno)
  
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

