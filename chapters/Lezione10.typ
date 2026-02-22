#import "../template.typ": *

= Mobile Network

Il problema delle reti cellulari di prima generazione era fornire un servizio competitivo con la telefonia fissa, ma con la mobilità. Questo era l'obiettivo principale.

== Linee guida progettuali

- Utilizzare molti ripetitori con una potenza minore di $100$ W
- Meno potenza significa minore raggio di copertura. La stessa area veniva quindi divisa in tante piccole celle, ognuna coperta da una propria antenna

#attenzione()[
  Ogni cella è servita da una base station che svolge tre funzioni fondamentali:
  - Trasmettitore
  - Ricevitore
  - Unità di controllo
]

#nota()[
  Netta separazione tra traffico di controllo e traffico dati (anche a livello architetturale).
]

Molto spesso le base station operano con lo spettro licenziato (licenza privata).

== Base station

La base station ha una parte di antenne (remote radio head) staccabile dalla parte di controllo.

I componenti principali sono:
- Cablatura in fibra ottica per il collegamento
- Base band unit (gestisce i dati in banda base)

I dati vengono modulati e trasmessi sulla portante in base alle frequenze licenziate. Le licenze si pagano sulla banda di frequenze utilizzata nelle telecomunicazioni.

== Rete cellulare

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
    hex(0, 0, "F1", blue)
    hex(2.1, 0, "F2", red)
    hex(1.05, 1.8, "F3", green)
    hex(-1.05, 1.8, "F1", blue)
    hex(-2.1, 0, "F2", red)
    hex(-1.05, -1.8, "F3", green)
    hex(1.05, -1.8, "F1", blue)
  }),
  caption: [Struttura esagonale delle celle con riuso delle frequenze]
)

Le celle sono progettate teoricamente per avere equidistanza da un qualsiasi punto della cella rispetto alla base station, senza considerare ostacoli. Nella pratica, la copertura dipende da vari fattori: ostacoli, posizionamento della base station, morfologia del terreno.

#nota()[
  Uno dei requisiti fondamentali della rete cellulare è garantire la mobilità del dispositivo tra le celle mantenendo la connettività.
]

#attenzione()[
  Sul bordo di una cella si possono ricevere segnali da più base station. Se queste usano le stesse frequenze, si verificano interferenze (mancanza di coordinazione). Per questo sono necessarie politiche di riuso delle frequenze.
]

=== Approccio CDMA

Si usa la stessa frequenza utilizzando tecniche di codifica per evitare le interferenze tra celle vicine (codice ortogonale). 

#nota()[
  Vantaggi: non serve coordinamento e si sfrutta tutto lo spettro.
  
  Svantaggi: minore data rate disponibile per ogni utente.
]

=== Bande diverse

Si utilizzano bande diverse dello stesso spettro per celle vicine: celle adiacenti non hanno alcuna sovrapposizione. 

#attenzione()[
  Per garantire la stessa qualità del servizio è necessario:
  - Aumentare lo spettro complessivo disponibile, oppure
  - Diminuire la banda allocata in ogni cella
]

=== Bande diverse solo sui bordi

Soluzione più intelligente della precedente. Per il centro della cella viene utilizzata una certa frequenza, mentre si usano bande di frequenza diverse per i bordi. In questo modo si garantisce l'assenza di interferenza.

#attenzione()[
  Questa soluzione richiede:
  - Meccanismi di posizionamento precisi (OFDMA)
  - Hardware più sofisticato sia a livello di dispositivo che di base station
]


= Lezione 10

== Indoor Coverage

All'interno di locali è necessario garantire un passaggio omogeneo tra l'esterno e l'interno dell'edificio, senza cambiare la tecnologia di accesso.

#nota()[
  Se il tempo riservato al traffico di controllo è insufficiente, si creano code di dispositivi che devono effettuare operazioni di _handover_ e _handoff_.
]

== Cell Sectoring

Anziché utilizzare un'antenna omnidirezionale (che copre tutta la cella uniformemente), si impiegano più antenne direzionali che coprono varie parti della cella. Si ha quindi una base station con la cella suddivisa in settori.

#esempio()[
  Una base station solitamente contiene 3 antenne e ognuna di queste gestisce un settore. Ogni antenna gestisce una sotto-cella. Ogni sotto-cella usa frequenze diverse o i meccanismi visti in precedenza.
]

#nota()[
  *Vantaggi*: Partizionando la cella in più parti si ha un minor path loss a parità di distanza (antenna gain). Le antenne direzionali coprono in modo settoriale la cella.
  
  *Svantaggi*: La parte di controllo diventa più complessa.
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

L'ambiente può essere fondamentale nella diffuzione del segnale cellulare. La rete è molto influenzata dalla topologia del terreno.

Dobbiamo capire:
- Potenza del segnale. Non deve creare interferenza con le celle vicine ma superare gli ostacoli
- Rete mobile molto variabile a casua della mobilità
- Fading, attenuazine del segnale molto presente (a differenza di wifi)

La rete cellulare ha una attenuazione del Line of Site molto marcata.

Queste operazioni prendono il nome di NetworkPlaning. Prendono al topologia 3D di un sito e studiano come si propaga il segnale in questo ambiente.

== HandOff/HandOver

Viene fatto in questo modo:
- La procedura viene decisa dalla rete osservando le misurazioni del segnale ricevuto per capire quanto è buono il canale di comunicazione.

  La basestation osserva la qualità del canale di uplink (non chiede informazioni aggiuntive) mentre il dispositivo trasmette. Se il canale è andato, può richiedere una procedura di handover.

- Il dispositivo può essere coinvolto nella decisione. Il dispositivo invia dei feedback tramite il segnale di uplink. Si tratta di cioò che il dispositivo _capisce_ dalla basestation (viene usato il downlink).

Sono informazioni che la basestation può utilizzare. La basestaion è molto veloce nel fare queste operazioni (garantito dall'hardware)

//aggiugnere grafico

Il grafico è in scala logaritimica.

=== Potenza relativa

Dopo un po potrebbe cadere che $"Rx"_B$ < $"Rx"_A$. Il *ping pong* effect è che facciamo un handover continuo dalla basestaion $A$ a $B$. Questo effetto è deleterio per le risorse, c'è solo controllo non mandiamo mai dati continuiamo a deallocare e allocare le risorse.

Vado a sempre al max della potenza offerta dalla base station.

==== Potenza relativa + Tashold

Per evitare questo effetto andiamo a posizionare una *Tashold*. Andiamo a imporre un valore assoluto di riferimento. L'ultima soglia, al di sotto del punto di intersezione dice che se percepiamo anche un altra base station che ha un seganle più alto non vale la pena cambiare. Sotto l'ultima soglia cambio stazione

In questo caso triggheriamo l'handover in $L_4$ da base station $A$ a base Station $B$. Le condizioni diventano due per il passaggio:
- $"Rx"_A < T$. Deve essere minore della soglia, altrimenti non ha senso cambiare
- $"Rx"_B > "Rx"_A$

La criticità e settare la trashold, è difficile trovarne una adeguata.

==== Potenza relativa Isteresi

*Isteresi* = valore di una funzione non dipende solamente dall'input ma anche dallo stato precedente del sistema.
#esempio()[
  Impostiamo la temperatura a 20 gradi (si spegne il sitema). Il parametro di isteresi è quanto deve essere più preddo per triggerare l'accensione del riscaldamento. Il riscaldamento non si accende subito quando scende a $19.99$ ma a $19.7$ ad esempio.
]

//aggiungere grafico

Sull'asse del $x$ c'è la potenza relativa $+H$ $B$ ha $H$ maggiore risetto ad $A$. Al contrario in $-H$ $A$ è migliore

Supponiamo che la potenza di B stia aumentando. Nel momento in cui raggiunge il punto $+H$ essa raggiunge il punt di esteresi e passa a $B$.

#nota()[
  é una potenza relativa, $B - A >= H$ per triggerare il cambio.
]
Se siamo in $B$ e torniamo indietro fino alla soglia di isteresi di $A$  e cambiamo, rimanendo in $A$.

La posizione sulla $Y$ ci dice la base station associata. La funzione ha due valori diversi in base alla funzione di partenza

Nel grafico precedente l'isteresi è come se seguissimo un'altra curva ($H$ nell'immagine). Tiene conto della potenza relativa di isteresi. Non faccio più il passagio in $L_1$ ma in un altro punto $L_2$.

#nota()[
  Problema con il segnle assoluto, Si impone una soglia in quanto l'isteresi lavora solatmente a livello relativo.
]
La condizioni diventano:
- $"Rx"_A < T$. Segnale minore in modo assoluto
- $"Rx"B^h > "Rx"_A$. Potenza relativa di $B$ maggiore di quella di $A$. Stiamo dicendo che la potenza dell'altra stazione è sufficentemente maggiore rispetto al punto di isteresi.

#informalmente()[
  L'isteresi è una sorta di buffer per le variazioni repentive di segnale
]

== Hard Handoff vs Soft Handoff

- Hard da 2g in avanti. Il dispositivo è assocato ad una sola BS alla volta

- Soft = il dispositiv mantiene la conettività con entrambe le BS, il rilascio di una BS quando il segnale è chiaramente dominante. Richiede ovviamente più risorse.

== FDD e TDD

In 2g la connessione avvenivs in FDD. Frequenze diverse per uplink e downlink. Vantaggi:
- Posso trasmettere e ricevere contemporaneamente (non c'è delay)
- Maggiori risorse, metà del datarate, devo dividere lo spettro

TDD. Utilizzo una sola frequenza sia per uplink e downlink. Utilizzo di una sola frequenza. Maggiore ritardo perchè devo aspettare

In 4G sono presenti entrambe le soluzioni

== GSM Mobile station

IL GSM è diviso in due parti:
- Mobile equipment
- Sim

=== ME
identificativo del dispositivo, fatto nel seguente modo:
- TAC: costruttore
- FAC: dove viene assemblato
- SN: sequence number
- Check Digit: bit di controllo

identifica in modo unico un dispositivo mobile (viene utilizzato in caso di furto).

=== SIM Card

Identifica un abbonato (un utente). La SIM contiene anche la chiave segreta per autenticazione e generazione delle chiavi di cifratura. L'identificativo della sim è detto IMSI, ed è composto da:
- MCC: stato dell'operatore
- MNC: mobile network code, unico a livello nazionale
- MISN: Mobile Subscriber per identification number

#nota()[
  Il numero di SIM non ha nulla a che vedere con il numero di telfono
]

Il numero di telefono è chiamaso MSISDN. ISDN sta per la rete digitale (precursore della DSL). Il numero di telefono è fatto da:
- CC: codice del paese
- NDC: Destination Code
- Numero

Tuttavia *non* c'è più un associazione $1:1$. Ad oggi una SIM può portare più numeri di telefono. è stata introdotta a metà degli anni 2000.

= GSM //non in esame

L'idea iniziale è di trasmettere solo voce, poi SMS (all'inizio erano messaggi di controllo).

Ad oggi GSM è un circuit-switch virtualizzato su IP. Vogliamo avere un numero elevato di utenti cambiando il meno possibile.

GSM è stato standardizzato dalla ETSI.

GSM funzionava con frequency division duplex. Due canali. Ogni banda sono $25 "Mhz"$. Ogni banda a sua volta viene divisa in $125$ canali da $200 "kHz"$.

Dicendo il canale $2$ possiamo sapere il dispositivo associato. Ad ogni dispositivo veniva associato un canale e un time-slot. Si parlava sempre a intervalli regolai (costant bit rate) e $2G$.

Abbiamo un grande dispendio per installare le base station e controllare il traffico voce.

= GPRS & EDGE

Si tratta dellìintegrazione di GSM con la rete internet. Non vogliamo buttare via la parte radio (base station) ma solamente la parte software.

