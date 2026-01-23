#import "../template.typ": *

= Lezione 1

== Introduzione

== Principi della Trasmissione
Quando si vogliono trasmettere informazioni binarie tramite mezzo analoigico, lo schema tipico che viene adottato è il seguente:

#align(center)[
  #cetz.canvas({
    import cetz.draw: *

    let blue-box = (fill: rgb("#0072BD"), stroke: none, radius: 0.5)
    let white-box = (fill: white, stroke: black, radius: 0.5)
    let arrow-style = (mark: (end: ">", fill: black), stroke: 1pt)

    let w = 1.8
    let h = 1.5
    let gap = 2.5
    let sep = 0.15

    let x1 = 0
    let x2 = x1 + w + gap
    let x3 = x2 + w + gap
    
    rect((x1, 0), (x1 + w, h), ..blue-box, name: "tx")
    content("tx", text(fill: white, size: 0.8em)[Transmitter])

    rect((x2, 0), (x2 + w, h), ..white-box, name: "ch")
    content("ch", text(size: 0.8em)[Channel])

    rect((x3, 0), (x3 + w, h), ..blue-box, name: "rx")
    content("rx", text(fill: white, size: 0.8em)[Receiver])

    line((x1 - 2.5, h/2), (rel: (-sep, 0), to: "tx.west"), ..arrow-style, name: "l1")
    content("l1.mid", anchor: "south", padding: 0.2)[$d(t)$]

    line((rel: (sep, 0), to: "tx.east"), (rel: (-sep, 0), to: "ch.west"), ..arrow-style, name: "l2")
    content("l2.mid", anchor: "south", padding: 0.2)[$s(t)$]

    line((rel: (sep, 0), to: "ch.east"), (rel: (-sep, 0), to: "rx.west"), ..arrow-style, name: "l3")
    content("l3.mid", anchor: "south", padding: 0.2, text(fill: red, weight: "bold")[$s'(t)$])

    line((rel: (sep, 0), to: "rx.east"), (x3 + w + 2.5, h/2), ..arrow-style, name: "l4")
    content("l4.mid", anchor: "south", padding: 0.2)[$d(t)$]
    
    content((x2 + w/2, h + 2.2), anchor: "south")[
      Rumore\
      Attenuazione\
      Interferenze
    ]

    line((x2 + w/2, h + 2.0), (rel: (0, sep), to: "ch.north"), ..arrow-style)
  })
]

È possibile notare come l'informazione trasmessa, passando per un canale non perfetto venga alterata a causa di:
- *Rumore*: interferenze casuali che alterano il segnale trasmesso (non ingorabile);
- *Attenuazione*: perdita di potenza del segnale con la distanza;
- *Interferenze*: presenza di altri segnali, sia casuali e causate dalla tecnologia adoperata, sia volontari.

L'obiettivo deve quindi essere di strutturare il segnale in modo tale che, nonostante queste alterazioni, il ricevitore sia in grado di ricostruire correttamente l'informazione trasmessa. Ovviamente, maggiori sono le alterazioni del segnale, più la ricostruzione delle informazioni risulterà difficoltosa.

Possiamo dividere le tipologie di segnali in 2 categorie:
- *Analogico*: Variazione continua e senza interruzioni/discontinuità nel tempo.

#align(center)[
  #cetz.canvas(length: 0.7cm, {
    import cetz.draw: *

    let x-max = 14
    let y-max = 6
    
    line((0, 0), (x-max, 0), mark: (end: ">", fill: black), name: "x")
    line((0, 0), (0, y-max), mark: (end: ">", fill: black), name: "y")

    content("x.end", anchor: "west", padding: 0.2)[*Time*]
    content("y.end", anchor: "south")[*Amplitude*]

    catmull(
      (0.5, 1.0),
      (1.5, 2.0), (2.0, 1.2),
      (3.0, 1.3), (3.8, 2.8), (4.5, 2.2), (5.0, 1.2),
      (5.5, 4.0), (6.0, 2.5),
      (7.0, 3.5), (8.0, 2.0),
      (9.0, 1.8), (10.0, 2.2), (10.5, 1.5),
      (11.0, 3.8), (11.5, 2.0),
      (12.5, 1.8),
      tension: 0.4,
      stroke: (paint: red, thickness: 2pt)
    )
    
    content((x-max/2, -1), text(weight: "bold")[(a) Analog])
  })
]

Dal grafico, è possibile notare l'ampiezza del segnale (asse `Y`) e come varia nel tempo (asse `X`).
Un esempio pratico di _segnale analogico_ è la voce umana, che varia in modo continuo nel tempo: esiste in ogni singolo istante e non ci sono "buchi" se la misuriamo tra 1 e 2 secondi.

#pagebreak()

- *Digitale*: Mantenimento costante, all'interno di un range temporale, del livello di segnale. Il cambio di livello avviene in modo istantaneo (discontinuo).

#align(center)[
  #cetz.canvas(length: 0.7cm, {
    import cetz.draw: *

    let x-max = 15
    let y-max = 5
    let h = 2.0

    line((0, 0), (x-max, 0), mark: (end: ">", fill: black), name: "x")
    line((0, 0), (0, y-max), mark: (end: ">", fill: black), name: "y")

    content("y.end", anchor: "south")[*Amplitude*]
    content("x.end", anchor: "west", padding: 0.2)[*Time*]

    line(
      (0, 0), (1, 0), 
      (1, h), (2.2, h), (2.2, 0),
      (3.5, 0), 
      (3.5, h), (7.0, h), (7.0, 0),
      (8.5, 0), 
      (8.5, h), (9.8, h), (9.8, 0),
      (10.5, 0), 
      (10.5, h), (11.8, h), (11.8, 0),
      (13.2, 0), 
      (13.2, h), (14.5, h),
      stroke: (paint: red, thickness: 2pt)
    )

    content((x-max/2, -1), text(weight: "bold")[(b) Digital])
  })
]

#nota[
Essendo un segnale digitale una vera e propria "traduzione" di quello analogico, ovvero di un fenomeno fisico reale, è normale che si creino punti di discontinuità. Un segnale analogico, come la voce, ha infatti infinite sfumature (tra il valore 10 e il valore 11 vi sono infiniti valori) e un computer, avendo memoria finita, deve in qualche modo semplificare il tutto.
]

Ciò che fanno *trasmettitore* e *ricevitore* è passare da una forma d'onda all'altra. Questa conversione è indispensabile per 2 motivi pratici fondamentali:
- I nostri dispositivi (PC, smartphone) elaborano e memorizzano le informazioni in *digitale* (bit);
- Il mezzo fisico di trasporto (l'aria per il wireless, o i cavi) permette la propagazione solo di segnali *analogici* (onde elettromagnetiche continue).
Alla luce di ciò, è facile intuire che, per comunicare correttamente, questa traduzione continua dev'essere svolta continuamente e con un margine d'errore alquanto ridotto.

== Rappresentazione dei segnali
Ogni segnale è rappresentabile come una funzione del tempo $s(t)$, dove $t$ è il tempo e $s$ l'ampiezza del segnale in quel preciso istante:

$ s(t) = A dot sin(2 pi f t + Phi) $

Dove:
- $A ->$ è l'ampiezza del segnale (massimo valore raggiungibile sull'asse `X`, misurato in `Volt`);
- $f ->$ è la frequenza del segnale (numero di cicli al secondo, misurata in `Hz`);
- $Phi ->$ è la fase del segnale (spostamento orizzontale della sinusoide);
- $T ->$ è il periodo del segnale (il tempo impiegato per un ciclo, corrispondente a $1/f$);
- $lambda ->$ Lunghezza d'onda (distanza tra due picchi consecutivi della sinusoide: $lambda = c/f$ oppure $lambda = c T$, dove $c$ è la velocità della luce $c = 3 dot 10^8 m\/s$).

#pagebreak()

#esempio[
  Grafico $sin(t)$:

  #align(center)[
  #cetz.canvas(length: 0.8cm, {
    import cetz.draw: *

    let x-scale = 6
    let y-scale = 2.5
    
    let points = ()
    let steps = 100
    for i in range(0, steps + 1) {
      let t = i / steps * 1.5
      let val = calc.sin(2 * calc.pi * t)
      points.push((t * x-scale, val * y-scale))
    }

    set-style(stroke: (thickness: 0.5pt, paint: gray))
    for i in (0, 0.5, 1.0, 1.5) {
        line((i * x-scale, -1 * y-scale), (i * x-scale, 1 * y-scale))
    }
    for i in (-1, -0.5, 0, 0.5, 1) {
        line((0, i * y-scale), (1.5 * x-scale, i * y-scale))
    }

    set-style(stroke: (thickness: 1.5pt, paint: black))
    line((0, -1 * y-scale), (0, 1 * y-scale))
    line((0, -1 * y-scale), (1.5 * x-scale, -1 * y-scale))
    line((0, 0), (1.5 * x-scale, 0))

    content((rel: (-0.2, 0), to: (0, 1 * y-scale)), anchor: "east")[1.0]
    content((rel: (-0.2, 0), to: (0, 0.5 * y-scale)), anchor: "east")[0.5]
    content((rel: (-0.2, 0), to: (0, 0)), anchor: "east")[0.0]
    content((rel: (-0.2, 0), to: (0, -0.5 * y-scale)), anchor: "east")[$-0.5$]
    content((rel: (-0.2, 0), to: (0, -1 * y-scale)), anchor: "east")[$-1.0$]

    content((0, -1 * y-scale - 0.3), anchor: "north")[0.0]
    content((0.5 * x-scale, -1 * y-scale - 0.3), anchor: "north")[0.5]
    content((1.0 * x-scale, -1 * y-scale - 0.3), anchor: "north")[1.0]
    content((1.5 * x-scale, -1 * y-scale - 0.3), anchor: "north")[1.5]
    content((1.5 * x-scale, -1 * y-scale - 0.3), anchor: "north", padding: (left: 1em))[$s$]

    content((0, 1 * y-scale + 0.3), anchor: "south")[$s(t)$]
    content((1.5 * x-scale + 0.3, -1 * y-scale), anchor: "west")[$t$]

    line(..points, stroke: (paint: rgb("d00000"), thickness: 2pt))
  })
  #v(0.5em)
  #text(weight: "bold")[(a) $A=1, f=1, Phi=0$]
]
]

La variazione dei primi 3 parametri di cui sopra (ampizza, frequenza e fase) permette di rappresentare diversi tipi di segnali.

=== Trasformata di Fourier e utilità
Un'onda elettromagnetica può anche essere osservata considerando un dominio diverso dal tempo: quello delle frequenze. In questo modo, ogni segnale può essere scomposto da una serie di segnali periodici (sinusoidi e/o cosinusoidi) con ampiezza, frequenza e fase diverse. Questa scomposizione è possibile grazie alla Trasformata di Fourier:

$ s(t) = 1/2 c + sum_(n=1)^oo a_n sin(2 pi n f t) + sum_(n=1)^oo b_n cos(2 pi n f t) $

Dove:
- $c ->$ è la costante che rappresenta il valore medio del segnale;
- $a_n, b_n ->$ sono i coefficienti che rappresentano l'ampiezza delle componenti (ovvero le armoniche);
- $f_n ->$ frequenze multiple della frequenza fondamentale.

#nota[
  L'idea alla base della _Trasformata di Fourier_ è che ogni segnale, anche complesso, può essere scomposto nella somma di onde sinusoidali e cosinusoidali più semplici, passando da un dominio all'altro.
]

Un ricevitore deve dunque "tradurre" i segnali che gli arrivano per capire com'è composta l'onda, a partire dall'osservazione di quest'ultima nel tempo. In particolare bisogna determinare le *ampiezze* di ogni componente e la *frequenza* con la quale è opportuno campionare il segnale.

=== Campionamento e Teorema di Nyquist-Shannon
Nel momento in cui un segnale *analogico* arriva ad un ricevitore, quest'ultimo deve necessariamente convertirlo in *digitale*. Per fare ciò, il segnale viene *campionato* ad intervalli regolari di tempo, misurandone l'ampiezza in quei precisi istanti. In questo modo, il segnale continuo viene trasformato in una serie di numeri discreti che rappresentano l'andamento del segnale nel tempo.

Il *Teorema di Nyquist-Shannon* ci dice inoltre la frequenza minima con la quale è necessario campionare un segnale (per poterlo ricostruire senza perdita di informazione): dev'essere almeno il *doppio* della massima frequenza presente nel segnale in ingresso.

#esempio[
  #align(center)[
    #cetz.canvas(length: 0.8cm, {
      import cetz.draw: *

      let x-scale = 6
      let y-scale = 2.5
      
      let points = ()
      let steps = 100
      for i in range(0, steps + 1) {
        let t = i / steps * 1.5
        let val = calc.sin(2 * calc.pi * t)
        points.push((t * x-scale, val * y-scale))
      }

      set-style(stroke: (thickness: 0.5pt, paint: gray))
      for i in (0, 0.5, 1.0, 1.5) {
          line((i * x-scale, -1 * y-scale), (i * x-scale, 1 * y-scale))
      }
      for i in (-1, -0.5, 0, 0.5, 1) {
          line((0, i * y-scale), (1.5 * x-scale, i * y-scale))
      }

      set-style(stroke: (thickness: 1.5pt, paint: black))
      line((0, -1 * y-scale), (0, 1 * y-scale))
      line((0, -1 * y-scale), (1.5 * x-scale, -1 * y-scale))
      line((0, 0), (1.5 * x-scale, 0))

      content((rel: (-0.2, 0), to: (0, 1 * y-scale)), anchor: "east")[1.0]
      content((rel: (-0.2, 0), to: (0, 0.5 * y-scale)), anchor: "east")[0.5]
      content((rel: (-0.2, 0), to: (0, 0)), anchor: "east")[0.0]
      content((rel: (-0.2, 0), to: (0, -0.5 * y-scale)), anchor: "east")[$-0.5$]
      content((rel: (-0.2, 0), to: (0, -1 * y-scale)), anchor: "east")[$-1.0$]

      content((0, -1 * y-scale - 0.3), anchor: "north")[0.0]
      content((0.5 * x-scale, -1 * y-scale - 0.3), anchor: "north")[0.5]
      content((1.0 * x-scale, -1 * y-scale - 0.3), anchor: "north")[1.0]
      content((1.5 * x-scale, -1 * y-scale - 0.3), anchor: "north")[1.5]
      content((1.5 * x-scale, -1 * y-scale - 0.3), anchor: "north", padding: (left: 1em))[$s$]

      content((0, 1 * y-scale + 0.3), anchor: "south")[$s(t)$]
      content((1.5 * x-scale + 0.3, -1 * y-scale), anchor: "west")[$t$]

      line(..points, stroke: (paint: rgb("d00000"), thickness: 2pt))

      for i in range(0, 16) {
        let t = i * 0.1
        if t <= 1.5 {
          let val = calc.sin(2 * calc.pi * t)
          circle((t * x-scale, val * y-scale), radius: 2pt, fill: green, stroke: none)
        }
      }

      for i in range(0, 3) {
        let t = i * 0.7
        if t <= 1.5 {
          let val = calc.sin(2 * calc.pi * t)
          circle((t * x-scale, val * y-scale), radius: 3pt, fill: blue, stroke: none)
        }
      }
    })
    #v(0.5em)
    #text(weight: "bold")[(a) $A=1, f=1, Phi=0$]
  ]

  In verde sono rappresentati i campioni presi con frequenza di campionamento alta (16 campioni in totale, compresi quelli a 0.0 e 1.4 secondi in blu), mentre in blu quelli con frequenza bassa (3 campioni in totale). Come si può notare, con un numero maggiore di campioni è possibile ricostruire perfettamente il segnale originale, mentre con pochi campioni si perde completamente l'andamento del segnale.

  Dal *Teorema di Nyquist-Shannon*, essendo la frequenza massima del segnale pari a 1 `Hz`, sappiamo che la frequenza di campionamento minima dev'essere di almeno 2 `Hz` (ovvero 2 campioni al secondo). Nel caso dei puntini verdi, con 16 campioni in 1.5 secondi, la frequenza di campionamento è di circa 10.67 `Hz` (molto maggiore del minimo richiesto), mentre nel caso dei puntini blu, con 3 campioni in 1.5 secondi, la frequenza di campionamento è di 2 `Hz` (esattamente il minimo richiesto, ma come si può notare non ideale per una ricostruzione del segnale più coerente).
]

=== Passaggi di dominio
Per passare da un dominio all'altro si utilizzano 2 operazioni matematiche:
- *Fast Fourier Transform (FFT)*: Permette di passare dal dominio del tempo a quello delle frequenze. A partire dalla forma d'onda nel tempo, vengono restituite le componenti $a_n$ e $b_n$ (ampiezze delle sinusoidi e cosinoidi che compongono il segnale);

#esempio[
  Un'antenna che riceve un segnale, dapprima converte da analogico a digitale (grazie al _campionamento_) e, in secondo luogo, utilizza la "lista" di numeri generata per applicare la *FFT* e capire quali bit sono stati trasmessi.
  
  Informalmente, possiamo affermare che il ricevitore si chieda quali sinusoidi e cosinusoidi, sommate assieme, potrebbero passare esattamente per i punti campionati. Viene quindi restituita l'ampiezza di ogni frequenza trovata ("Ho trovato tanto segnale a 50 `Hz`, poco a 100 `Hz` e niente a 200 `Hz`").

  Al termine della procedura, il ricevitore sa esattamente quali frequenze sono state trasmesse e con quale ampiezza, potendo così ricostruire i bit originari: se vede un picco sulla frequenza che il trasmettitore usa per il bit `1`, allora sa che quel bit è stato trasmesso come `1`, altrimenti come `0`.
]

#nota[
  Come detto a lezione, il rumore si presenta spesso come un "tappeto basso" su tutte le frequenze, mentre il segnale utile è tipicamente un picco alto e stretto. Nel dominio delle frequenze, il segnale utile dovrebbe quindi essere facilmente isolabile (al contrario, nel dominio del tempo, il rumore deforma l'onda rendendola praticamente illeggibile).
]

- *Inverse Fast Fourier Transform (IFFT)*: Permette di passare dal dominio delle frequenze a quello del tempo. Partendo dalle componenti $a_n$ e $b_n$, viene restituita la forma d'onda nel tempo.

#nota[
  Sostanzialmente è una trasformazione che ha lo scopo opposto di quella trattata poc'anzi: nel momento in cui c'è bisogno di trasmettere e non di ricevere, i dati nell'aria devono viaggiare sotto forma *analogica*, per cui diventa essenziale passare dal dominio delle frequenze a quello del tempo. Senza *IFFT*, il trasmettitore non sarebbe dunque in grado di convertire i bit in un'onda elettromagnetica trasmissibile.
]

Queste trasformazioni sono veri e propri algoritmi implementati direttamente negli hardware dei dispositivi di trasmissione e ricezione (es. antenne Wi-Fi), dovendo essere eseguiti in tempi brevissimi per permettere comunicazioni fluide e senza ritardi percepibili dagli utenti.

Per facilitare la "traduzione" di una forma d'onda, a partire dalla sua trasformata, è possibile utilizzare delle *lookup table*: delle tabelle precompilate che associano ad ogni possibile combinazione di ampiezza e frequenza un particolare bit o sequenza di bit. In questo modo, il ricevitore non deve calcolare ogni volta la trasformata inversa, ma può semplicemente cercare nella tabella il bit corrispondente alla combinazione trovata.

#esempio[
  #align(center)[
    #table(
      columns: (auto, auto),
      inset: 10pt,
      align: (col, row) => (if col == 1 { center } else { left } + horizon),
      stroke: 0.5pt + luma(200),
      fill: (_, row) => if row == 0 { luma(240) } else { white },
      table.header(
        [*Impronta (Valore della Trasformata/FFT)*], [*Significato (Bit)*],
      ),
      [Picco di energia a *100 Hz*], [*00*],
      [Picco di energia a *200 Hz*], [*01*],
      [Picco di energia a *300 Hz*], [*10*],
      [Picco di energia a *400 Hz*], [*11*],
    )
  ]

  Questa tabella contiene un esempio semplificato di ciò che realmente succede e che ricerca un ricevitore: ad ogni picco di energia rilevato in una certa frequenza, viene associata una particolare sequenza di bit e scorre righe e colonne per identificare il bit corrispondente.
]

=== Schema riassuntivo
#align(center)[
  #cetz.canvas(length: 0.9cm, {
    import cetz.draw: *

    let arrow-style = (mark: (end: ">", fill: black), stroke: 0.5pt)
    let label-style = (size: 0.7em)

    content((0, 0), anchor: "west", name: "tx-start")[*Trasm*: Bit]
    content((3.5, 0), anchor: "west", name: "tx-freq")[Frequenze]
    content((6.5, 0), anchor: "west", name: "tx-time")[Tempo (Digitale)]
    content((10.5, 0), anchor: "west", name: "tx-ana")[Analogico]
    content((13.5, 0), anchor: "west", name: "tx-aria")[*\[ARIA\]*]

    line("tx-start.east", "tx-freq.west", ..arrow-style, name: "l1")
    content("l1.mid", anchor: "south", padding: 0.1, text(..label-style)[Mappatura])

    line("tx-freq.east", "tx-time.west", ..arrow-style, name: "l2")
    content("l2.mid", anchor: "south", padding: 0.1, text(..label-style, weight: "bold")[IFFT])

    line("tx-time.east", "tx-ana.west", ..arrow-style)
    line("tx-ana.east", "tx-aria.west", ..arrow-style)

    line((0.2, -0.4), (0.2, -1.6), ..arrow-style)

    content((0, -2), anchor: "west", name: "rx-start")[*Ric*: *\[ARIA\]*]
    content((3.5, -2), anchor: "west", name: "rx-ana")[Analogico]
    content((9.0, -2), anchor: "west", name: "rx-time")[Tempo (Digitale)]
    content((13.0, -2), anchor: "west", name: "rx-freq")[Frequenze]
    content((15.5, -2), anchor: "west", name: "rx-end")[Bit]

    line("rx-start.east", "rx-ana.west", ..arrow-style)

    line("rx-ana.east", "rx-time.west", ..arrow-style, name: "l3")
    content("l3.mid", anchor: "south", padding: 0.1, text(..label-style, weight: "bold")[Campionamento (N.-S.)])

    line("rx-time.east", "rx-freq.west", ..arrow-style, name: "l4")
    content("l4.mid", anchor: "south", padding: 0.1, text(..label-style, weight: "bold")[FFT])

    line("rx-freq.east", "rx-end.west", ..arrow-style)
  })
]

Questo schema riassume i passaggi fondamentali che avvengono durante la trasmissione e la ricezione di un segnale:
- *TRASMETTITORE*:
  - Mappa i bit da inviare in frequenze specifiche;
  - Utilizza l'*IFFT* per convertire le frequenze in un segnale digitale nel dominio del tempo;
  - Converte il segnale *digitale* in *analogico* per poterlo trasmettere attraverso l'aria.

- *RICEVITORE*:
  - Cattura il segnale *analogico* dall'aria;
  - Campiona il segnale *analogico*, secondo il *Teorema di Nyquist-Shannon*, per ottenerne uno *digitale* nel dominio del *tempo*;
  - Applica la *FFT* per ottenere le frequenze presenti nel segnale;
  - Mappa le frequenze trovate nei bit originari.

== Spettro, Bandwidth e Data Rate
Tra i concetti fondamentali per comprendere le prestazioni di un sistema di comunicazione vi sono lo *spettro*, la *larghezza di banda* (o _Bandwidth_) e la *velocità di trasmissione dati* (o _Data Rate_):
- *Spettro* $->$ Rappresenta l'insieme (o il range) di tutte le frequenze elettromagnetiche possibili, suddivise in bande (es. banda AM, banda FM, banda Wi-Fi, ecc.);
- *Bandwidth* $->$ Indica una misura fisica, espressa in `Hz`, che rappresenta la "larghezza del tubo" o lo spazio/ampiezza dello *spettro* delle frequenze che occupa il segnale;
- *Data Rate* $->$ Indica la quantità di dati che possono essere trasmessi in un certo intervallo di tempo, espressa in `bps` (bit per secondo). Rappresenta la velocità effettiva con cui le informazioni vengono trasferite attraverso il canale di comunicazione.

#nota[
  È importante non confondere *Spettro* e *Bandwidth*: lo *spettro* è l'insieme di tutte le frequenze possibili, mentre la *Bandwidth* è una misura specifica della larghezza di banda occupata da un segnale all'interno di quello spettro.

  #esempio[
    Ho un segnale composto da 3 frequenze: 100 `Hz`, 200 `Hz` e 300 `Hz`. Lo *spettro* di questo segnale comprende tutte e 3 le frequenze, mentre la *Bandwidth* è calcolata come la differenza tra la frequenza massima e minima, ovvero 300 `Hz` - 100 `Hz` = 200 `Hz`.
  ]
]

=== Relazione tra Bandwidth e Data Rate
La relazione fondamentale che sussiste tra *Bandwidth* e *Data Rate* è la seguente: per ottenere un *DR* più alto, è necessario disporre di una *BW* maggiore. Questo perché una maggiore larghezza di banda consente di trasmettere più informazioni in un dato intervallo di tempo.

#esempio[
  Supponiamo di avere un'onda quadrata:
  
  #align(center)[
    #cetz.canvas({
      import cetz.draw: *

      let A = 1.5
      let w = 2.0

      line((0, -A - 1.5), (0, A + 1.0), mark: (end: ">", fill: black))
      line((-0.5, 0), (5 * w + 1, 0))
      content((5 * w + 1, 0), anchor: "north-east")[Time]
      content((0, A + 1.0), anchor: "south", align(center)[Amplitude])

      line((-0.1, A), (0.1, A))
      content((-0.2, A), anchor: "east")[A]
      line((-0.1, -A), (0.1, -A))
      content((-0.2, -A), anchor: "east")[$-A$]

      line(
        (0, A), (w, A), (w, -A),
        (2*w, -A), (2*w, A), (3*w, A),
        (3*w, -A), (4*w, -A), (4*w, A),
        (5*w, A), (5*w, 0),
        stroke: (paint: rgb("E00000"), thickness: 2pt)
      )

      content((0.5 * w, A + 0.5))[1]
      content((1.5 * w, A + 0.5))[0]
      content((2.5 * w, A + 0.5))[1]
      content((3.5 * w, A + 0.5))[0]
      content((4.5 * w, A + 0.5))[1]

      line((0, -A - 0.2), (0, -A - 1.2))
      line((2*w, -A - 0.2), (2*w, -A - 1.2))
      line((0, -A - 0.8), (2*w, -A - 0.8), mark: (start: ">", end: ">", fill: black))
      content((w, -A - 0.8), anchor: "north", padding: 0.2)[period = $T = 1/f$]
    })
  ]

  Per ogni periodo, vengono trasmessi 2 bit (1 e 0): questo corrisponde al *Data Rate*. Per inviare questa onda quadra perfetta, sono necessarie infinite frequenze (tutte le armoniche dispari della frequenza fondamentale), il che implica una *Bandwidth* infinita:
  $ s(t) = A dot 4/pi dot sum_(k=1)^oo sin(2 k f t)/k $

  Come è facile intuire, non si ha mai a disposizione una banda infinita, ma è comunque possibile ridurre lo *spettro* per ottenere una buona approssimazione. 

  #align(center)[
    #cetz.canvas({
      import cetz.draw: *

      let x-scale = 3.5
      let y-scale = 1.8
      
      let points = ()
      let steps = 200
      for i in range(0, steps + 1) {
        let t = i / steps * 2.0
        let angle = 2 * calc.pi * t
        let val = (4 / calc.pi) * (calc.sin(angle) + (1/3) * calc.sin(3 * angle) + (1/5) * calc.sin(5 * angle))
        points.push((t * x-scale, val * y-scale))
      }

      set-style(stroke: (thickness: 0.5pt, paint: gray))
      for i in (0.5, 1.0, 1.5, 2.0) {
          line((i * x-scale, -1.2 * y-scale), (i * x-scale, 1.2 * y-scale))
      }
      for i in (-1, -0.5, 0.5, 1) {
          line((0, i * y-scale), (2.0 * x-scale, i * y-scale))
      }

      set-style(stroke: (thickness: 1pt, paint: black))
      line((0, -1.2 * y-scale), (0, 1.2 * y-scale))
      line((0, 0), (2.0 * x-scale, 0))

      content((rel: (-0.2, 0), to: (0, 1 * y-scale)), anchor: "east")[1.0]
      content((rel: (-0.2, 0), to: (0, 0.5 * y-scale)), anchor: "east")[0.5]
      content((rel: (-0.2, 0), to: (0, 0)), anchor: "east")[0.0]
      content((rel: (-0.2, 0), to: (0, -0.5 * y-scale)), anchor: "east")[$-0.5$]
      content((rel: (-0.2, 0), to: (0, -1 * y-scale)), anchor: "east")[$-1.0$]

      content((0, -1.2 * y-scale - 0.2), anchor: "north")[0.0]
      content((0.5 * x-scale, -1.2 * y-scale - 0.2), anchor: "north")[$0.5T$]
      content((1.0 * x-scale, -1.2 * y-scale - 0.2), anchor: "north")[$1.0T$]
      content((1.5 * x-scale, -1.2 * y-scale - 0.2), anchor: "north")[$1.5T$]
      content((2.0 * x-scale, -1.2 * y-scale - 0.2), anchor: "north")[$2.0T$]

      content((1.0 * x-scale, 1.4 * y-scale), text(size: 1.2em)[$f, 3f, 5f arrow.r B = 4f$])

      line(..points, stroke: (paint: rgb("d00000"), thickness: 2pt))
    })
  ]

  In questo esempio è possibile notare come l'onda quadra venga approssimata utilizzando solo le prime 3 armoniche (frequenze: $f$, $3f$ e $5f$), riducendo così la *Bandwidth* a $4f$. L'onda risultante è comunque abbastanza vicina a quella ideale, permettendo di trasmettere i 2 bit per periodo con una *BW* finita.

  Ciò non vieta di allargare ulteriormente la *Bandwidth* per ottenere un'onda ancora più precisa:

  #align(center)[
    #cetz.canvas({
      import cetz.draw: *

      let x-scale = 3.5
      let y-scale = 1.8
      
      let points = ()
      let steps = 300
      for i in range(0, steps + 1) {
        let t = i / steps * 2.0
        let angle = 2 * calc.pi * t
        let val = (4 / calc.pi) * (calc.sin(angle) + (1/3) * calc.sin(3 * angle) + (1/5) * calc.sin(5 * angle) + (1/7) * calc.sin(7 * angle))
        points.push((t * x-scale, val * y-scale))
      }

      set-style(stroke: (thickness: 0.5pt, paint: gray))
      for i in (0.5, 1.0, 1.5, 2.0) {
          line((i * x-scale, -1.2 * y-scale), (i * x-scale, 1.2 * y-scale))
      }
      for i in (-1, -0.5, 0.5, 1) {
          line((0, i * y-scale), (2.0 * x-scale, i * y-scale))
      }

      set-style(stroke: (thickness: 1pt, paint: black))
      line((0, -1.2 * y-scale), (0, 1.2 * y-scale))
      line((0, 0), (2.0 * x-scale, 0))

      content((rel: (-0.2, 0), to: (0, 1 * y-scale)), anchor: "east")[1.0]
      content((rel: (-0.2, 0), to: (0, 0.5 * y-scale)), anchor: "east")[0.5]
      content((rel: (-0.2, 0), to: (0, 0)), anchor: "east")[0.0]
      content((rel: (-0.2, 0), to: (0, -0.5 * y-scale)), anchor: "east")[$-0.5$]
      content((rel: (-0.2, 0), to: (0, -1 * y-scale)), anchor: "east")[$-1.0$]

      content((0, -1.2 * y-scale - 0.2), anchor: "north")[0.0]
      content((0.5 * x-scale, -1.2 * y-scale - 0.2), anchor: "north")[$0.5T$]
      content((1.0 * x-scale, -1.2 * y-scale - 0.2), anchor: "north")[$1.0T$]
      content((1.5 * x-scale, -1.2 * y-scale - 0.2), anchor: "north")[$1.5T$]
      content((2.0 * x-scale, -1.2 * y-scale - 0.2), anchor: "north")[$2.0T$]

      content((1.0 * x-scale, 1.4 * y-scale), text(size: 1.2em)[$f, 3f, 5f, 7f arrow.r B = 6f$])

      line(..points, stroke: (paint: rgb("d00000"), thickness: 2pt))
    })
  ]

  In questo caso, aggiungendo la quarta armonica ($7f$), la *Bandwidth* sale a $6f$ e l'onda quadra risulta ancora più precisa, migliorando la qualità della trasmissione dei dati.

  #align(center)[
    #set text(size: 9pt)
    #table(
      columns: (auto, 1fr, 1fr),
      inset: 6pt,
      align: (col, row) => (if col == 0 { left } else { center } + horizon),
      stroke: 0.5pt + luma(200),
      fill: (_, row) => if row == 0 { luma(240) } else { white },
      
      [*Frequenza fondamentale ($f$)*], [*1 MHz*], [*2 MHz*],
      
      [Spettro], [1 MHz -- 5 MHz], [2 MHz -- 10 MHz],
      
      [Periodo ($T$)], [1 $mu$s], [0.5 $mu$s],
      
      [Durata di 1 bit], [0.5 $mu$s], [0.25 $mu$s],
      
      [Bandwidth ($B$)], [4 MHz ($5f - f$)], [8 MHz ($2 dot (5f - f)$)],
      
      [Data rate (bps)], [2 Mbps (2 bit ogni $mu$s)], [4 Mbps (4 bit ogni $mu$s)]
    )
  ]

  È possibile evincere che, raddoppiando della *Bandwidth*, anche il *Data Rate* fa lo stesso.
]

=== Capacità del canale, Rumore e Tasso di errore
Altre definizioni importanti per comprendere al meglio le prestazioni di un sistema di comunicazione:
- *Capacità del canale* (o _Channel Capacity_) $->$ Rappresenta il massimo *Data Rate* al quale è possibile trasmettere dati attraverso un canale di comunicazione;
- *Rumore* (o _Noise_) $->$ Indica qualsiasi interferenza o disturbo non voluto che può alterare il segnale durante la trasmissione, rendendo difficile la corretta ricezione dei dati;
- *Tasso di errore* (o _Error Rate_) $->$ Rappresenta quante volte viene modificato il segnale in maniera non volontaria a livello di numero di bit.

== Teorema di Nyquist sulla banda
Ipotizzando di avere a disposizione un canale privo di rumore, la larghezza di banda (*Bandwidth*) $B$ limita il *Data Rate*. Il massimo di informazioni che è possibile trasmettere attraverso un canale senza errori è quindi dato dalla seguente formula:
$ C = 2B $

Questo vale per segnali binari a 2 livelli di voltaggio. Per segnali multilivello (con $M$ livelli di voltaggio), la formula diventa:
$ C = 2B log_2(M) $
Dove $M$ è il numero di livelli di voltaggio e $log_2(M)$ indica quanti bit corrispondono a ciascun livello.

#nota[
  Aumentre i livelli di voltaggio è essenziale per incrementare il *Data Rate* senza dover aumentare la *Bandwidth*, che spesso è limitata dalle caratteristiche fisiche del canale di comunicazione.
  #esempio[
    Supponiamo di avere una larghezza di banda di 1000 `Hz`:
    - Avendo un numero di livello di voltaggio $M = 2$, la capacità del canale è \ 
      $C = 2 dot 1000 dot log_2(2) = 2000$ `bps`;
    - Avendo un numero di livello di voltaggio $M = 8$, la capacità del canale diventa \
      $C = 2 dot 1000 dot log_2(8) = 6000$ `bps`.
  ]
]

== Il rumore 
Come già detto precedentemente, il *rumore* (chiamato spesso anche _noise_), è un segnale non voluto che si combina al segnale trasmesso, distorcendolo. Questo può portare a errori nella ricezione dei dati, poiché il ricevitore potrebbe interpretare erroneamente i bit trasmessi.

Possiamo inoltre categorizzare il *rumore*:
- *_Thernmal Noise_* $->$ Rumore di fondo *inevitabile e non eliminabile*. Deriva dall'agitazione termica delle particelle nei materiali conduttori e si manifesta come un segnale casuale che si somma al segnale utile (informalmente, è il fruscio che si può sentire, ad esempio, nelle radio non sintonizzate);
- *_Intermodulation Noise_* $->$ Rumore *non naturale*. È tipicamente causato da un malfunzionamento del sistema di trasmissione. Si verifica quando 2 frequenze viaggiano nello stesso mezzo (ad esempio, un cavo condiviso) e passano attraverso un componente non lineare (es. un amplificatore difettoso), generando nuove frequenze che interferiscono con il segnale originale;
- *_Crosstalk_* $->$ Rumore causato da *interferenze tra canali* di comunicazione vicini. Si verifica quando, ad esempio, 2 cavi in rame corrono paralleli lungo un tratto.
- *Impulse Noise* $->$ Rumore *improvviso e di breve durata*. È causato da eventi esterni come fulmini, interruzioni di corrente o interferenze elettromagnetiche. Può causare errori significativi nella trasmissione dei dati, specialmente in sistemi digitali. È particolarmente importante come tipo di rumore, poiché ha la capacità di cancellare o invertire un intero gruppo di bit, rendendo tutto il pacchetto illeggibile.

=== Grandezze fondamentali
Appurato il concetto di *rumore* e le varie tipologie che possono potenzialmente intaccare una comunicazione, è importante definire ulteriori grandezze fondamentali che verranno trattate durante il corso:

==== Decibel (dB):
È la "_misura del cambiamento_". È il rapporto fra 2 potenze, espresso in scala logaritmica:
$ d B = 10 dot log_10(P_f/P_i) $

Dove $P_f$ è la potenza finale e $P_i$ è la potenza iniziale.

Ci interessa sapere la misura di differenza relativa a quanto il segnale sia diventato più grande (guadagno) o più piccolo (attenuazione) rispetto a prima.

#nota[
  Per il *Decibel* tendendzialmente si interpreta il risultato utilizzando la regola del ±3:
  - -3 $->$ La potenza si è dimezzata;
  - +3 $->$ La potenza è raddoppiata.
]

==== Decibel-Milliwatt (dBm):
Si tratta di una *misura assoluta*: ci dice esattamente quanta potenza abbiamo in mano e, per farlo, fissa come riferimento 1 `mW` (milliwatt):
$ d B m = 10 dot log_10(P/(1 m W)) $
Dove $P$ è la potenza misurata.

#nota[
  Interpretazione del risultato:
  - 0 `dBm` $->$ Esattamente 1 `mW`;
  - 3 `dBm` $->$ Potenza raddoppiata rispetto a 1 `mW`;
  - -3 `dBm` $->$ Potenza dimezzata rispetto a 1 `mW`.
]

==== Rapporto Segnale-Rumore (SNR):
Misura quanto il segnale utile è più forte rispetto al rumore di fondo. Si esprime in *Decibel*:
$ S N R = 10 dot log_10(P_s/P_n) $
Dove $P_s$ è la potenza del segnale e $P_n$ è la potenza del rumore.

Tanto più è alto, maggiore sarà la distinzione del segnale rispetto al rumore (e viceversa).

=== Shannon Capacity Formula:
$ C = B dot log_2(1 + S N R) $

Questa formula fornisce il valore relativo al massimo numero di bit al secondo ($C$) che possono essere trasmessi attraverso un canale con larghezza di banda $B$ e rapporto segnale-rumore $S N R$. 

È una grandezza teorica intuita da Shannon, che, a differenza di ciò che formalizzò Nyquist, ci dice che è possibile avere una *massima teorica* di trasmissione (senza errori), considerando anche il rumore e sapendo che la capacità dipende dalla *larghezza di banda* e dal *rapporto segnale-rumore* ($S N R$).

Da questa formula è inoltre possibile intuire che, in una determinata condizione di rumore ($S N R$), è possibile aumentare il *Data Rate* in 2 modi distinti:
- Aumentando la *Bandwidth* ($B$), rischiando di aumentare però di aumentare il rumore termico;
- Migliorando il *SNR* (ad esempio, aumentando la potenza del segnale trasmesso), con il rischio di far aumentare *Intermodulation* e *Cross Talk Noise*.

#esempio[
  Supponiamo di avere uno spettro tra $3$ `MHz` e $4$ `MHz`. Abbiamo inoltre un rapporto segnale-rumore $S N R = 24$ `dB`.

  A questo punto, è possibile calcolare la *Capacità* secondo Shannon:
  - Calcoliamo la *Bandwidth*:
    $ B = 4 M H z - 3 M H z = 1 M H z $
  - Convertiamo il *SNR* da *Decibel* a rapporto di potenze:
    $ S N R = 10 log_10(S N R) = 10 log_10(24) = 251 $
    Significa che il segnale è circa 251 volte più potente del rumore.
  - Applichiamo la *formula di Shannon*:
    $ C = B dot log_2(1 + S N R) = 1 M H z dot log_2(1 + 251) = 1 M H z dot 8.0 = 8.0 M b p s $
  - Ora è possibile applicare anche la *formula di Nyquist* per sapere quanti livelli di voltaggio sono necessari per raggiungere questa capacità ($M$ è l'incognita):
    $ C = 2 B log_2(M)  => $
    $ => 8.0 M b p s = 2 dot 1 M H z dot log_2(M) => $
    $ => log_2(M) = 4.0 => $
    $ => M = 2^4 = 16 $
]

== Multiplexing
