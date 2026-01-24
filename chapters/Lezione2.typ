#import "../template.typ": *

= Lezione 2

// TODO SPOTARE DI SEZIONE
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

== Trasmissione wireless

=== Trasmissione in banda base

La trasmissione in *banda base* ha uno spettro che va da $0$ all'ampiezza di banda massima $B$ del canale. 

#esempio()[
  Lo spettro sonoro è in banda base. Da 0 a $22"MHz"$.
]

Questo tipo di trasmissione va bene per la comunicazione via cavo, tuttavia presenta una serie di *$mr("criticità")$* in ambito wireless:

- problemi di *sicurezza*. Se tutte le trasmissioni via radio (Militare, Tv) usassero lo spettro radio $[0,B]$ *interferirebbero* tra di loro.

- più la frequenza è bassa, più *l'antenna* per ricevere il segnale deve essere *grande*. Essa deve avere una dimensione che sia almeno metà della lunghezza d'onda $tilde lambda / 2$ (dipolo). 
  #esempio()[
    Per una frequenza a $1"MHz"$ servirebbe un'antenna di almeno $142"cm"$.
  ]

- ogni range di radio frequenze possiede *diverse proprietà* di propagazione e attenuazione.  

#attenzione()[
  Il mezzo di trasmissione wireless è intrisicamente broadcast, tutti possono vedere le onde eletromagnitiche
]

=== Trasmissione in banda traslata

Per *evitare* di avere *trasmissione sovrapposte* viene utilizzata la trasmissione in banda traslata (o passa banda). 

Viene introdotta una fase intermedia chiamata *modulazione*. Essa agisce sulla *frequenza portante* $f_c$, in comune tra trasmettitore e ricevitore. 
L'operazione di modulazione permette di spostare un segnale originale (in banda base) a frequenze più elevate. Il risultato è un segnale "passa banda", centrato attorno alla frequenza portante, che occupa una porzione specifica dello spettro. 

#nota()[
  L'operazione di modulazione non intacca Bandwidth e data rate. 
]

Lo spettro utilizzato diventa:
#figure(
  {
    set text(size: 9pt)
    
    // Contenitore medio
    box(width: 50%, height: 80pt, {
      place(
        dx: 0pt,
        dy: 65pt,
        line(length: 200pt, stroke: 0.7pt + black)
      )
      
      // Freccia asse x
      place(
        dx: 196pt,
        dy: 61pt,
        polygon(
          fill: black,
          (0pt, 0pt),
          (5pt, 4pt),
          (0pt, 8pt)
        )
      )
      
      // Etichetta asse x
      place(
        dx: 206pt,
        dy: 61pt,
        text(size: 8pt)[Frequenze]
      )
      
      // Asse y
      place(
        dx: 15pt,
        dy: 0pt,
        line(length: 68pt, angle: 90deg, stroke: 0.7pt + black)
      )
      
      // Freccia asse y
      place(
        dx: 11pt,
        dy: -3pt,
        polygon(
          fill: black,
          (4pt, 0pt),
          (0pt, 5pt),
          (8pt, 5pt)
        )
      )
      
      // Rettangolo spettro - parte sinistra
      place(
        dx: 60pt,
        dy: 28pt,
        rect(width: 50pt, height: 37pt, fill: rgb("#0284c7"), stroke: none)
      )
      
      // Rettangolo spettro - parte destra
      place(
        dx: 110pt,
        dy: 28pt,
        rect(width: 50pt, height: 37pt, fill: rgb("#0ea5e9"), stroke: none)
      )
      
      // Linee verticali tratteggiate
      place(
        dx: 60pt,
        dy: 65pt,
        line(length: 10pt, angle: 90deg, stroke: (paint: black, thickness: 0.7pt, dash: "dashed"))
      )
      
      place(
        dx: 110pt,
        dy: 65pt,
        line(length: 10pt, angle: 90deg, stroke: (paint: black, thickness: 0.7pt, dash: "dashed"))
      )
      
      place(
        dx: 160pt,
        dy: 65pt,
        line(length: 10pt, angle: 90deg, stroke: (paint: black, thickness: 0.7pt, dash: "dashed"))
      )
      
      // Etichette frequenze
      place(
        dx: 44pt,
        dy: 78pt,
        text(size: 8pt)[$f_c - B\/2$]
      )
      
      place(
        dx: 100pt,
        dy: 78pt,
        text(size: 8pt)[$f_c$]
      )
      
      place(
        dx: 145pt,
        dy: 78pt,
        text(size: 8pt)[$f_c + B\/2$]
      )
    })
  },
  caption: [Spettro di una trasmissione in banda traslata ]
)

$mg("Vantaggi")$ della modulazione:
- *Dimensioni delle antenne*: Traslare un segnale a frequenze molto più alte, riduce drasticamente la dimensione dell'antenna. 
- *Multiplexing*: Permette di inviari più segnali contemporaneamente su un unico canale, assegnando a ciascuno di essi una diversa frequenza portante
-  *Efficienza*: Adatta segnali diversi (audio, video, dati) a canali di trasmissione idonei, riducendo interferenze e attenuazione. 

== Encoding symbol

Un *simbolo* è una forma d'onda, uno stato (livello di voltaggio) o una condizione significativa del canale che *persiste* per un certo intervallo di *tempo*. 

#attenzione()[
  Un symbol *non* è semplicemente del rumore sul canale, ma è ben definito.
]

Il *Symbole rate* è il numero di simboli emessi dal livello fisico in un secondo, si misura in _Bd_ (_Baud_). 

#esempio()[
  Il symbol rate può rappresentare quante volte il livello fisico è in grado di cambiare il voltaggio in un secondo. 
]


#attenzione()[
 In generale un simbolo è un grado di *codificare più bit*, per questo motivo:
 *$
  "symbol rate" != "bit rate" \
  "bit rate" >= "symbol rate"
  $*
  Queste due misure corrispondono quando il livello fisico è in grado di produrre solamente $2$ segnali, _alto_ e _basso_. 
]

Andiamo ad utilizzare come parametro la modulazione dell'*ampiezza di un onda* per identificare i diversi simboli (cambia l'altezza dell'onda). Questa tecnica prende il nome di *Amplitude shift key* (coppia chiave, parametri): 
- *chiave*: è la sequenza di bit che vogliamo rappresentare 
- *parametri*: è l'onda elettromagnetica che dobbiamo emettere per un certo intervallo di tempo

#figure(
  {
    set text(size: 9pt)
    
    grid(
      columns: (1fr, 1.5fr),
      column-gutter: 20pt,
      [
        // Tabella simboli e voltaggi
        #table(
          columns: 2,
          stroke: 0.5pt + black,
          fill: (col, row) => if row == 0 { luma(220) } else if col == 1 { rgb("#e0f2fe") },
          align: center,
          [*Bit*], [*Simbolo*],
          [00], [-3 V],
          [01], [-1 V],
          [10], [1 V],
          [11], [3 V],
        )
        
        #v(-30pt)
        
        // Segnale digitale
        #box(width: 100%, height: 100pt, {
          // Linea base
          place(dx: 0pt, dy: 50pt, line(length: 180pt, stroke: 0.5pt))
          
          // Linee di riferimento per i livelli
          place(dx: 0pt, dy: 20pt, line(length: 180pt, stroke: (paint: gray.lighten(60%), dash: "dotted", thickness: 0.3pt)))
          place(dx: 0pt, dy: 35pt, line(length: 180pt, stroke: (paint: gray.lighten(60%), dash: "dotted", thickness: 0.3pt)))
          place(dx: 0pt, dy: 65pt, line(length: 180pt, stroke: (paint: gray.lighten(60%), dash: "dotted", thickness: 0.3pt)))
          
          // Simbolo 1: 00 -> -3V (alto)
          place(dx: 0pt, dy: 50pt, line(end: (0pt, -30pt), stroke: 2pt + red))
          place(dx: 0pt, dy: 20pt, line(length: 30pt, stroke: 2pt + red))
          
          // Simbolo 2: 01 -> -1V (alto medio)
          place(dx: 30pt, dy: 20pt, line(end: (0pt, 45pt), stroke: 2pt + red))
          place(dx: 30pt, dy: 65pt, line(length: 30pt, stroke: 2pt + red))
          
          // Simbolo 3: 10 -> 1V (basso)
          place(dx: 60pt, dy: 65pt, line(end: (0pt, -30pt), stroke: 2pt + red))
          place(dx: 60pt, dy: 35pt, line(length: 30pt, stroke: 2pt + red))
          
          // Simbolo 4: 11 -> 3V (molto basso)
          place(dx: 90pt, dy: 35pt, line(end: (0pt, 45pt), stroke: 2pt + red))
          place(dx: 90pt, dy: 80pt, line(length: 30pt, stroke: 2pt + red))
          
          // Simbolo 5: 01 -> -1V (alto medio)
          place(dx: 120pt, dy: 80pt, line(end: (0pt, -15pt), stroke: 2pt + red))
          place(dx: 120pt, dy: 65pt, line(length: 30pt, stroke: 2pt + red))
          
          // Simbolo 6: 00 -> -3V (alto)
          place(dx: 150pt, dy: 65pt, line(end: (0pt, -45pt), stroke: 2pt + red))
          place(dx: 150pt, dy: 20pt, line(length: 30pt, stroke: 2pt + red))
          
          // Etichette bit
          place(dx: 8pt, dy: 90pt, text(size: 7pt)[00])
          place(dx: 38pt, dy: 90pt, text(size: 7pt)[01])
          place(dx: 68pt, dy: 90pt, text(size: 7pt)[10])
          place(dx: 98pt, dy: 90pt, text(size: 7pt)[11])
          place(dx: 128pt, dy: 90pt, text(size: 7pt)[01])
          place(dx: 158pt, dy: 90pt, text(size: 7pt)[00])
          
          // Etichette voltaggio
          place(dx: -15pt, dy: 17pt, text(size: 6pt)[-3V])
          place(dx: -15pt, dy: 32pt, text(size: 6pt)[1V])
          place(dx: -15pt, dy: 47pt, text(size: 6pt)[0V])
          place(dx: -15pt, dy: 62pt, text(size: 6pt)[-1V])
          place(dx: -15pt, dy: 77pt, text(size: 6pt)[3V])
        })
      ],
      [
        // Grafico della forma d'onda modulata
        #align(center)[*Modulazione M-ASK*]
        
        #box(width: 100%, height: 120pt, {
          // Asse Y (Voltaggio)
          place(dx: 15pt, dy: 10pt, line(length: 100pt, angle: 90deg, stroke: 0.5pt))
          place(dx: 10pt, dy: 8pt, text(size: 7pt)[V])
          
          // Asse X (Tempo)
          place(dx: 15pt, dy: 110pt, line(length: 250pt, stroke: 0.5pt))
          
          // Linea centrale (0V)
          place(dx: 15pt, dy: 60pt, line(length: 250pt, stroke: (paint: gray, dash: "dotted", thickness: 0.3pt)))
          
          // Simbolo 1: 00 -> -3V (ampiezza alta)
          for i in range(0, 8) {
            let x1 = 15pt + i * 5pt
            let x2 = 15pt + (i + 1) * 5pt
            let y1 = (60 + 35 * calc.sin(i * 45deg)) * 1pt
            let y2 = (60 + 35 * calc.sin((i + 1) * 45deg)) * 1pt
            place(dx: x1, dy: y1, line(end: (x2 - x1, y2 - y1), stroke: 1.5pt + blue))
          }
          
          // Divisore e etichetta simbolo 1
          place(dx: 55pt, dy: 20pt, line(length: 90pt, angle: 90deg, stroke: (paint: red, dash: "dashed", thickness: 0.5pt)))
          place(dx: 28pt, dy: 115pt, text(size: 6pt)[00])
          
          // Simbolo 2: 01 -> -1V (ampiezza media-bassa)
          for i in range(0, 8) {
            let x1 = 55pt + i * 5pt
            let x2 = 55pt + (i + 1) * 5pt
            let y1 = (60 + 15 * calc.sin(i * 45deg)) * 1pt
            let y2 = (60 + 15 * calc.sin((i + 1) * 45deg)) * 1pt
            place(dx: x1, dy: y1, line(end: (x2 - x1, y2 - y1), stroke: 1.5pt + blue))
          }
          
          // Divisore e etichetta simbolo 2
          place(dx: 95pt, dy: 20pt, line(length: 90pt, angle: 90deg, stroke: (paint: red, dash: "dashed", thickness: 0.5pt)))
          place(dx: 68pt, dy: 115pt, text(size: 6pt)[01])
          
          // Simbolo 3: 10 -> 1V (ampiezza media-alta)
          for i in range(0, 8) {
            let x1 = 95pt + i * 5pt
            let x2 = 95pt + (i + 1) * 5pt
            let y1 = (60 - 15 * calc.sin(i * 45deg)) * 1pt
            let y2 = (60 - 15 * calc.sin((i + 1) * 45deg)) * 1pt
            place(dx: x1, dy: y1, line(end: (x2 - x1, y2 - y1), stroke: 1.5pt + blue))
          }
          
          // Divisore e etichetta simbolo 3
          place(dx: 135pt, dy: 20pt, line(length: 90pt, angle: 90deg, stroke: (paint: red, dash: "dashed", thickness: 0.5pt)))
          place(dx: 108pt, dy: 115pt, text(size: 6pt)[10])
          
          // Simbolo 4: 11 -> 3V (ampiezza massima)
          for i in range(0, 8) {
            let x1 = 135pt + i * 5pt
            let x2 = 135pt + (i + 1) * 5pt
            let y1 = (60 - 35 * calc.sin(i * 45deg)) * 1pt
            let y2 = (60 - 35 * calc.sin((i + 1) * 45deg)) * 1pt
            place(dx: x1, dy: y1, line(end: (x2 - x1, y2 - y1), stroke: 1.5pt + blue))
          }
          
          // Divisore e etichetta simbolo 4
          place(dx: 175pt, dy: 20pt, line(length: 90pt, angle: 90deg, stroke: (paint: red, dash: "dashed", thickness: 0.5pt)))
          place(dx: 148pt, dy: 115pt, text(size: 6pt)[11])
          
          // Simbolo 5: 01 -> -1V (ampiezza media-bassa)
          for i in range(0, 8) {
            let x1 = 175pt + i * 5pt
            let x2 = 175pt + (i + 1) * 5pt
            let y1 = (60 + 15 * calc.sin(i * 45deg)) * 1pt
            let y2 = (60 + 15 * calc.sin((i + 1) * 45deg)) * 1pt
            place(dx: x1, dy: y1, line(end: (x2 - x1, y2 - y1), stroke: 1.5pt + blue))
          }
          
          // Divisore e etichetta simbolo 5
          place(dx: 215pt, dy: 20pt, line(length: 90pt, angle: 90deg, stroke: (paint: red, dash: "dashed", thickness: 0.5pt)))
          place(dx: 188pt, dy: 115pt, text(size: 6pt)[01])
          
          // Simbolo 6: 00 -> -3V (ampiezza alta)
          for i in range(0, 8) {
            let x1 = 215pt + i * 5pt
            let x2 = 215pt + (i + 1) * 5pt
            let y1 = (60 + 35 * calc.sin(i * 45deg)) * 1pt
            let y2 = (60 + 35 * calc.sin((i + 1) * 45deg)) * 1pt
            place(dx: x1, dy: y1, line(end: (x2 - x1, y2 - y1), stroke: 1.5pt + blue))
          }
          
          // Etichetta simbolo 6
          place(dx: 228pt, dy: 115pt, text(size: 6pt)[00])
        })
      ]
    )
  },
  caption: [Modulazione M-ASK: sequenza 00 01 10 11 01 00]
)

#informalmente()[
  Quando il canale è disturbato, il trasmettitore smette di usare modulazioni complesse (tanti bit per simbolo) e passa a modulazioni semplici (meno bit per simbolo) per evitare errori, riducendo però la velocità di trasmissione.
]

Se il segnale è pulito, possiamo andare a "riempire" un simbolo con più bit. Se c'è rumore, dobbiamo svuotarlo per essere sicuri che arrivi a destinazione. Seguendo questa idea una data *bandwidth* può supportare *diversi data rate* a seconda dell'abilità del ricevente di distinguere $0$ e $1$ in presenza di rumore. 

#esempio()[
  Supponendo di usare una $4$-ASK (4 bit per simbolo), vogliamo andare a creare $4$ livelli di ampiezza dove ogni livello corrisponde ad una coppia di bit: 
  - Ampiezza $100% -> 11$ 
  - Ampiezza $75% -> 10$
  - Ampiezza $50% -> 01$
  - Ampiezza $25% -> 00$

  Se c'è molto "rumore" (interferenze elettromagnetiche), un segnale che è partito al $50%$ potrebbe arrivare sporcato e sembrare al $60%$, producendo un errrore nel ricevitore. 

  In questo caso sarebbe stato meglio andare ad utilizzare la $2$-ASK ($0%$ o $100%$), anche se il segnale arriva sporco al $60%$, il ricevitore riesce a risalire al messaggio originale. 
]

== Trasmissione radio

Ci sono diversi tipi di onde radio, in base alla frequenza utilizzata: 

- *Ground Wave propagation*: se siamo sotto i $2"MHz"$ non è necessario che trasmettitore e ricevitore si vedano (in linea d'aria).

- *Sky wave propagation*: se siamo nel range $2-30 "MHz"$ il segnale rimbalza sulla iomosfera. Trasmettitore e ricevitore possono non essere in linea d'aria.

- *Line-Of-sight* (LOS) propagation: sopra i $30"MHz"$ (frequenza delle telecomunicazioni) il trasmettitore e il ricevitore devono vedersi, devono trovarsi sulla stessa retta in linea d'aria.

Anche le antenne si dividono in due tipi: 
- *Omnidirezionale*: il segnale viene propagato con la stessa potenza in tutte le direzioni.

- *Direzionale*: si vuole propagare il segale in una certa direzione, l'energia viene concentrata in un unico punto (line of site) sia per la trasmissione che per la ricezione.

  #nota()[
    L'antenna direzionale non è perfetta. Il segnale potrebbe essere propagato (con una potenza minore) anche in altre  direzioni rispetto alla _los_.
  ]

== Trasmissione LOS

Durante la trasmissione radio, dobbiamo tenere in considerazione i seguenti *$mr("problemi")$*: 

- *Path lost*: attenuazione del segnale in base alla distanza e all'ambiente in cui il segnale si propaga (problema presente anche su cavo ma in maniera limitata).

- *Rumore*: diturbo che distorce il segnale, il canale wireless non ha isolamento (a differenza del cavo).

- *Multipath*: la strada più breve dalla  sorgente alla destinazione è il line of site. Tuttavia, la propagazione spinge l'energia verso altre parti (*rifrazione*). Dalla sorgente le onde escono con un diverso angolo.\ 
  Oltre ai segnali provenienti dalla via più breve, il ricevitore viene raggiunto da altri segmenti (percorrono spazi più lunghi con alla stessa velocità), causando così un *interferenza*. 

- *Effetto dopler*: shift di frequenza del segnale in base al movimento della sorgente, della destinazione o presenza di ostacoli. 
  #nota()[
    Lo shift aumenta in maniera proporzionale alla velocità di spostamento della sorgenete o destinazione.
  ]

=== Path Lost

#informalmente()[
  Quantifica la *perdità di potenza* del segnale trasmesso rispetto a quello ricevuto.

  Si misura in *decibel $"dB"$*
]

Viene calcolata come: 
$
  L = P_t / P_r = ((4pi)/(lambda))^2 d^n underbrace(=, mr(lambda = c/f)) ((4pi f)/(c))^2 d^n 
$
Dove: 
- $d$: distanza tra le antenne
- $f$: frequenza del segnale
- $c$: velocità della luce $3 dot 10^8 m/s$
- *$n$*: esponente della path loos (valore base = 2), man mano che aumentano gli ostacoli sale (*dipende dall'ambiente*) 

#nota()[
  La potenza di trasmissione ($P_t$) è in generale maggiore di quella di ricezione ($P_r$). 
]

La perdità di potenza segue la *legge dell'inverso del quadrato*. Essa afferma che *l'intensità* di una grandezza fisica *diminuisce proporzionalmente al quadrato della distanza* dalla sua sorgente: _se la distanza raddoppia, l'intensità diventa un quarto_. L'energia si distribuisce su una superficie che cresce con il quadrato della distanza (come la superficie di una sfera $4 pi d^2$).

Possiamo quindi scrivere: 
$
  L  infinity  f^2
$
Se aumentiamo la frequenza, la lunghezza d'onda $lambda$ diventa più piccola. Come abbiamo visto prima, un'antenna standard deve essere proporzionata alla lunghezza d'onda ($lambda / 2$):
  - Frequenza Alta $->$ $lambda$ piccola $->$ Antenna ricevente fisicamente più piccola.
  - Frequenza Bassa $->$ $lambda$ grande $->$ Antenna ricevente fisicamente più grande.

Un'antenna più piccola cattura meno segnale. 

#nota()[
  A parità di distanza, maggiore è la frequenza, maggiore è il path loss.

  Con _free space loss_ si intende la perdita ideale in caso di spazio completamente libero, quindi con $d^n = d^2$ .
]


#informalmente()[
  La formula ci dice : 
  - più il *ricevitore è lontano*, più la *potenza del segnale ricevuto è minore*
  - *dipende anche dalla frequenza* $f$. A parità di potenza, più la frequenza è alta, minore è il raggio di copertura.

  #esempio()[
    A parità di potenza, la copertura di un acces point è maggiore con una frequenza pari a $2.4"Ghz"$ rispetto a $5"Ghz"$.
  ]
]

#figure(
  {
    set text(size: 8pt)
    
    box(width: 70%, height: 250pt, {
      // Griglia di sfondo
      for i in range(0, 13) {
        let y = 20pt + i * 16pt
        place(dx: 30pt, dy: y, line(length: 240pt, stroke: (paint: blue.lighten(70%), thickness: 0.3pt)))
      }
      for i in range(0, 13) {
        let x = 30pt + i * 20pt
        place(dx: x, dy: 20pt, line(length: 192pt, angle: 90deg, stroke: (paint: blue.lighten(70%), thickness: 0.3pt)))
      }
      
      // Asse X (Distance)
      place(dx: 30pt, dy: 212pt, {
        line(length: 240pt, stroke: 1pt + black)
        place(dx: 100pt, dy: 18pt, text(size: 8pt)[Distance (km)])
      })
      
      // Asse Y (Free Space Path Loss)
      place(dx: 30pt, dy: 20pt, {
        line(length: 192pt, angle: 90deg, stroke: 1pt + black)
        place(dx: -110pt, dy: -100pt, text(size: 8pt)[Free space path loss (dB)])
      })
      
      // Etichette asse X
      place(dx: 25pt, dy: 220pt, text(size: 6pt)[1])
      place(dx: 85pt, dy: 220pt, text(size: 6pt)[5])
      place(dx: 125pt, dy: 220pt, text(size: 6pt)[10])
      place(dx: 205pt, dy: 220pt, text(size: 6pt)[50])
      place(dx: 265pt, dy: 220pt, text(size: 6pt)[100])
      
      // Etichette asse Y (da 60 a 180)
      place(dx: 10pt, dy: 210pt, text(size: 6pt)[60])
      place(dx: 10pt, dy: 194pt, text(size: 6pt)[70])
      place(dx: 10pt, dy: 178pt, text(size: 6pt)[80])
      place(dx: 10pt, dy: 162pt, text(size: 6pt)[90])
      place(dx: 5pt, dy: 146pt, text(size: 6pt)[100])
      place(dx: 5pt, dy: 130pt, text(size: 6pt)[110])
      place(dx: 5pt, dy: 114pt, text(size: 6pt)[120])
      place(dx: 5pt, dy: 98pt, text(size: 6pt)[130])
      place(dx: 5pt, dy: 82pt, text(size: 6pt)[140])
      place(dx: 5pt, dy: 66pt, text(size: 6pt)[150])
      place(dx: 5pt, dy: 50pt, text(size: 6pt)[160])
      place(dx: 5pt, dy: 34pt, text(size: 6pt)[170])
      place(dx: 5pt, dy: 18pt, text(size: 6pt)[180])
      
      // Funzione per convertire coordinate logaritmiche
      let log_x(d) = {
        30pt + calc.log(d) / calc.log(100) * 240pt
      }
      
      let linear_y(loss) = {
        212pt - (loss - 60) * 1.6pt
      }
      
      // Linea f = 300 MHz
      for i in range(0, 50) {
        let d1 = calc.pow(100, i / 50.0)
        let d2 = calc.pow(100, (i + 1) / 50.0)
        let loss1 = 62 + 20 * calc.log(d1)
        let loss2 = 62 + 20 * calc.log(d2)
        let x1 = log_x(d1)
        let x2 = log_x(d2)
        let y1 = linear_y(loss1)
        let y2 = linear_y(loss2)
        place(dx: x1, dy: y1, line(end: (x2 - x1, y2 - y1), stroke: 1.5pt + red))
      }
      place(dx: 140pt, dy: 160pt, text(size: 8pt, fill: red)[$f = 30 "MHz"$])
      
      // Linea f = 3 GHz
      for i in range(0, 50) {
        let d1 = calc.pow(100, i / 50.0)
        let d2 = calc.pow(100, (i + 1) / 50.0)
        let loss1 = 82 + 20 * calc.log(d1)
        let loss2 = 82 + 20 * calc.log(d2)
        let x1 = log_x(d1)
        let x2 = log_x(d2)
        let y1 = linear_y(loss1)
        let y2 = linear_y(loss2)
        place(dx: x1, dy: y1, line(end: (x2 - x1, y2 - y1), stroke: 1.5pt + red))
      }
      place(dx: 150pt, dy: 28pt, text(size: 8pt, fill: red)[$f = 300 "GHz"$])
      
      // Linea f = 30 GHz
      for i in range(0, 50) {
        let d1 = calc.pow(100, i / 50.0)
        let d2 = calc.pow(100, (i + 1) / 50.0)
        let loss1 = 102 + 20 * calc.log(d1)
        let loss2 = 102 + 20 * calc.log(d2)
        let x1 = log_x(d1)
        let x2 = log_x(d2)
        let y1 = linear_y(loss1)
        let y2 = linear_y(loss2)
        place(dx: x1, dy: y1, line(end: (x2 - x1, y2 - y1), stroke: 1.5pt + red))
      }
      place(dx: 145pt, dy: 125pt, text(size: 8pt, fill: red)[$f = 300 "MHz"$])
      
      // Linea f = 300 GHz
      for i in range(0, 50) {
        let d1 = calc.pow(100, i / 50.0)
        let d2 = calc.pow(100, (i + 1) / 50.0)
        let loss1 = 122 + 20 * calc.log(d1)
        let loss2 = 122 + 20 * calc.log(d2)
        let x1 = log_x(d1)
        let x2 = log_x(d2)
        let y1 = linear_y(loss1)
        let y2 = linear_y(loss2)
        place(dx: x1, dy: y1, line(end: (x2 - x1, y2 - y1), stroke: 1.5pt + red))
      }
      place(dx: 153pt, dy: 90pt, text(size: 8pt, fill: red)[$f = 3 "GHz"$])
      
      // Linea f = 3 THz
      for i in range(0, 50) {
        let d1 = calc.pow(100, i / 50.0)
        let d2 = calc.pow(100, (i + 1) / 50.0)
        let loss1 = 142 + 20 * calc.log(d1)
        let loss2 = 142 + 20 * calc.log(d2)
        let x1 = log_x(d1)
        let x2 = log_x(d2)
        let y1 = linear_y(loss1)
        let y2 = linear_y(loss2)
        place(dx: x1, dy: y1, line(end: (x2 - x1, y2 - y1), stroke: 1.5pt + red))
      }
      place(dx: 150pt, dy: 59pt, text(size: 8pt, fill: red)[$f = 30 "GHz"$])
    })
  },
  caption: [
    Path loss in funzione della distanza per diverse frequenze.\
    Attorno ai $3"GHz"$ gira la rete cellulare.
  ]
)

=== Antenna Gain

#informalmente()[
  Il Gain misura quanto è più forte il segnale nella direzione "giusta" rispetto all'antenna isotropica (ideale), la quale sparge il segnale in modo equo in tutte le direzioni. 

  Il Gain ci dice quanto l'antenna è _brava_ a concentrare il raggio:
  - Alto Gain = Raggio laser (va lontanissimo, ma va puntato benissimo).
  - Basso Gain = Lanterna (va poco lontano, ma copre ovunque).

  Viene misurato in decibel (Db)
]

#figure(
  {
    set text(size: 8pt)
    
    grid(
      columns: (2fr, 1fr),
      column-gutter: 10pt,
      [
        #box(width: 100%, height: 180pt, {
        
           // Antenna direzionale (ellisse blu allungata - a destra)
          place(dx: 100pt, dy: 60pt, {
            ellipse(width: 130pt, height: 70pt, stroke: 2pt + blue, fill: rgb("#e3f2fd"))
            place(dx: 40pt, dy: -80pt, text(size: 8pt, fill: blue)[Direzionale (ideale)])
          })
          
          // Antenna isotropica (cerchio grigio - a sinistra)
          place(dx: 60pt, dy: 55pt, {
            circle(radius: 40pt, stroke: 1.5pt + gray, fill: none)
            place(dx: -60pt, dy: -50pt, text(size: 8pt, fill: black)[Isotropica (ideale)])
          })
          
          // Centro comune (origine)
          place(dx: 95pt, dy: 90pt, {
            circle(radius: 3pt, fill: black)
            place(dx: -8pt, dy: 5pt, text(size: 8pt)[$0$ dBi])
          })
         
           // Assi cartesiani
          place(dx: 100pt, dy: 90pt, line(length: 180pt, stroke: (paint: gray, dash: "dashed", thickness: 0.5pt)))
          place(dx: 100pt, dy: 10pt, line(length: 160pt, angle: 90deg, stroke: (paint: gray, dash: "dashed", thickness: 0.5pt)))
          
          // Punto A (sul cerchio isotropico)
          place(dx: 110pt, dy: 70pt, {
            circle(radius: 5pt, fill: red, stroke: 1pt + black)
            place(dx: 0pt, dy: -20pt, text(size: 8pt, weight: "bold")[A])
            place(dx: -22pt, dy: -8pt, text(size: 7pt)[$-3$dBi])
          })
          
          // Punto B (sull'ellisse direzionale, alla massima estensione)
          place(dx: 225pt, dy: 85pt, {
            circle(radius: 5pt, fill: red, stroke: 1pt + black)
            place(dx: -8pt, dy: -15pt, text(size: 8pt, weight: "bold")[B])
            place(dx: 7pt, dy: 2pt, text(size: 7pt)[+6dBi])
          })
        })
      ],
      [
        // Tabella gain
        #align(center)[
          #table(
            columns: (1fr, 1fr, 1fr),
            stroke: 1pt + black,
            fill: (col, row) => if row == 0 { luma(220) },
            align: center,
            [], [*Isotropica*], [*Direzionale*],
            [*A*], [-10dBm], [-13dBm],
            [*B*], [-20 dBm], [-14dBm],
          )
        ]      
      ]
    )
  },
  caption: [
    Confronto tra antenna isotropica e direzionale.\
    Il cerchio grigio rappresenta l'antenna ideale che spara in tutte le direzioni.\
    Il cerchio blu rappresenta l'antenna reale con Gain.\
    Il gain è espresso in dBi rispetto all'antenna isotropica ideale (nell'immagine il punto $mr("A")$ ha un gain peggiore rispetto all'antenna isotropica).
  ]
)

#attenzione()[
  L'antenna *non* è un amplificatore. Non crea energia dal nulla e non aggiunge potenza elettrica.

  Il Gain è puramente una questione di forma e direzione.
]

Possiamo ricalcolare il path loss considerando anche il gain:
$
  G_"tx" &= "Gain Trasmettitore"\
  G_"rx" &= "Gain Ricevitore"\
  P_t / P_r &= ((4pi f)/c)^2 d^n \
            &= ((4 pi f)^2 / (G_"tx" G_"rx" c^2)) dot d^n
$

Più *alto* è il *Gain*, *minore* è la *perdita* di segnale. Possiamo riscrivere la formula anche in scala logaritmica: 
$
  L_"dB" = 10 log_10 P_t/P_r = 20(log_10 (4pi f)/c - log_10 G_"tx" - log_10G_("rx"))
$
il gain ovviamente viene sottratto in modo da diminure la loss. 

#attenzione()[
  Usare antenne direzionali (High Gain) è rischioso. Se non sono perfettamente allineate, c'è il rischio di finire nella _zona morta_ (fuori dal *beam*). In questo spicchio il segnale è peggiore, rispetto ad un antenna isotropica.
]


=== Multipath 

Anche se la trasmissione avviene in maniera direzionale, il segnale avrà una _fascia_ di direzioni in cui viene inviato (*multipath*), siccome il mezzo di propagazione è l'aria esso potrà interagire con l'ambiente. Si possono verificare fenomeni di: 
- *Riflessione*: il segnale _rimbalza_ sull'oggetto colpito.
 
- *Scattering*: il segnale colpisce un oggetto avente la stessa lunghezza d'onda $lambda$, le onde vengono sparate in diverse direzioni.

- *Diffrazione*: se la lunghezza d'onda $lambda <<$ della dimensione dell'oggetto colpito e l'impatto avviene sui bordi, il segnale cambia e devia la sua direzione (_impatto con un palazzo_).

Al ricevitore $R_x$ arriveranno tutti questi segnali. Inoltre, i segnali possono *combinarsi tra di loro* in modo casuale, portando a due fenomeni, *fading* e *interferenza inter-simbolo*.

==== Fading
  
Oltre alla perdità di potenza del segnale dovuta alla distanza, possono causarsi delle interferenze durante il percorso che ne alterano ulteriormente l'intensità e la forma.

Questo accade quando più segnali vengono ricevuti in tempi diversi. Le interferenze possono essere: 
- *Costruttive*: le interferenze amplificano il segnale, suono _buone_.
- *Distruttive*: il segnale ricevuto è stato modificato in modo imprevedibile.

#nota()[
  *Non* si ha alcun controllo su come poter combinare in modo costruttivo le interferenze. 
] 

Bisogna anche tenere in conto le proprietà fisiche del mezzo e come il segnale si modifica durante la propagazione. Il *tempo di coerenza* permette di sapere ogni quanto campionare la condizione del canale, al fine di ottenere una misurazione stabile e costante. Durante questo intervallo di tempo le caratteristiche del segnale saranno _costanti_:
$
  T_c = 1 / f_D
$
Tale tempo *dipende dalla frequenza dopler ($f_D$)*: 
$
  f_D = underbrace(v/c, "velocità tra"\ T_x "e" R_x) underbrace(f_c,"frequenza portante")
$

#informalmente()[
  Maggiore è la velocità a cui spostano $T_x$ e $R_x$ e maggiore è la frequenza $->$ Più il campionamento dovrà avvenire frequentemente. 
]

==== Interferenza inter-simbolo

La trasmissione di un simbolo corrisponde all'invio di un certo impulso per un determinato intervallo di tempo. Tuttavia, se l'*intervallo è troppo breve*, potrebbe accadere che il ricevitore mentre sta già processando il simbolo successivo, riceva ancora dei segnali relativi al simbolo precedente dovuti al multipath, generando un'*interferenza distruttiva*. 




#nota[
  Maggiore è la distanza tra $T_X$ e $R_X$, più alta è la probabilità che si verifichi questo fenomeno. Trasmettendo meno simboli si ha un data rate minore, ma incrementandoli aumenta la probabilità di avere ISI.
]





#esempio()[
  
  #figure(
  {
    set text(size: 7pt)
    
    box(width: 85%, height: 180pt, {
      // Titolo in alto a destra
      place(dx: 450pt, dy: 5pt, {
        align(right)[
          #text(size: 8pt, weight: "bold")[
            Multi-path fading\
            Doppler\
            Noise
          ]
        ]
      })
      
      // Funzione helper per disegnare griglia e assi
      let draw_grid(y_offset) = {
        // Griglia
        for i in range(0, 10) {
          let x = i * 32pt
          place(dx: 30pt + x, dy: y_offset, line(length: 26pt, angle: 90deg, stroke: (paint: gray.lighten(80%), thickness: 0.2pt)))
        }
        for i in range(0, 4) {
          let y = i * 8.7pt
          place(dx: 30pt, dy: y_offset + y, line(length: 320pt, stroke: (paint: gray.lighten(80%), thickness: 0.2pt)))
        }
        // Assi
        place(dx: 30pt, dy: y_offset + 26pt, line(length: 320pt, stroke: 0.5pt + black))
        place(dx: 30pt, dy: y_offset, line(length: 26pt, angle: 90deg, stroke: 0.5pt + black))
      }
      
      // Primo grafico: onda sinusoidale pulita (nera)
      draw_grid(10pt)
      place(dx: 355pt, dy: 23pt, text(size: 6pt)[TX 400 mW])
      for i in range(0, 64) {
        let x1 = 30pt + i * 5pt
        let x2 = 30pt + (i + 1) * 5pt
        let y1 = (23 + 9 * calc.sin(i * 25deg)) * 1pt
        let y2 = (23 + 9 * calc.sin((i + 1) * 25deg)) * 1pt
        place(dx: x1, dy: y1, line(end: (x2 - x1, y2 - y1), stroke: 1.1pt + black))
      }
      
      // Secondo grafico: segnale LoS con fading (blu)
      draw_grid(44pt)
      place(dx: 355pt, dy: 57pt, text(size: 5pt, fill: blue)[RX LoS])
      for i in range(0, 128) {
        let x1 = 30pt + i * 2.5pt
        let x2 = 30pt + (i + 1) * 2.5pt
        let amp = 6 + 3 * calc.sin(i * 4deg)
        let y1 = (57 + amp * calc.sin(i * 36deg)) * 1pt
        let y2 = (57 + amp * calc.sin((i + 1) * 36deg)) * 1pt
        place(dx: x1, dy: y1, line(end: (x2 - x1, y2 - y1), stroke: 0.8pt + blue))
      }
      
      // Terzo grafico: segnale NLOS (arancione) - parte sfalsata
      draw_grid(78pt)
      place(dx: 355pt, dy: 91pt, text(size: 5pt, fill: orange)[RX NLoS 1])
      for i in range(18, 128) {
        let x1 = 30pt + i * 2.5pt
        let x2 = 30pt + (i + 1) * 2.5pt
        let amp = 5.5 + 3.5 * calc.sin(i * 5deg)
        let y1 = (91 + amp * calc.sin(i * 36deg)) * 1pt
        let y2 = (91 + amp * calc.sin((i + 1) * 36deg)) * 1pt
        place(dx: x1, dy: y1, line(end: (x2 - x1, y2 - y1), stroke: 0.8pt + orange))
      }
      
      // Quarto grafico: segnale NLOS rumoroso (verde) - continua oltre la durata del nero
      draw_grid(112pt)
      place(dx: 355pt, dy: 125pt, text(size: 5pt, fill: green)[RX NLoS 2])
      for i in range(35, 150) {  // Continua oltre (150 invece di 128)
        let x1 = 30pt + i * 2pt
        let x2 = 30pt + (i + 1) * 2pt
        let noise = calc.rem(i * 23, 7) - 3.5
        let y1 = (125 + noise) * 1pt
        let y2 = (125 + calc.rem((i + 1) * 23, 7) - 3.5) * 1pt
        place(dx: x1, dy: y1, line(end: (x2 - x1, y2 - y1), stroke: 0.7pt + green))
      }
      
      // Quinto grafico: segnale ricevuto finale MOLTO scombinato (ROSSO)
      draw_grid(146pt)
      place(dx: 355pt, dy: 159pt, text(size: 5pt, fill: red)[RX ricevuto])
      
      for i in range(0, 128) {
        let x1 = 30pt + i * 2.5pt
        let x2 = 30pt + (i + 1) * 2.5pt
        
        // Segnale molto più caotico e distorto
        let noise1 = calc.rem(i * 17, 5) - 2
        let noise2 = calc.rem(i * 13, 4) - 1.5
        let amp_combined = 4 + 3 * calc.sin(i * 9deg) + 2 * calc.sin(i * 3deg) + noise1
        let y1 = (159 + amp_combined * calc.sin(i * 45deg + 20deg) + noise2) * 1pt
        
        let noise3 = calc.rem((i + 1) * 17, 5) - 2
        let noise4 = calc.rem((i + 1) * 13, 4) - 1.5
        let amp_combined2 = 4 + 3 * calc.sin((i + 1) * 9deg) + 2 * calc.sin((i + 1) * 3deg) + noise3
        let y2 = (159 + amp_combined2 * calc.sin((i + 1) * 45deg + 20deg) + noise4) * 1pt
        
        place(dx: x1, dy: y1, line(end: (x2 - x1, y2 - y1), stroke: 0.8pt + red))
      }
    })
  },
  caption: [
    Effetti del multipath sulla ricezione del segnale.
  ]
  )
  Descrizione: 
  - Il primo *grafico* rappresenta l'onda sinusoidale prima che esca dall'antenna del trasmettitore. 
  - I grafici $mb("blu")$, $mg("verde")$ e $mo("arancione")$ rappresentano cosa succede quando il segnale viene trasmesso nell'ambiente. In particolare, il segnale $mg("verde")$ ha fatto un giro più lungo, ed è arrivata in ritardo. Se il ritardo è troppo grande, l'onda $mg("verde")$ arriverà addosso al simbolo successivo, causando ISR. 
  - il grafico $mr("rosso")$ è ciò che "sente" l'antenna ricevente ($R_x$). Il ricevitore non sente le singole linee separate ma la *somma* di tutte le onde sopra (Arancione + Verde + Blu + Rumore).
]

== Codifica e trasmissione dei dati

Codifica
- Forward e Correction, encoder
- Modulazione e codifica
- power amplifier
Decodifcia: 
- forward error, correction, decoder
- demodulation & decoding

Possiamo agire sempre su una sinusoide (combinando anche tra di loro le modulazioni) in:
- Ampiezza (ASK):  
- Frequenza (FSK): 
- Fase (PSK):

#informalmente()[
  Vogliamo avere diverse tipologie di segnale modificando le proprietà della sinusoide
]

//Aggiungere immagine
#esempio()[
  Esempi di modulazione: 
  - ASK: se trasmetto un 1 trasmetto un certo segnale con una certa ampiezza. Prendo il bit (ogni simbolo codifica 1 solo bit) e se è 0 sono in idle, aktrimenti se è 1 ho un segnale
  - FSK: le bande mostrano la durata di un simbolo e abbiamo due frequenze, a seconda che sia uno zero o un uno usiamo una frequenza o l'altra (per zero ho una frequenza minore con meno oscillazioni)
  - PSK: ho una fase a 0, nel caso devo trasmettere uno zero uso uno sfasamento, le interruzioni di fase rappresentano il cambio del bit. 
]

Nei dispositivi elettronici è molto più semplice vedere una discontinuità nella fase piuttosto che misurare il tempo (?).

DPSK. Se cambia qualcosa io cambio il simbolo. Se osservo un camvbio nel voltaggio allora è stato trasmesso un uno, se c'è un proseguo allora è stato trasmesso uno zero. 

=== Codifice per più bit

Vedremo : 
- MFSK: più frequenze che coficano più bite, il numero di bit codificati in un simbolo è $log_2(M) "bit"$.
- QPSK: codifica 2 bit per ogni simbolo 
- X-QAM: codifica x bit per ogni simbolo

==== MFSK

==== QPSK

Diagramma della costellazione. GLi estremi sono i simboli che possiamo trasmettere. 
Idea. $s(t) $ segnale che viene trasmesso. 

Ogni punto della costellazione 
Se volessi trasmettere la 10 prendo 1 per il valore I(t) e -1 per Q(t) sotituendo nella formula ottengo il segnale risultante 

La ricezione va la cosa inversa, riceve un punt distorto nella costellazione e guardo il punto più vicino nel diagramma. 

#nota()[
  trasmettitore e ricevitore devono condividere la stessa costellazione
]

QAM (disegno in 16-QAM). Il punto rappresenta la stringa di bit da trasmettere, tuttavia prendiam due valori per ogni punto. Per ogni punto sappiamo la circonferenza (ampiezza da dare a ciascuna delle parti) e le coordinate $I$ e $Q$. 

La limitazione è la potenza di trasmissione. 

Non guardiamo solo la fase, ma guardiamo anche l'ampiezza.

Vengono implementati nel seguente modo: 
- blocco di N-BIT che arriva diviso a metà, il primo blocco è in fase il secondo è in quadratura. Identifica i punti cardinali dei bit
- in fase calcoliamo in coseno e la parte in quadratura viene mandata in shift. 

//aggiugnere segnale
#esempio()[
    Esempio di QPSK

  Supponiamo di voler trasmetter i bit. QPSK ci permette di trasmetter 2 bit per ogni simbolo. Per ogni coppai di bit guardiamo il punto della costellazione a cui corrisponde ottenendo i parametri del segnale. 

  Alle variazioni cambiano il bit che si sta trasmettendo, conoscendo anche la durata se riesce a risalire ai bit trasmessi 

  Impieghiamo $8$ simboli per trasmettere la sequenza di bit. ovvero trasmettiamo $16$ bit al secondo. 
]

#esempio()[
  Esempio di 16 Quam. i bit vengono raggruppati a gruppi di $4$. 

  Più lento ???? No forse la durata del simbolo è la stessa ma trasmettiamo più bit al secondo. 
  Costellazione più denza. 
]

==== Curve di BER

L'idea è che la curva dice qual'è l'energia del bit rispetto al rumore: 
$
  "BER" = "func"(E_b/N)
$

La linea viola è più densa di quella blue. A partià di $8$db (e condizione del canale) la linea blue ha molto meno probabilità di errore rispetto a quella rosa. Più è complicata la costellazione (più è densa) dobbiamoa avere un buon canale di trasmissione, altrimenti ho più errori sul singolo bit. 

#informalmente[
  Man mano che mi muovo sulle $x$ aumento il rapporto segnale rumore, il segnale diventa sempre più forte rispetto al rumore. ù

  Sull'asse delle $y$ ho la propabilità di errore di un bit. Parte da tutti i bit. 

  La curva è in scala logaritmica. Mano mano che il segnale migliora, la probabilità di errore diminuisce (errore sul bit meno probabile). 
]

Motivazione (i punti rossi sono i centri delle costellazioni) quello che viene ricevuto è un punto nella nuvolo blue (varia in fase e altezza). Fin quando un punto ricade nel quadrato va bene (lo rimappiamo a quello più vicino). tutta via se cade fuori dal quadrato è difficile trovare un centroide. 

Più punti mettiamo nel quadrato della costellazione, la probabilità di sbagliare punto (bit) (a fronte di un canale rumoroso) è più alta. 

=== Forward error correction 

Il controllo degli errori è fatto dopo la ricezione nella comunicazione a cavo. C'è un codice che rappresenta se è stato trasmesso correttamente, se vogliamo un link affidabile richiedo la ritrasmissione con NACK o HACK. 

In ambito wireless si sbaglia molto spesso (il mezzo è molto distrubato). Continuare a ripetere la trasmissione non è una buona scelta. 

L'errore viene prevenuto. A seconda del caso si può parlare di : 
- Code redundancy
- Code rate

$k$ è il numero di bit utili trasmetti sugli effettivi $n$ trasmessi. Il parametro è scelto in base alla rumorosità del canale (più rumoroso più bit di ridondanza)


==== X-QAM
