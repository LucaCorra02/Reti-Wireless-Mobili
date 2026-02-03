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

 