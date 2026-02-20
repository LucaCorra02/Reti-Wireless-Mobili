#import "../template.typ": *

= Lezione 10

All'intenrno di locali. Abbiamo un passaggio molto omogeneo tra l'esterno e l'internod dell'edificio, senza cambiare la tecnologia di accesso.

Se il tempo riservato al traffico di controllo avremo delle code di dispositivi che vogliono fare traffico autonomo _handover_ e _handoff_

== Cell Sectoring

Non abbiamo una antenna omidirezionale (copre tutta la celal uniforme), ma abbiamo più antenne direzioaneli, che coprano varie parti della cella. Abbiamo uan base station e la cella suddivisa in parti.

Una base station solitamente contiene 3 antenne e ognuna di queste ha 3 antenne. Ogni antenna gestisce una sotto-cella. Ogni sotto-cella usa frequenze diverse o i meccanismi visti in precedenza.

Il vantaggio è che partizionando la cella in più parti abbiamo un minor path loss a partià di distanza (antenna gain). Le antenne sono direzionali, coprono in modo settoriale la cella.

Tuttavia, viene complicata la parte di controllo.

== Archetettura ed operazioni

Struttura generale (in ogni generazione rimane la stessa struttura):

- Servizi: Come internet, ecc

- Core Network (o  anche MTSO). Il comptito è portare la comunicazione in _rete_. Si occupa di mantenere le informazioni di controllo e di fare da tramite per i servizi (esterno)
  #nota()[
    La rete mobile non offre servizi, essi sono esterni dalla rete
  ]

- RAN (Radio access netowrk). Si tratta del modulo per l'accesso e trasporta le informazioni al controller. Contiene
  - Base Station controller: Serve a coordinare le base station
  - Dispostivi
  - Base station

Esistono due tipi di canali che trasposrtano due tipologie di traffichi:
- *Canali di controllo*: Control Plane. Dicono che cosa deve essere fatto per gestire la rete.

- *Canali di dati*: Trasportano la voce e dati (traffico dei servizi offerti)-> Data Plane (indica come deve essere fatto).

Man mano che si è andati avanti nelel tecnologie, i moduli sono stati separati, ci sono moduli che fanno controllo e moduli che si occupano del canale dati

=== Inizializzazione e monitoraggio del segnale

Inizialmente deve essere scelta la migliore cella e chiesto l'accesso a quella cella.

Periodicamente vengono inviati dei *pilot*. Sono dei segnali codificato in modo standard che contengono dati standard. Servono per sapere quanto il segnale è diverso da quello che so che viene trasmesso. Tanto più il segnale trasmesso è diverso da quello effettivo tanto più posso asserire sulla non qualità del canale. Grazie ai pilot possono essere anche applicati delle trasformazioni al segnale ricevuto, in modo da ricostruire il segnale.\
La frequenza di invio dipende dal tempo di frequenza del mezzo radio (per che intervallo di tempo le caratteristiche dle segnle rimangono costanti).

Il pilot ci permette di essere molto aggiornato sullo stato del canele, permettendolo di aggiornalo.

#nota()[
  Operazioni svolte solamente dalla rete access Network
]

=== Passaggio alla rete core

Ci deve essere un canale radio dedicato all'utenete, viene chiesto alla base station a cui il dispositivo è attaccatto. Tutta la comunicazione è gestita dalla base station (non c'è un accesso random). Questo accade in quanto si vuole avere un controllo rigido (come bluethoot, la base station è il master).

#esempio()[
  Se sono in un lugo in cui non ci sono base station del mio operatore, viene negato l'accesso, non potento trasmettere dati. Solo chiamate di emergenza
]

=== Paging

Supponiamo che una chiamata arrivi dall'esterno. La conoscenza all'interno di MSTO non può tenere traccia di ogni base station e ogni dispositivo (troppi dispositivo).

Per questo motivo le base station vengono divisi in aeree (gruppo di base station identificate da un codice). Viene tenuto traccia di questa informazion MTSO sa che un dispositivo si trova nell'area 100. Per sapere la base station individuale viene effettuato il paging. Solo una base station risponderà che gestisce lei un certo dipsositivo, verranno po trasferiti i dati.

Vantaggi:
- I dispositivi si possono mettere in idle. Possono rilasciare i canali ad altri utenti. Vengono tenuti in memoria i servizi che sta utilizzando il dispositivo ed essere rilasciati ad altri. Quando il dispositivo deve ricevere qualcosa li vengono riassegnati.

Operazione onerosa (si cerca di fare il meno possibile)

C'è un canale specifico dedicato al paging.

=== Chiamata accettata

I canali devono essere accettati da entrambe le parti e dalle base station

=== handoff
Possibilibiòtà di passare da una cella all'altra senza percepire l'interruzione del servizio.

La parte di handover a tre fasi:
- Decisione di una nuova associazione (spotamento di cella)

- Gestione nuova associazione. L'idea e non rilasciare le risorse acquisite della vecchia base station non prima che le nuove risorse siano pronte nella nuova base station. Se non avessimo le risorse pronte acadrebbe uan perdità di connessione.

- Riconfigurazione percorsi di comunicazione. Routing soprattuto verso la rete core.

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

