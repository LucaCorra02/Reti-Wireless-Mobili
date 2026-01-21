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

  In verde sono rappresentati i campioni presi con frequenza di campionamento alta (16 campioni in totale), mentre in blu quelli con frequenza bassa (3 campioni in totale). Come si può notare, con un numero maggiore di campioni è possibile ricostruire perfettamente il segnale originale, mentre con pochi campioni si perde completamente l'andamento del segnale.

  Dal *Teorema di Nyquist-Shannon*, essendo la frequenza massima del segnale pari a 1 `Hz`, la frequenza di campionamento minima dev'essere di almeno 2 `Hz` (ovvero 2 campioni al secondo). Nel primo caso, con 16 campioni in 1.5 secondi, la frequenza di campionamento è di circa 10.67 `Hz` (molto maggiore del minimo richiesto), mentre nel secondo caso, con 3 campioni in 1.5 secondi, la frequenza di campionamento è di 2 `Hz` (esattamente il minimo richiesto).
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

