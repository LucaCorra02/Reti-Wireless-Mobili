#import "../template.typ": *

= Lezione 2

//Può capitare all'esame
#esempio()[
  Dati: 
  - uno spettro che va da $3"Mhz"$ e $4"Mhz"$
  - $"SNR_(dB)" = 12 "db"$

  Vogliamo: 
  - trovare la capacità del canale $C$
  - calcolare il numero di livelli di segnale che devo avere per avere quella capacità del canale.

  Per shannon la capacità massima del canale è data da : 
  $
    C = B * log_2(1+"SNR")\
    C = 2B log_2(M)
  $
  Vogliamo trovare $C "e" M$.\
  Per prima cosa dobbiamo passare da dB a SNR "puro":
  $
    "SNR"_("dB") = 12_("dB") = 10 log_(10)("SNR") = 10^(1,2) -> "SNR" = 15,8 = 16
  $
  Possiamo ora calcolare la capacità del canale: 
  $
    C = 1"MHz" = log_2(1+16) = 4"Mbps"
  $
  Vogliamo calcolare ora il numero di segnali che il livello fisico deve implementare per raggiungere tale capacità (Usare nighmist(?)):
  $
    4"Mbps" = 2 * 1"Mhz" * log_2(M)\
    "Serve" M = 4
  $
  il nostro livello fisico deve almeno usare $2$ bit.
]

== Trasmissione a cavo

== Trasmissione in banda base
La Trasmissione avviene in banda base. La banda base ha uno spettro che va da 0 all'ampiezza di banda massima $B$ del canale. 

#esempio()[
  Lo spettro sonoro è in banda base. Da 0 a $22"Mhz"$.
]

Questo va bene per la comunicazione via cavo. 
Trasmettendo in ambito wireless ci sono dei problemi: 
- Se tutte le trasmissioni radio (Militare, Tv) usassero lo stesso spettro. Problema puramente di sicurezza e di interferenza
- Più le sequenze sono basse più l'antenna per ricevere il segnale deve essere grande. Deve essere almeno grande metà dell'onda. 
#esempio()[
  2100Mhz serve un antenna di 7cm (usata per cellulari)
]

- Ogni range ha diverse proprietà. 

#attenzione()[
  Il mezzo di trasmissione in wireless è intrisicamente broadcast, tutti possono vedere le onde eletromagnitiche
]
// Aggiungere immagine

== Trasmissione in base traslata

Per evitare di avere trasmissione sovrapposte è usare la trasmissione in banda traslata (o passa banda). 


Viene effettuata una fase intermedia. Viene scelta una frequenza portante e utilizziamo il seguente spettro: 
$
  [f_c - B/2, f_c+B/2]
$
Questa operazione sulla frequenza portante prende il nome di *modulazione*, possiamo cambiarne: 
- frequenza
- fase 
- banda
in ambito wireless vengono utilizzate tutte e 3. 

#informalmente()[
  Usiamo uno spettro centrato rispetto a una frequenza di carry
]

#nota()[
  La modulazione non modifica L'ampiezza di manda rimane uguale e anche il teta medio. 
]

== Encoding symbol

Simbolo = è una forma d'onda, uno stato (livello di voltaggio) o una condizione significativa del canale che persiste per un certo intervallo di tempo. 

Simbole rate = numero di simboli emessi dal livello fisico in un secondo, si misura in $"baud"$. Ad esempio quante volte è in gradi di cambiare il voltaggio il livello fisico in un secondo. 

#attenzione()[
  Non è semplicemente rumore
]

Un simbolo può codificare più bit. In linea generale il symbol rate è diverso dal bit rate. Il bit rate è $>=$ del simbolo rate. Queste due misure sono uguali quando il livello fisico è in grado di produrre solo 2 segnali, alto e basso. 

Quando il cellulare non prendo ad esempio dovremo avere la possibilità di codificare meno bit sui simboli, in mdoo da trasferire meno dati. 

Una data bandwitch può supportare diversi data rate a seconda dell'abilità del ricevente di distinguere $0$ e $1$ in presenza di rumore

//aggiungere tabella e riguardare
Un simbolo può codificare più bit alla stessa frequenza. 

Usiamo l'ampiezza di un onda come parametro per identificare i diversi simboli andandola a modulare. Amplitude shift key (coppia chiave, parametri). La chiave è la sequenza di bit che vogliamo rappresentare e i parametri è l'onda elettromagnetica che dobbiamo emettere per un certo intervallo di tempo. 

=== Trasmissione radio

Propagazione delle onde radio:
- Se siamo sotto i $2"MHZ"$ non è necessario che trasmettitore e ricevitore si vedano (terra sferica). 

- Se siamo dai $2-30 "MHZ"$ il segnale rimbalza sulla iomosfera (non si possono vedere).

- Sopra i $30"Mhz"$ (comunicazione delle telecomunicazioni) la trasmissione avvien line of site (le due parti devono vedersi in linea retta).

L'antenna a destra è direzionale, un solo lobo in una direzione. L'idea è di concentrare l'energia in una certa direzione (line of site) er la trasmissione e per la ricezione

Dobbiamo tenere in considerazione i seguenti problemi con il segnale radio: 
- *Path lost*: prblema che c'è su cavo ma limitato (non possiamo deviare troppo dal cavo).
Modello free-space lost. Anche se fossimo in spazio aperto (no interferenze) c'è una perdità del segnale anche solo per distanza. 
- *Rumore*: distorce il segnale, il canale wireless non ha isolamento (a differenza del cavo)
- *Multipath*: la strada più breve da sorgente e destinazione è line of site. Tuttavia la propagazione spinge l'energia verso altre parti (rifrazione). Dalla sorgente le onde escono con un diverso angolo. Oltre ai segnali provenienti dalla via più breve ci sono altri segmenti che raggiungono il ricevitore (percorrono spazi più lunghi ma alla stessa velocità), causando così un iterferenza. 
- Effetto dopler: shift di frequenza del segnale in base al movimento della sorgente o della destinazione o di entrambi (più la velocità è alta più questo shift è alto).

=== Path Lost

Mi dice quanto ho perso in potenza del segnale tra il segnale che ho trasmesso (numeratore) e quello che ho ricevuto
//Aggiungere formula

La potenza di trasmissione è in generale maggiore di quella di ricezione. 

La parte:
$ 
  ((4pi f)/c)^2 d^n 
$
richiama molto la superficie della sfera. L'antenna ha una capacità di ricezione limitata. Mano mano che l'onda si allontana dalla sorgente (riguardare). Sfera piccola se siamo vicini, sfera grande se siamo lontani. 
//Aggiugnere disegno sfera e riguardare concetto

Il costo è direttamente proporzionale al quadrato delal distanza (esponente minimo), perdiamo tantissimo. Tuttavia possiamo cambiare la frequenza. 
#informalmente()[
  La formula ci dice : 
  - più lontani siamo più la potenza del segnale ricevuta è minore
  - dipende anche dalla frequenza $f$. più la frequenza è alta più perdiamo potenza a parità di distanza. 

  #esempio()[
    Se a parità di potenza mettiamo un acces point la copertura della banda $2.4"Ghz"$ è maggiore della $5"Ghz"$ 
  ]
]

Il grafico ci dice data la distanza la perdità del segnale in decibel. Attorno ai $3"Ghz"$ gira la rete cellulare

=== Antenna Gain

// R
Gain(guadagno) dell'antenna. 


Perdità di un caso isotropico. Alla perdità sottraiamo quello che guadagnamo con le antenne direzionali (antenna gain). Avendo le antenne direzionali perdiamo di meno, dipende da quanto sono direzionali le antenne di trasmissione e ricezione. 

=== Multipath 

L'immisione di raggi non è un singolo fascio. Abbiamo una serie di onde che colpiscono oggetti in direzioni diverse, abbiamo fenomeni di: 
- riflessione
- scattering, viene preso un oggetto con la stessa lunghezza d'onda del segnale, le onde vengono sparate in diverse direzioni
- Diffrazione: cambia e devia il suo percorso e direzione, ad esempio quando incrocia un palazzo. 

Al ricevitore arrivano tutti questi segnali. I segnali si combinano in modo casuale, portando a: 
- *fading*: oltre alla perdità di potenza dovuta alla distanza perdiamo anche per interferenze distruttive
- *interferenza inter-simbolo*: trasemtto un simbolo come un impulso in un certo intervallo. Se l'intervallo è troppo breve, potrebbe accadere che riceverei mentre sto trasmettendo il simbolo successivo ancora dei segnali del simbolo precedente, generando un interferenza distruttiva

*Fading*, potrei sia ottenere un segnalo amplificato che sia un segnale nullo (interferenze distruttive)
#nota()[
  Non ho controllo su come combinare in modo costruttivo questi segnali, potrei ottenere uan cstruzione o distruzione di onde elettromagnetiche
] 
Inoltre, potrei avere un tempo di cooerenza del segnale, ovvero un tempo in cui si possono considerare caratteristiche costanti del segnale:
$
  T_c = 1 / f_d
$ 
Dipende dalla frequenza dopler. La frequenza di dopler $f_d$ dipende dalla velocità relativa tra trasmettitore e ricevitore e anche dalla frequenza della portante. 

#informalmente()[
  più vado veloce e più alte sono le frequenze della portante devo rifare le stime del campionamento. 
]