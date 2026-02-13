#import "../template.typ": *

= Lezione 8

== 802.11e EDCA

L'idea è di proporre una tabella che definsice $4+1$ parametri, che permettono di definire diverse politiche di accesso:
- Contation windows min
- Contation windows max
- AiFSN
- Max TXOP

Traffico background:
- CW = 15
- CWMax = al più 1023 (con random backoff).
- AIFSN = numero di slot time che aspetto SIFS + N. Solo se non c'è nessuno che deve accere al canale posso farlo. Ovvero ho la priorità minima di accesso al canele.
- Max TXOP = 0, quanto posso aspettare prima di considerare il trasferimento fallito, in questo caso non è definito.

Il voice ha un random background molto breve, questo permette uan trasmissione più veloce. Max TXop = se ho preso l'hop del canale posso tenerlo al massimo per $1.5$ ms. Il traffico voce ha una altissima priorità (tenere il lock del canale per un massimo di tempo indicato)

Gestendo il backoff (il range iniziale, numero di slot temporali minimi e massimi) possiamo andare a modificare i tempi di attesa per l'accesso al canale.

Questi servizi vengono richiesti a livello MAC, in base a come è configurata l'applicazione.

#informalmente()[
  Non c'è starvation (sistema a code di priorità), prima o poi anche il backgroudn accederà
]

= (802.11p) & Wave-V2V

Si tratta del WIFI veicolare. Sono delle reti specifiche per la mobilità. In questa configurazione non ha senso avere un access point, entriamo da una cella e entriamo in un altra, inutile avere un beacon. Inoltre i vicini (in termini di coopertura) cambiano dinamicamente

L'obbiettivo è scambiarsi dei messaggi di presenza ecc, senza avere un flusso di date continuo tra due veicoli. Il messaggio è di notifca dei comportamenti di un certo veicolo agli altri.

Fornisce un sipporto per servizi critici (alta qualità di servizio, si tratta di servizi real time).

I veocili devono sempre ascolatare, radio in ricezione sempre accesa in quanto gli eventi sono asincroni, possono avenire in modo non contollato. Non c'è ACK ma vengono inviati dei piccoli beacon di notifica in maniera costante.

//riguardare PHY

abbiamo uno schema di contesa interno a livello mAC. Viene scelto se il canale di controllo e di servizo, in base alla classe di servizio scelto ogni richiesta viene messa in una coda di priorità diversa:
- Si fa una contesa interna alla classe
- e una contesa esterna per unsare il canale fisico vero e proprio

#nota()[
  il canale servizio a priorità maggiore rispetto a quello di controllo
]

== Platooning

Riduzione consumi di carburante.
Corrdinamenti:
- Legge di controllo
- Tecnologia efficiente ed efficace



Ci servono i seguenti dati:
- Dati del nostro veicolo
- Dati del veicolo che abbiamo davanti
- Dati del leader

In output abbiamo l'accelerazione desisderta.

//aggiungere immagine

=== CACC

Maggiore è la velocità, maggiore è la distanza. Vogliamo avere uan distanza costante. Anche qua ci servono i dati:
- Dati del mio veicolo
- Dati del veicolo che mi precede

Abbiamo meno benefini a livello dinamico, ci allontaniamo nel caso stiamo andado più veloci (più safe ma consumo meno carburante)

== (802.11p)

Ogni veicolo calcola la legge in loco.

Non gestisce il problema del terminale nascosto, si perdono delle occasioni per ricevere dati nuovi nel nostro sistema

//Grafico sulla distanza
Suppendo una policy di garantire la distanza veicolare, l'idea è di avere un distance error pari a zero. Man mano che passa il tempo la distanza converege.

Tuttavia il veicolo rosa essendo troppo distante dal leader esso non calcola i dati di controllo e si allontana sempre di più dal leader.

L'idea è la seguene: Ciasun veicolo che riceve i dati del leader li trasmette a sua volta, chi riceve i miei messaggi trasmette anche i dati del leader. in modo tale che raggiungano anche l'ultimo veicolo

#esempio()[
  Siccome il clock non è sincronizzato
  //aggiungere schema
  - Il f6 riceve il dato del leader, il f11 no troppo lontano.
  - il f6 trasmette i suoi dati e anche i dati del leader
  - il f11 calcola i dati del leader a partire da quelli di f6(stato più aggiornato)

  più i tempi si dilatono in questa comunicazione maggiore è il lag che si verifica. Le azioni avvengono in ritardo, è come se stessimo lavorando su una fotografia vecchia del sistema.

  Il sistema solitamente cambia intorno al secondo, Tuttavia se si accumulano ritardi compromette la situazione del sistmea
]

#esempio()[
  In questo caso:
  - F11 non riceve niente
  - F6 manda t0 a f11 al tempo T2
  - Tuttavia a tempo T3 il leader fornisce un nuvo aggiornamento a tutti tranne che a f11. Ora f11 possiede una versione non aggiornata dei dati, i dati più freschi sono a tempo t3 ma io ho una versione aggiornata a t0 dei dati del leader. Ho i dati aggiornati di f6 ma una versione precedente di quelli del leader
]

Tramite questo sistema abbiamo la convergenza. Il sistema regge ma man mano si accumulano ritardi.

= Reti ad hoc wireless

Ogni nodo può svolgere funzioni di routing, può instradare messaggi di controllo.

L'obbiettivo è creare un percorso sorgenete destinazione, assummento che la rete è dinamica, i link possono cambiare. Inoltre si vuole popolare le tabelle di ruorutng

L'approccio è di tipo Stateless, quello che sappiamo adesso è effimero, lo stato viene mantenuto per un certo intervallo di tempo.

obbiettivi:
- Gestire la dinamicità della rete.
- Autoinizializzate (no rotte preconfigurate)
- Loop free
- Deve poter creare un percorso tra una sorgente e destinazione quando viene richiesto e in tempi rapidi
- Ripsosta rapida alla rottura dei link e cambio di tipologia (nodic he escono dal rado di copertura)

== ADV
Il protocollo effetua dei percorsi simmetrici. Ogni nodo maneiten le tabelle di routing (per ogni destinazione qual'è il nexthope).

Useremo gli indirizzi Ip per decidere sorgente e destinazione.

Il messaggi di controllo sono:
- `Route request`: Messaggi che chiedono la creazione di un percorso. Mando in broadcast (non so dov'è la destinazione) a livello 3 (ip `255.255.255.255`) in modo controllato.\
  Ogni nodo tiene traccia da dove arriva la route request, in modo da limitare il traffico

- `Route replay`: Mandata in unicast al nodo originator. La destinazione manda una rout replay sul percorso della route request. La ripsosta è unicast in quanto la destinazione conosce l'ip dell'originator.\
  Un nodo sul percorso della rout request può risposndere con una route replay, anche se non è la destinazione se la sua conoscienza è suffcientemente aggiornata.

- `RERR`:

#nota()[
  I messaggi di controllo sono specifici dei distance vector, hanno un loro formato. Seguono come applicazione AODV e a livello di trasporto usano la prota 654 di UDP.

  Mentre i dati seguono il protocollo di applicazione, ecc.

  in entrambi i casi alla base c'è il pachetto IP.
]

=== TAbella di routing

Contiene:
- Ip Destinazione
- Sequence number della destinazione (indice di frescrezza dell'informazione)
- Flag validità del sequence number della destinazione.
- Stato del percorso valico, invalido, sospeso.
- Interfaccia di rete
- Hop Count
- Lifetime (gestita dal protocollo), tempo di scadenza della entry

=== Sequence number

Codifica la frescrezza della informazione di una entry. è incrementato solo dal nodo stesso:
- Quando un nodo inizia una ricefca di percorso, viene incrementato di 1
- Quando il nodo risponde a una route request ed è la destinazione di quella richiesta

Il SEQN può essere modificato solo dal nodo a cui il SEQN si riferisce.

Gli altri nodi possono aggiornare il seq di una entry nelal tabella se:
- è il nodo stesso
- il nodo riceve infromazioni più aggiornate per una destinazione
- scade

==== Formato

- Type Per vedere che tipo di cirichesta è
- Flag:
  - G = Gratutios //rigurdare
  - D = Destinatoon only. Solo il nodo destinatione della RREQ può rispondere, gli altri non possono ripsondere
  - U = Unknown sequenc number flag. origine non conosce SN della destinazione.

- Hop Count: nuemro di hop della richiesta, serve per chi riceve capire quanto è lontana l'origine

- RREQ ID = identificatore della richiesta (incrementato dall 'originator) da chi fa la richiesta

- Destination IP

- Destination SEQ: ultimo SEQ della destinazione in mio possesso. Ha significato SSe il flag U = 0.

==== Request Creation

Creo una richiesta nel momento in cui non conosco la destinazione o la entry di quella destinazione è scaduta.

Step della creazione:
- Incrementa `RREQID++`,`SN++`
- Aggiunge i valori se DST è sconoscuta `U=1`
- Tengo una coppai di `Origin Ip, PREQ ID`. Si tratta di un identificatore univoco di una route request (non a livello di paccehtto) ma identifico come nodo intermedio se ho già visto o meno quella route requesta, se non l'ho vista faccio forward
- Tempi per cui viene tenuta in memoria la route request (secondo lo standard NFC). Questi tempi possono esser impostanti nel protocollo. Al più può metterci 2 volte il tempo di andata, finito questo tempo non ho trovato niente la destinazione non esiste.

Come vengono impostati i parametri di tempo. Fino a quanti HOP la richiesta viene propagata

L'obbiettivo è ridurre l'overhead. Non sempre è necessario il fluding delle RREQ, vogliamo traovare un modo efficiente

- ``
- ``
- `NET_DIAMETER`: parametro fisso. Massimo valore TTL

===== Caso expading ring search

*Non sappiamo dov'è la destinazione*. Impostiamo un time all'invio e assumiamo che la destinazione sia vician in termini di hop, il `TTL_START` ha un numero di hop basso.

Ogni volta che fallsce una ricerca locale estendiamo la ricerca, Il numero di hop per cui viene aumentata è definiot da `TTL_INC`. Il tempo massimo è definito da `TTL_NET_DIAMETER`

Si tratta della tecnica più onerosa a livello di traffico, nel caso peggiore il pacchetto viaggia per tutta la rete, facendo flooding.

A livello iP il pacchetto avrà una destinazione boradcast. La replay avrà una destinazione unicast.

Nel caso avessimo uan entry invalida, sappiamo anche l'hop count, ovvero il percorso per $A$ era 10 hop. L'idea è di riprovare il percorso di prima per quanto riguarda la distanza impostando il `TTL=10`. Se si è avvicinato mi ripsonde prima, altrimenti si va avanti con `TTL_increment` fino al diametro

==== Scarto

Se ho gia visto la coppaia `REQ_ID, ORiginator_IP` non inoltro comunque la richiesta. Tuttavia vado a fare una serie di azioni:
- Confronto ORIGIN SQ contenuto nella richiesta con quello che ho in tabella. Se è >, allora l'aggiorno. L'informazione contenuta nella route request è aggiornata. Il nodo originator si è aggiornato e anche io voglio rimanere coerente

Costruisco il percorso reverse, in quanto so che l'originator è verso il nodo da cui mi arriva la Route request

==== Inoltro

Nel caso che non l'ho vista la devo intolreare:
- Incremento `hop_count`
- Metto l'informazione più fresca possibile. La setination SEQ può essere più recente o più vecchia rispetto a quello che ho su quella recente
#nota()[
  A differenza del numero di sequenza della richiesta, quello dell'orginator è più recente, l'ha fatta lui
]
- Mando RREQ in broad cast

#esempio()[
  Esempio di RREQ, No RREP Intermedio
  Contenuto della route request fatta da A:
  - DEST: H
  - DST SN: 140
  - ORIG: A
  - ORIG SN: 200
  - #Hop A

  Situazione, il nodo F conosce `<H,G,2,139>`

  il nodo originator conosce già H e la situazione è più aggiornata rispetto ai nodi intermedi.

  Con l'avanzare della route request vado a costuire anche il percorso al contrario. 

  Il nodo F non conosce A -> nuova entry

  Il nodo D aveva la entry `<A,E,4,199>`. Siccome la RREQ contiene `200` come SN vado a cambiare le informazioni (più recente). Modifico la entry come `<A,B,2,200>` raggiungo A tramite B in due hop e i SEQ è 200.
  (a parità di SN viene l'hop minore).

  #nota[
    A parità di hop vince il sequence number maggiore. 
  ]





]
