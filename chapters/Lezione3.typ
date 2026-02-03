#import "../template.typ": *

= Lezione 3

== Orthogonal Frequency Division Multiplexing (OFDM)
L'*OFDM* è un concetto di modulazione che tenta di risolvere il problema principale del *Frequency Division Multiplexing* (FDM), ovvero l'inefficienza spettrale dovuta alla necessità di inserire delle *guard bands* tra le diverse portanti per evitare interferenze.

#esempio[
  Informalmente, possiamo immaginare il *FDM* come un'autostrada (_banda_) in cui ogni macchinna (che rappresenta il _segnale_) viaggia in una corsia separata (_portante_). Per evitare incidenti (interferenze), è necessario lasciare delle corsie vuote (_guard bands_) tra le corsie occupate, il che riduce l'efficienza dell'autostrada.

  Questo bisogno degli _guard bands_ è necessario per evitare che le frequenze/auto delle diverse portanti si sovrappongano, causando interferenze e degradando la qualità del segnale ricevuto.
]

L'*OFDM* è una sorta di _"incastro perfetto"_: non si spreca spazio con le _guard bands_, ma si fa in modo che le portanti si sovrappongano in modo controllato e *ortogonale*, minimizzando le interferenze.

#figure(
  align(center)[
    #cetz.canvas(length: 1.2cm, {
      import cetz.draw: *

      let w = 6
      let h = 0.8
      let rows = 5
      let bits = ("1", "0", "0", "1", "0")
      let freqs = ($f_(-2)$, $f_(-1)$, $f_0$, $f_1$, $f_2$)
      let brace-col = rgb("#00BFFF")

      line((0, 0), (0, rows * h + 0.5), mark: (end: ">", fill: black))
      content((-1.3, rows * h / 2), text(size: 1.1em)[Frequenze], angle: 90deg)

      line((0, 0), (w + 0.5, 0), mark: (end: ">", fill: black))
      content((w / 2, -0.4), text(size: 1.1em)[Tempo])
      content((w, -0.4), [1 sec])

      for i in range(rows) {
        let y = i * h
        rect((0, y), (w, y + h), stroke: 1pt)
        content((w / 2, y + h / 2), text(weight: "bold")[#bits.at(i)])
        content((-0.5, y + h / 2), freqs.at(i))
      }

      let bx = w + 0.6
      let by_top = rows * h
      let by_mid = by_top / 2
      let bw = 0.2

      line(
        (bx, 0), (bx + bw, 0), 
        (bx + bw, by_mid - 0.1), 
        (bx + bw + 0.15, by_mid),
        (bx + bw, by_mid + 0.1),
        (bx + bw, by_top),
        (bx, by_top),
        stroke: (paint: brace-col, thickness: 1.5pt)
      )

      content((bx + bw + 0.8, by_mid), text(fill: brace-col, size: 1.2em)[$N f_b$])
    })
  ]
)

#figure(
  image("/assets/OFDM.png", width: 40%),
  caption: [Schema dell'Orthogonal Frequency Division Multiplexing.],
)

#nota[
  A sinistra, possiamo vedere il "_flusso veloce_" $"R"_("bps")$, che corrisponde al flusso in entrata ad alta velocità (ad esempio, un video in streaming). Il problema nasce dal fatto che, se si provasse a trasmettere questo flusso così com'è e su una singola portante (es. canale largo $20"Mhz"$ con un solo segnale, di quasi $20"Mhz"$, usato per trasportare tutto), si rischierebbe di incorrere in problemi di interferenza e degrado del segnale a causa delle caratteristiche del canale wireless (ad esempio, fading, interferenze, ecc.).

  C'è poi un *convertitore* da seriale a parallelo, con lo scopo di far viaggiare il flusso di dati su più portanti in parallelo, riducendo così la velocità di trasmissione su ciascuna portante e mitigando gli effetti negativi del canale wireless.

  Infine, a destra, vediamo il "_flusso lento_" $"R/N"_("bps")$, che rappresenta il flusso di dati su ciascuna portante dopo la conversione da seriale a parallelo. Ogni portante trasmette una frazione del flusso totale, riducendo la velocità di trasmissione e migliorando la robustezza del segnale contro le interferenze e il fading.
] 

=== L'ortogonalità delle portanti
L'ortogonalità permette di sovrapporre le portanti in modo che, nonostante si intersechino nello spettro delle frequenze, non interferiscano tra loro. Questo è possibile grazie a una particolare scelta delle frequenze delle portanti e alla loro modulazione:

#figure(
  align(center)[
    #box(width: 320pt, height: 180pt, {
      let axis-y = 150pt
      let origin-x = 20pt
      let scale-x = 45pt
      let scale-y = 90pt
      
      let f1 = origin-x + 2 * scale-x
      let f2 = origin-x + 3 * scale-x
      let f3 = origin-x + 4 * scale-x

      let get-points(center-x) = {
        let points = ()
        for i in range(0, 300) { 
           let x = origin-x + i * 1pt
           let rel-x = (x - center-x) / scale-x * calc.pi
           let y-val = 0
           if rel-x == 0 { y-val = 1 } else { y-val = calc.sin(rel-x) / rel-x }
           points.push((x, axis-y - y-val * scale-y)) 
        }
        return points
      }

      place(line(start: (f1, axis-y), end: (f1, axis-y - scale-y), stroke: (thickness: 0.5pt, dash: "dashed", paint: black)))
      place(line(start: (f2, axis-y), end: (f2, axis-y - scale-y), stroke: (thickness: 0.5pt, dash: "dashed", paint: black)))
      place(line(start: (f3, axis-y), end: (f3, axis-y - scale-y), stroke: (thickness: 0.5pt, dash: "dashed", paint: black)))

      place(line(start: (origin-x, axis-y), end: (300pt, axis-y), stroke: 1pt + black))
      place(polygon(fill: black, (300pt, axis-y - 2pt), (300pt, axis-y + 2pt), (305pt, axis-y)))

      place(line(start: (origin-x, axis-y), end: (origin-x, 10pt), stroke: 1pt + black))
      place(polygon(fill: black, (origin-x - 2pt, 10pt), (origin-x + 2pt, 10pt), (origin-x, 5pt)))

      place(dx: 310pt, dy: axis-y - 2pt, text(size: 9pt, $f$))
      place(dx: origin-x - 5pt, dy: 0pt, text(size: 9pt, $S(f)$))

      place(path(..get-points(f3), stroke: (thickness: 1.2pt, paint: rgb("#009E73"))))
      place(path(..get-points(f1), stroke: (thickness: 1.2pt, paint: rgb("#D55E00"))))
      place(path(..get-points(f2), stroke: (thickness: 1.2pt, paint: rgb("#0072B2"), dash: "dashed")))

      place(dx: f1 - 5pt, dy: axis-y + 6pt, text(size: 8pt, $f_b$))
      place(dx: f2 - 8pt, dy: axis-y + 6pt, text(size: 8pt, $2f_b$))
      place(dx: f3 - 8pt, dy: axis-y + 6pt, text(size: 8pt, $3f_b$))
    })
  ]
)

#nota[
  La scelta della sotto-portante $f_b$ è dettata dalla durata $T$ dei simboli:
  $
    f_b = 1/T
  $
]

Come si evince dal grafico, tutti i segnali multipli di $f_b$ sono *ortogonali* fra loro: ogni campana colorata rappresenta una sotto-portante (ovvero le onde che trasportano i dati), in cui vi è un allineamento preciso di picchi e zeri. 

Prendendo come spunto la curva #text(fill: red)[rossa], in particolare nel punto esatto in cui presenta un picco, è possibile osservare come le altre curve, #text(fill: blue)[blu] e #text(fill: green)[verde], passino esattamente da zero in quell'istante.

In sintesi, la precisione matematica $Delta f = 1/T$ è il cuore di tutto e permette dunque di far corrispondere a un picco di una sotto-portante al nullo delle altre.

