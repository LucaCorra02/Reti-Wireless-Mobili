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
  I grafici di handoff mostrano la potenza del segnale ricevuto da due base station (A e B) in funzione della distanza. Il dispositivo si sposta da sinistra a destra, avvicinandosi a B e allontanandosi da A.
]


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

#figure(
  canvas(length: 1cm, {
    import draw: *
    
    // Assi principali
    line((0, 0), (10, 0), mark: (end: "stealth"), name: "x-axis")
    line((0, 0), (0, 6), mark: (end: "stealth"), name: "y-axis")
    
    // Etichette assi
    content((10.5, -0.3), [Distanza])
    content((-1.2, 6.3), [Potenza])
    content((0.5, -0.5), text(size: 9pt, [Base]))
    content((0.5, -0.8), text(size: 9pt, [station A, $S_A$]))
    content((9.5, -0.5), text(size: 9pt, [Base]))
    content((9.5, -0.8), text(size: 9pt, [station B, $S_B$]))
    
    // Curve BS A (decrescente, parte alta) e BS B (crescente, parte bassa)
    catmull((0, 5.5), (1.5, 5.0), (3, 4.3), (4.5, 3.5), (6, 2.8), (7.5, 2.2), (9, 1.7), (10, 1.4),
         stroke: blue + 2.5pt, name: "curve-a")
    
    catmull((0, 1.4), (1, 1.7), (2.5, 2.2), (4, 2.8), (5.5, 3.5), (7, 4.3), (8.5, 5.0), (10, 5.5),
         stroke: red + 2.5pt, name: "curve-b")
    
    // Soglie orizzontali
    line((0, 4), (10, 4), stroke: (dash: "dashed", paint: black, thickness: 1.5pt))
    content((-0.5, 4), text(size: 9pt, [$T h_1$]))
    
    line((0, 3), (10, 3), stroke: (dash: "dashed", paint: black, thickness: 1.5pt))
    content((-0.5, 3), text(size: 9pt, [$T h_2$]))
    
    line((0, 2.4), (10, 2.4), stroke: (dash: "dashed", paint: black, thickness: 1.5pt))
    content((-0.5, 2.4), text(size: 9pt, [$T h_3$]))
    
    // Punto di intersezione
    circle((5, 3.15), radius: 0.1, fill: black)
    line((5, 0), (5, 3.15), stroke: (dash: "dotted", paint: gray, thickness: 1pt))
    
    // Punti significativi
    // L1: Curva A incrocia Th1
    circle((2.1, 4), radius: 0.08, fill: purple)
    line((2.1, 0), (2.1, 4), stroke: (dash: "dotted", paint: purple, thickness: 1pt))
    content((2.1, -0.5), text(size: 9pt, fill: purple, [$L_1$]))
    
    // L2: Intersezione
    circle((5, 3.15), radius: 0.08, fill: green)
    line((5, 0), (5, 3.15), stroke: (dash: "dotted", paint: green, thickness: 1pt))
    content((5, -0.5), text(size: 9pt, fill: green, [$L_2$]))
    
    // L3: Handoff (curva A sotto Th3 e B > A)
    circle((6.5, 2.4), radius: 0.08, fill: orange)
    line((6.5, 0), (6.5, 2.4), stroke: (dash: "dotted", paint: orange, thickness: 1pt))
    content((6.5, -0.5), text(size: 9pt, fill: orange, weight: "bold", [$L_3$]))
    
    // L4: Curva B incrocia Th1
    circle((7.9, 4), radius: 0.08, fill: purple)
    line((7.9, 0), (7.9, 4), stroke: (dash: "dotted", paint: purple, thickness: 1pt))
    content((7.9, -0.5), text(size: 9pt, fill: purple, [$L_4$]))
    
    // Freccia e annotazione per H (margine di isteresi)
    line((9.5, 2.4), (9.5, 3.15), mark: (start: "stealth", end: "stealth"), stroke: blue + 1.5pt)
    content((10.2, 2.8), text(size: 9pt, fill: blue, [$H$]))
    
    // Etichette curve
    content((1.5, 5.3), text(fill: blue, weight: "bold", [$P r_1$]))
    content((8.5, 5.3), text(fill: red, weight: "bold", [$P r_2$]))
    
    // Punto handoff evidenziato
    content((6.5, 1.8), text(size: 9pt, fill: orange, weight: "bold", [Handoff]))
  }),
  caption: [Strategia potenza relativa + soglia: L'handoff da BS A a BS B avviene in $L_3$ quando $P r_1 < T h_3$ e $P r_2 > P r_1$. Le soglie multiple mostrano diversi livelli di qualità del segnale.]
)

#nota()[
  L'handover da base station $A$ a base station $B$ avviene quando sono soddisfatte entrambe le condizioni:
  - $"Rx"_A < T$ (segnale di A minore della soglia in valore assoluto)
  - $"Rx"_B > "Rx"_A$ (segnale di B migliore di quello di A)
  
  Nel grafico, l'handoff avviene in posizione $L_3$ ($T h_3$).
]

#attenzione()[
  La criticità è impostare correttamente la threshold: è difficile trovare un valore adeguato per tutti gli scenari.
]

==== Potenza relativa con Isteresi

#figure(
  canvas(length: 1cm, {
    import draw: *
    
    // Assi principali
    line((0, 0), (10, 0), mark: (end: "stealth"), name: "x-axis")
    line((0, 0), (0, 6), mark: (end: "stealth"), name: "y-axis")
    
    // Etichette assi
    content((10.5, -0.3), [Distanza])
    content((-0.7, 6.3), [Potenza])
    content((0.3, -0.5), [$L_A$])
    content((9.7, -0.5), [$L_B$])
    
    // Curve BS A (decrescente) e BS B (crescente) - partono dagli assi
    catmull((0, 5.8), (1, 5.2), (2, 4.5), (3, 3.8), (4, 3.2), (5, 2.7), (6, 2.3), (7, 1.9), (8, 1.6), (9, 1.3), (10, 1.0),
         stroke: blue + 2pt, name: "curve-a")
    
    catmull((0, 1.0), (1, 1.3), (2, 1.6), (3, 1.9), (4, 2.3), (5, 2.7), (6, 3.2), (7, 3.8), (8, 4.5), (9, 5.2), (10, 5.8),
         stroke: red + 2pt, name: "curve-b")
    
    // Threshold orizzontale
    line((0.5, 2.5), (9.5, 2.5), stroke: (dash: "dashed", paint: black, thickness: 1.5pt))
    content((0.3, 2.5), [$T$])
    
    // Soglie di isteresi (tracciate come offset dalle curve)
    line((0.5, 2.2), (9.5, 2.2), stroke: (dash: "dashed", paint: purple, thickness: 1pt))
    content((0.2, 2.2), text(size: 8pt, fill: purple, [$T_2$]))
    
    line((0.5, 2.8), (9.5, 2.8), stroke: (dash: "dashed", paint: purple, thickness: 1pt))
    content((0.2, 2.8), text(size: 8pt, fill: purple, [$T_1$]))
    
    // Intersezione
    circle((5, 2.7), radius: 0.08, fill: black)
    content((5, 2.3), [$L_1$])
    
    // Punto handoff A->B (con isteresi, più a destra)
    circle((6, 2.4), radius: 0.08, fill: green)
    line((6, 0), (6, 2.4), stroke: (dash: "dotted", paint: green))
    content((6, -0.5), text(fill: green, [$L_2$]))
    
    // Punto handoff B->A (con isteresi, più a sinistra)
    circle((4, 2.9), radius: 0.08, fill: orange)
    line((4, 0), (4, 2.9), stroke: (dash: "dotted", paint: orange))
    content((4, -0.5), text(fill: orange, [$L_3$]))
    
    // Rettangolo che evidenzia la zona di isteresi
    rect((4, 2.2), (6, 2.8), stroke: purple + 1pt, fill: purple.transparentize(90%))
    
    // Frecce per indicare H (margine di isteresi)
    line((9.8, 2.5), (9.8, 2.8), mark: (start: "stealth", end: "stealth"), stroke: purple + 1.5pt)
    content((10.3, 2.65), text(size: 9pt, fill: purple, [$H$]))
    
    // Etichette curve
    content((2, 5), text(fill: blue, [BS $A$, $S_A$]))
    content((8, 5), text(fill: red, [BS $B$, $S_B$]))
    
    // Annotazioni
    content((6, 3.1), text(size: 8pt, fill: green, [A→B]))
    content((4, 3.6), text(size: 8pt, fill: orange, [B→A]))
    
    // Grafico laterale per mostrare l'isteresi (spostato più a destra e ingrandito)
    let hx = 12
    let hy = 3
    
    // Assi del grafico isteresi
    line((hx, hy - 2), (hx, hy + 2), mark: (end: "stealth"), stroke: black + 1pt)
    line((hx - 0.5, hy), (hx + 2.5, hy), mark: (end: "stealth"), stroke: black + 1pt)
    
    content((hx + 2.8, hy - 0.1), text(size: 8pt, [$(P_B - P_A)$]))
    content((hx - 0.2, hy + 2.3), text(size: 8pt, [BS]))
    
    // Funzione di isteresi (a gradino)
    line((hx - 0.4, hy - 1.5), (hx + 0.4, hy - 1.5), stroke: red + 2.5pt)
    line((hx + 0.4, hy - 1.5), (hx + 0.4, hy + 1.5), stroke: red + 2.5pt, mark: (start: "stealth", end: "stealth"))
    line((hx + 0.4, hy + 1.5), (hx + 2.2, hy + 1.5), stroke: red + 2.5pt)
    
    // Soglie verticali tratteggiate
    line((hx - 0.4, hy - 2), (hx - 0.4, hy + 2), stroke: (dash: "dashed", paint: purple, thickness: 1.5pt))
    content((hx - 0.7, hy - 1.7), text(size: 8pt, fill: purple, weight: "bold", [$-H$]))
    
    line((hx + 0.4, hy - 2), (hx + 0.4, hy + 2), stroke: (dash: "dashed", paint: purple, thickness: 1.5pt))
    content((hx + 0.7, hy + 1.7), text(size: 8pt, fill: purple, weight: "bold", [$+H$]))
    
    // Frecce di transizione (opzionali, per chiarezza)
    line((hx + 0.1, hy - 1.2), (hx + 0.7, hy - 1.2), mark: (end: "stealth"), stroke: gray + 1pt)
    line((hx + 0.7, hy + 1.2), (hx + 0.1, hy + 1.2), mark: (end: "stealth"), stroke: gray + 1pt)
    
    // Etichette BS
    content((hx + 1.8, hy + 1.8), text(size: 9pt, weight: "bold", [B]))
    content((hx - 0.8, hy - 1.2), text(size: 9pt, weight: "bold", [A]))
  }),
  caption: [Grafico 2: Handoff con isteresi. L'handoff A→B avviene in $L_2$, mentre B→A in $L_3$. Il margine $H$ previene il ping-pong effect. Il grafico a destra mostra la funzione di isteresi rispetto alla potenza relativa.]
)

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

