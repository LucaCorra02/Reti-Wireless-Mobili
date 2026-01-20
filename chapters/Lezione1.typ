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
  #cetz.canvas({
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

Dall'esempio riportato in figura, è possibile notare l'ampiezza del segnale (asse `Y`) e come varia nel tempo (asse `X`).
Un esempio pratico di _segnale analogico_ è la voce umana, che varia in modo continuo nel tempo: esiste in ogni singolo istante e non ci sono "buchi" se la misuriamo tra 1 e 2 secondi.

- *Digitale*: Mantenimento costante, all'interno di un range temporale, del livello di segnale. Il cambio di livello avviene in modo istantaneo (discontinuo).

#align(center)[
  #cetz.canvas({
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

Ciò che fanno *trasmettitore* e *ricevitore* è passare da una forma d'onda all'altra.

== Rappresentazione dei segnali
Ogni segnale è rappresentabile come una funzione del tempo `s(t)`, dove `t` è il tempo e `s` l'ampiezza del segnale in quel preciso istante:

$ s(t) = A dot sin(2 pi f t + Phi) $

Dove:
- $A ->$ è l'ampiezza del segnale (massimo valore raggiungibile sull'asse `X`, misurato in Volt);
- $f ->$ è la frequenza del segnale (numero di cicli al secondo, misurata in Hz);
- $Phi ->$ è la fase del segnale (spostamento orizzontale della sinusoide);
- $T ->$ è il periodo del segnale (il tempo impiegato per un ciclo, corrispondente a $1/f$);
- $lambda ->$ Lunghezza d'onda (distanza tra due picchi consecutivi della sinusoide: $lambda = c/f$ oppure $lambda = c T$, dove $c$ è la velocità della luce $c = 3 \cdot 10^8 m\/s$).

#esempio[
  #align(center)[
  #cetz.canvas({
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
    content((1.5 * x-scale, -1 * y-scale - 0.3), anchor: "north", padding: (left: 1em))

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
Un'onda elettromagnetica può anche essere osservata considerando un dominio diverso dal tempo: quello delle frequenze. In questo modo, ogni segnale può essere scomposto da una serie di segnali periodici (sinusoidi come seno e coseno) con ampiezza, frequenza e fase diverse. Questa scomposizione è possibile grazie alla Trasformata di Fourier:

$ s(t) = 1/2 c + sum_(n=1)^oo a_n sin(2 pi n f t) + sum_(n=1)^oo b_n cos(2 pi f_n t) $

Dove:
- $c ->$ è la costante che rappresenta il valore medio del segnale;
- $a_n, b_n ->$ sono i coefficienti che rappresentano l'ampiezza delle componenti (ovvero le armoniche);
- $f_n ->$ frequenze multiple della frequenza fondamentale.

