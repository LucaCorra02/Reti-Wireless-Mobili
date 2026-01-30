#import "../template.typ": *

= Wireless Loacal Area Netowrk (WLAN)

ISM Industial Scientific and Medical. Questo spettro è utilizzato anche da dispositivi elettronici, medici ecc. 

#esempio()[
  Ad esempio il microonde e il wifi lavorano sulla stessa frequenza. Il microonde può interferire con il segnale wifi o bluetooth.
]

Chi vuole costruire un dispositivo che comunica in questo range di frequenze non deve acquistare una licenza per trasmettere (non è ad uso esclusivo dell'operatore). In ambito cellulare spesso sono licend-band (uso esclusivo di un certo operatore).

== Pulse Code modulation (PCM)

L'idea è che abbiamo un segnale che sappiamo come campionare. L'idea è campionare un segnale per capire tutte le frequenze che ci sono in quel segnale. 

Per la voce, ad esempio, ci interessa catturare solo un certo range di frequenze da $300-3400 "Hz"$. Trasmessa al doppio

Il campionamento avviene nei punt in blue, ci permette di capire la potenza del segnale. Il segnale viene quantizzato al valore più vicino, quanto più è fitta questa griglia tanto più siamo in grado di determinare vari livelli del segnale. 

#esempio()[
  Usiamo 4 bit per quantizzare la nostra informazione. Con 4 bit abbiamo 16 livelli. 

  Tipicamente la voce è coodificata con $8$ bit, ci permette di avere $256$ livelli. 
]

== Standard bluetooth (802.15.1)

Lo standard comprende un insieme di tecnologie per la comunicazione a corto raggio. Tra cui il bluetooth.

LIFI, trasmissione del segnale attraverso la luce. Altamente direzionabile e mascherabile. 

La struttura di bluetooth è fortemente gerarchica e fissa: 
- Rete *pico-net*
- Master node, coordina l'interà attività della pico-net.
- Abbiamo una serie di slave, l'architetture è di tipo master e slave. GLi slave comunicano solo con quello che è stato deciso dal master, sia in termini di tempo che di frequenze. 

Caratteristiche del bluetooth: 
- Corto raggio (10-50 metri)
- Lavora sulla banda ISM $2.4 "GHz"$ (la stessa del wifi)
- Il data rate può variare, molto meno del wifi. 

Solitamente vtecnologia utilizzato per sostituire i cavi, oppure come punto di accesso per dati e voce. 

=== Stack di bluetooth

#nota()[
  Completamente diverso dallo stack TCP/IP o ISO/OSI.
]
Abbiamo i seguenti pezzi: 
- Livello fisico 
- Livello Data-Link, con il relativo controllo
- Abbiamo un livello che ci permette di convogliare tutto quello che è il mondo esterno 

Tutti i livelli in blu, sono sempre presenti in un qualsiasi dispositivo bluetooth. 

La linea rossa divide la parte hardware da quella sofware. 

=== bluetooth Radio

Livello fisico

Si occupa di trasmettere e ricevere radio frequenze. 
Gestisce: 
- Gestione del frequency hopping
- Lo schema di modulazione di forwarder e correction
- Gestisce la potenza di trasmissione

=== Baseband

Si occupa di : 
- Stabile la connessione con la pico-net
- Gestisce l'indirizzamento. Abbiamo sia l'indirizzo hardware del dispositivo che logico a livello di pico-net.
- Sincronizzazione e tempistiche di comunicazione, Time division duplex, frequency division duplex (2 trasmissioni divere).
- Gestisce la potenza di trasmissione

Duplex, come gestisco la trasmissione e la ricezione (il cavo ethernet è full-duplex). In ambito Wireless non si può fare o trasmettiano o riceviamo

=== LMP
Si tratta di un livello di controllo. Non trasmette dati ma li gestisce. 

- Configura i collegamenti
- Gestisce la sicurezza 

=== L2CAP

Siamo nella parte sofware. Si tratta di fatto di un protocollo che permette la convergenza di quello che c'è sopra adattandolo ai servizi offerti dai livelli inferiori. 

=== SDP 

serve per gestire cosa il dispositivo è in grado di fare (auricolari bluetooth fanno qualcosa di diverso da orologio bluetooth). Implementa un protocollo che permette ad un dispositivo che si conette alla pico-net di trovare il dispositivo con un certo profilo (cosa è in grado di fare) nella rete. 

=== RFCOMM 

emulatore di porta seriale. Non è fondamentale che ci sia

=== ALtro

Lo standard bluetooth intende riutilizzare il maggior numero di protocolli già esistenti. bluetooth si occupa tramite i suoi livelli proprietari di convertire il mondo esterno in quello bluetooth
//TODO aggiungere cosa sono i profili

== pico-net & scatternet

Active slave (AS): Membro attivo della rete. Al massino il suo indirizzo è $3$ bit. 

Al più in una piconet ci possono essere 8 dispositivi che comunicano attiviamento (uno di quelli è il master)

Parked Salve (PS): Comunque parte della pico-net ma non ha accesso diretto alla comunicazione. Può ascoltare messaggi ma non puà comunicare attivamente. Il master decide se risvegliarlo, assegnandoli un active member address. Per farlo serve una parked member address, al massimo $255$ dispositivi (lo zero è riservato al master)

Stanby Salve (SS): Ci sono anche dei dispositivi che possono ascoltare messaggi ma sono esclusi dalla rete (non sono indirizzati). 

#nota()[
  Lo standard bluetooth permette ad uno slave di far parte di più piconet. 
]
Uno slave può essere una qualsiasi combinazione dei possibili stati nelle varie reti. In questo modo viene a crearsi una *scatternet*. Insieme di più pico-net (pico-net che condividono slave), tuttavia ogni pico-net è separata, ognuna è gestita dal proprio master. 

=== COmunicazione 
FH: 

TDD: In uno solot temporare la comunicazione avviene master slave mentre quello successivo slave master e cosi via. Nell'immagine gli indici delle frequenze pari (slot pari delle frequenze) abbiamo comunicazione master slave. Nell'istante di tempo successivo su una frequenza diversa abbiamo la comunciazione slave - master. 

#nota()[
  La direzione è decisa a priori. Nelle frequenze pari (in termini di tempo e non nei canali) il master parla con gli slave e in quelle dispari viceversa
]

Tutti gli slave sono Sincronizzati temporalmente e condividono al stessa frequenza di frequency hopping (altrimenti non sarebbe possibile)

TDMA: Aggiugnere

//aggiungere imamgine
#esempio()[
  in TDMA il master decise di paralre con lo slave 2. In particolare lo slave 2 ascolterare sulla sequenza 2 del frequency holding. per tutti i 3 slot successivi il master non cambia la frequenza. Una volta scelto una frequenza non la cambia (i clock sono distributii).\
  Lo slave risponde sulal frequenza $5$. Il metronomo assoluto della pico-net continua a battere ogni $225 "ms"$. Chi dovrà parlare in questo istante dovrà usare la frequenza $5$ in base alla frequency hopping globale. 

  #nota()[
    GLi slot possono essere solo dispari. Con la rigidità del TDM, tutti i dispositivi della pico-net sanno che sulle freuqnze pari devono ascoltare, sulle frequenze pari sanno che possono comunicare.

    Si tratta di una convenzione. La frequency hopping viene data dal master, ogni tot secondi c'è alternanza e se si trasmette su più slot non si cambia frequenza. La frequenza successiva non dipenderà dalla precedente ma da quella globale. 
    
    In questo modo non c'è comunicazione. 
  ] 
  #attenzione()[
    é come se la trasmissione fosse sincrona implicitamente, la sincronia viene gestita dal master. 
  ]
]

=== Scatternet FH + CDMA 

In alcuni momenti (non si sa quali ) dei 79 canali che possiamo usare ci può essere una sovrapposzione, lo stesso canale viene utilizzato. Lo slave riceve un interferenza in quanto si sta trasmettendo sulla stessa frequenza. 

Soluzione: 
- Non risolvere il problema, usare molti meno canali
- CDMA, comunicare sulla stessa frequenza senza interferenza. 

Il master comunica un codice ortogonale per la propia piconet. Nella comunicazione oltre al frequency hopping usiamo anche CDMA. 

Quando lo slave di mezzo vuole comunicare o ascoltare deve utilizzare il codice della piconet di riferimento. 

#nota()[
  Non è una soluzione totale, ma è parziale, mitiga di molto il problema. 
]

== Baseband SCO & ACL

// riguardare 

=== Formato frame
- Access code: 
  - Ha un preambolo per sincronizzare la parte radio.
  Acces Code può essere (o uno o l'altro): 
  - CAC: identifica la piconet 
  - DAC: derivato dall'hardware dello slave, serve per dire che un certo messaggio è destinato a quel dispositivo
  - IAC: usato per trovare l'indirizzo di un dispositivo
- Head: 
  - AMA: indirizzo del membro attivo della piconet (master o slave)
  - Type: identifica se è un canale SCO o ACL
  - Flow: per le ACL
  - ARQN: parte per la ritrasmissione
  - SEQN: sequence number
  - HEC: Conrollo degli errori
- Payload (30 byte per SCO o variabile per ACL):

== Controllo degli errori
//aggungere imamgine
Abbiamo uan comunicazione tra un singolo master e un singolo slave. 
Il bit scritto nel header è il SEQN (sequence number), il bit è relativo all'ACK. 

- La prima trasmissione master slave ha SEQN 0. Lo slave risponde un ACK con SEQN 0. 
- il master trasmetter il SEQN del pacchetto succevvo, ovvero 1. tuttavia la trasmissione fallisce
- lo slave non riceve, siccome si aspettava un pacchetto con SEQN $1$ risponde con un NAK pari a $1$. Lo slave si aspettava di ricevere qualcosa (turno del master), comuncia di nona aver ricevuto SEQN. 

- più avanti nella figura fallisce l'ACK. Il master nella frequenza 5 si apettava l'ACK dello slave ma non è arrivato, il master assume che sia stao perso. Il master rimandera messagio con SEQN $1$

- lo slave lo riveve, siccome lo ha già nel buffer viene scartato. QUesta volta l'ACK arriva. 

- Alla fine viene trasferito il messaggio successivo (SEQN modulo 2 = 0).

#nota()[
  Se non ci fosse questa alternanza rigida (sincronismo implicito) non basterebbe un controllo dell'errore così semlice. 

  Basta un solo bit per controllare il flusso. Se trasmetto l'1 e rivevo conferma di aver ricevuto 1 il successivo è lo 0. 
]

== Link manager protocol (LMP)

Come arriviamo dallo stanby mode (non sappiamo frequency hopping, come contattare i master ecc) alla modalità attiva essendo in una modalità distributia. 

L'idea è scegliere un sotto-insieme (non tutti per evitare interferenze) di canali in cui il Master chiede se ci sono dei dispositivi (inquiring message) che si vogliono conettere, lo slave ascolta (ogni tanto per risparmiare batteria). Allo stesso modo il master fa polling tra i vari canali (wake-up channel) di connessione durante in un certo intervallo. 

#attenzione()[
  Tutto questo meccanismo è non coordinato
]
Il master ogni tanto trasmesse un inquiry packet (intervallo di tempo fissato). Lo slave ogni tanto scansiona il canale di connessione. Se lo slave intercetta il segnsle non risponde subito ma aspetta un  *random backoff time*. In modo tale da evitare collisioni con altri slave che si vogliono collegare. 

il random backoff è calcolato apposta per cercare di beccare la sincronizzazione del master. 

Una volta che il master ha scoperto la presenza di uno slave viene dato l'accesso allo slave. Vengono comunicati: 
- l'indirizzo 
- il frequency hopping

Inoltre viene uitlizzato semrpe un insieme di canali standard specifici (più piccoli), in quanto lo slave non è ancora a conoscenza del frequency hopping. 