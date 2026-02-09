#import "../template.typ": *

== Lezione 6

=== Problema del terminale nascosto

Per capire il concetto alla base del problema, immaginiamo il seguente scenario:

#figure(
  image("/assets/terminale_nascosto.png", width: 40%),
  caption: [Schema del problema.],
)

Prendiamo come esempi il teminale *A* e *D*: in base al raggio di copertura, non possono in alcun modo sentirsi. Se entrambi volessero trasmettere verso *B*, vedrebbero contemporaneamente il canale libero (_Carrier Sense_) e causerebbero una collisione:

#figure(
  align(center)[
    #box(width: 100%, height: 180pt, {
      let light-blue = rgb("#BFEFFF")
      let frame-green = rgb("#88CC66")
      let frame-blue = rgb("#00BFFF")
      let check-green = rgb("#008800")
      let expl-red = rgb("#FF0000")
      
      let draw-check(x, y) = {
        place(dx: x, dy: y, path(stroke: 2pt + check-green, (0pt, 0pt), (4pt, 4pt), (12pt, -8pt)))
      }

      let y-a = 40pt
      let y-b = 90pt
      let y-d = 140pt
      
      let h-bar = 18pt
      let w-difs = 80pt
      let w-frame = 80pt
      let x-start-a = 30pt
      let x-frame-a = x-start-a + w-difs
      let shift-d = 50pt
      let x-start-d = x-start-a + shift-d
      let x-frame-d = x-start-d + w-difs

      place(dx: 5pt, dy: y-a, text(weight: "bold", size: 12pt)[A])
      place(dx: 25pt, dy: y-a + h-bar, line(length: 280pt, stroke: 1.5pt + black))

      place(dx: x-start-a, dy: y-a, rect(width: w-difs, height: h-bar, fill: light-blue, stroke: none))
      place(dx: x-start-a, dy: y-a - 5pt, line(start: (0pt, 0pt), end: (0pt, h-bar + 5pt), stroke: 1.5pt + frame-blue))
      place(dx: x-start-a + w-difs, dy: y-a - 5pt, line(start: (0pt, 0pt), end: (0pt, h-bar + 5pt), stroke: 1.5pt + frame-blue))
      place(dx: x-start-a, dy: y-a - 12pt, block(width: w-difs, align(center, text(size: 8pt)[DIFS])))
      place(dx: x-start-a, dy: y-a + 4pt, block(width: w-difs, align(center, text(size: 6pt)[Carrier Sense])))
      
      place(dx: x-frame-a, dy: y-a, rect(width: w-frame, height: h-bar, fill: frame-green, stroke: none))
      place(dx: x-frame-a, dy: y-a + 4pt, block(width: w-frame, align(center, text(size: 8pt)[Frame A$->$B])))

      draw-check(x-start-a - 5pt, y-a + h-bar + 2pt)
      draw-check(x-frame-a - 5pt, y-a + h-bar + 2pt)

      place(dx: 5pt, dy: y-b, text(weight: "bold", size: 12pt)[B])
      place(dx: 25pt, dy: y-b + h-bar, line(length: 280pt, stroke: 1.5pt + black))

      place(dx: x-frame-a, dy: y-b + 5pt, rect(width: w-frame, height: h-bar, fill: frame-green, stroke: none))
      place(dx: x-frame-a, dy: y-b + 9pt, block(width: w-frame, align(center, text(size: 8pt)[Frame A$->$B])))

      place(dx: x-frame-d, dy: y-b - 5pt, rect(width: w-frame, height: h-bar, fill: frame-blue, stroke: none))
      place(dx: x-frame-d, dy: y-b - 1pt, block(width: w-frame, align(center, text(size: 8pt)[Frame D$->$B])))

      let ex-x = x-frame-d + 15pt
      let ex-y = y-b + 8pt
      place(dx: ex-x, dy: ex-y, polygon(
        fill: expl-red, stroke: 0.5pt + black,
        (0pt, -10pt), (5pt, -5pt), (12pt, -12pt), (8pt, -2pt), 
        (18pt, 0pt), (8pt, 5pt), (15pt, 12pt), (3pt, 8pt), 
        (0pt, 18pt), (-3pt, 8pt), (-12pt, 15pt), (-6pt, 3pt),
        (-18pt, 0pt), (-8pt, -3pt), (-15pt, -10pt), (-4pt, -6pt)
      ))

      place(dx: 5pt, dy: y-d, text(weight: "bold", size: 12pt)[D])
      place(dx: 25pt, dy: y-d + h-bar, line(length: 280pt, stroke: 1.5pt + black))

      place(dx: x-start-d, dy: y-d, rect(width: w-difs, height: h-bar, fill: light-blue, stroke: none))
      place(dx: x-start-d, dy: y-d - 5pt, line(start: (0pt, 0pt), end: (0pt, h-bar + 5pt), stroke: 1.5pt + frame-blue))
      place(dx: x-start-d + w-difs, dy: y-d - 5pt, line(start: (0pt, 0pt), end: (0pt, h-bar + 5pt), stroke: 1.5pt + frame-blue))
      place(dx: x-start-d, dy: y-d - 12pt, block(width: w-difs, align(center, text(size: 8pt)[DIFS])))
      place(dx: x-start-d, dy: y-d + 4pt, block(width: w-difs, align(center, text(size: 6pt)[Carrier Sense])))

      place(dx: x-frame-d, dy: y-d, rect(width: w-frame, height: h-bar, fill: frame-blue, stroke: none))
      place(dx: x-frame-d, dy: y-d + 4pt, block(width: w-frame, align(center, text(size: 8pt)[Frame D$->$B])))

      draw-check(x-start-d - 5pt, y-d + h-bar + 2pt)
      draw-check(x-frame-d - 5pt, y-d + h-bar + 2pt)
    })
  ]
)

La soluzione a questo problema risiede nell'invio di una *Request to Send (RTS)*, da parte di chi vuole trasmettere (il _sender_), verso *tutti* i terminali presenti nel proprio raggio di copertura. Questa richiesta contiene l'indirizzo della sorgente e della destinazione, la durata stimata dell'*RTS* stesso e un _ack_ finale. 

I terminali ai quali non è destinata la richiesta, scartano l'*RTS* e allocano un *Network Allocation Vector (NAV)*, che corrisponde a un tempo in cui sanno di non poter trasmettere (questo tempo viene stimato sulla base delle informazioni raccolte prima di scartare la *Request to Send*).

Il destinatario risponderà, nel caso in cui fosse libero, con un *Clear to Send CTS*, che al suo interno contiene indirizzo di sorgente e destinazione e il tempo rimanente fino al termine della trasmissione. Questo tempo viene calcolato, partendo dalla stima contenuta nell'*RTS* e sottraendogli il tempo passato per "trovare" la destinazione.

Dopo che il *CTS* viene ricevuto da tutti i terminali nel raggio del destinatario, questi ultimi riallocheranno un *NAV* per il tempo indicato nel *CTS*. Questo serve a far sapere a tutti che un altro nodo, all'esterno, vuole comunicare con il terminale destinatario.

Lo schema è il seguente:

#figure(
  align(center)[
    #box(width: 100%, height: 220pt, {
      let c-sense = rgb("#BFEFFF")
      let c-rts = rgb("#FFCC00")
      let c-frame = rgb("#00BFFF")
      let c-cts = rgb("#99FF66")
      let c-nav = rgb("#CCCCCC")
      let c-check = rgb("#008800")
      let bar-h = 20pt
      let arrow-end = 460pt
      
      let draw-check(x, y) = {
        place(dx: x, dy: y, path(stroke: 2pt + c-check, (0pt, 0pt), (4pt, 4pt), (12pt, -8pt)))
      }

      let draw-timeline(y, lab) = {
        place(dx: 0pt, dy: y, text(weight: "bold", size: 12pt)[#lab])
        place(dx: 30pt, dy: y + 8pt, line(start: (0pt, 0pt), end: (arrow-end, 0pt), stroke: 1.5pt + black))
        place(dx: 30pt + arrow-end, dy: y + 8pt, polygon(fill: black, (0pt, 0pt), (-4pt, 3pt), (-4pt, -3pt)))
      }

      let y-a = 30pt
      let y-b = 80pt
      let y-c = 130pt
      let y-d = 170pt

      draw-timeline(y-a, "A")
      
      let x-difs = 50pt
      let w-difs = 80pt
      place(dx: x-difs, dy: y-a - 10pt, rect(width: w-difs, height: bar-h, fill: c-sense, stroke: none))
      place(dx: x-difs, dy: y-a - 15pt, line(start: (0pt, 0pt), end: (0pt, bar-h + 5pt), stroke: 2pt + c-frame))
      place(dx: x-difs + w-difs, dy: y-a - 15pt, line(start: (0pt, 0pt), end: (0pt, bar-h + 5pt), stroke: 2pt + c-frame))
      place(dx: x-difs, dy: y-a - 22pt, block(width: w-difs, align(center, text(size: 10pt)[DIFS])))
      place(dx: x-difs, dy: y-a - 6pt, block(width: w-difs, align(center, text(size: 7pt)[Carrier Sense])))
      draw-check(x-difs - 5pt, y-a + 12pt)
      draw-check(x-difs + w-difs - 5pt, y-a + 12pt)

      let x-rts = x-difs + w-difs
      let w-rts = 50pt
      place(dx: x-rts, dy: y-a - 10pt, rect(width: w-rts, height: bar-h, fill: c-rts, stroke: 0.5pt + black))
      place(dx: x-rts, dy: y-a - 5pt, block(width: w-rts, align(center, text(size: 8pt)[RTS A$->$B])))

      let x-sifs1 = x-rts + 15pt
      let w-sifs1 = 40pt
      place(dx: x-sifs1, dy: y-a - 22pt, block(width: w-sifs1, align(center, text(size: 10pt)[SIFS]))) 

      let x-sense2 = x-sifs1 + w-sifs1 + 50pt 
      let w-sense2 = 40pt
      place(dx: x-sense2, dy: y-a - 10pt, rect(width: w-sense2, height: bar-h, fill: c-sense, stroke: none))
      place(dx: x-sense2, dy: y-a - 15pt, line(start: (0pt, 0pt), end: (0pt, bar-h + 5pt), stroke: 2pt + c-frame))
      place(dx: x-sense2 + w-sense2, dy: y-a - 15pt, line(start: (0pt, 0pt), end: (0pt, bar-h + 5pt), stroke: 2pt + c-frame))
      place(dx: x-sense2, dy: y-a - 22pt, block(width: w-sense2, align(center, text(size: 10pt)[SIFS])))
      place(dx: x-sense2, dy: y-a - 6pt, block(width: w-sense2, align(center, text(size: 6pt)[Carrier Sense])))

      let x-frame = x-sense2 + w-sense2
      let w-frame = 80pt
      place(dx: x-frame, dy: y-a - 10pt, rect(width: w-frame, height: bar-h, fill: c-frame, stroke: 0.5pt + black))
      place(dx: x-frame, dy: y-a - 5pt, block(width: w-frame, align(center, text(size: 9pt)[FRAME A$->$B])))
      place(dx: x-frame + w-frame + 10pt, dy: y-a - 22pt, text(size: 10pt)[SIFS])

      draw-timeline(y-b, "B")

      let x-sense-b = x-rts + 15pt
      let w-sense-b = 40pt
      place(dx: x-sense-b, dy: y-b - 10pt, rect(width: w-sense-b, height: bar-h, fill: c-sense, stroke: none))
      place(dx: x-sense-b, dy: y-b - 15pt, line(start: (0pt, 0pt), end: (0pt, bar-h + 5pt), stroke: 2pt + c-frame))
      place(dx: x-sense-b + w-sense-b, dy: y-b - 15pt, line(start: (0pt, 0pt), end: (0pt, bar-h + 5pt), stroke: 2pt + c-frame))
      place(dx: x-sense-b, dy: y-b - 22pt, block(width: w-sense-b, align(center, text(size: 10pt)[SIFS])))
      place(dx: x-sense-b, dy: y-b - 6pt, block(width: w-sense-b, align(center, text(size: 6pt)[Carrier Sense])))
      draw-check(x-sense-b - 5pt, y-b + 12pt)
      draw-check(x-sense-b + w-sense-b - 5pt, y-b + 12pt)

      let x-cts = x-sense-b + w-sense-b
      let w-cts = 50pt
      place(dx: x-cts, dy: y-b - 10pt, rect(width: w-cts, height: bar-h, fill: c-cts, stroke: 0.5pt + black))
      place(dx: x-cts, dy: y-b - 5pt, block(width: w-cts, align(center, text(size: 8pt)[CTS B$->$A])))

      let x-ack = x-frame + w-frame + 20pt
      let w-ack = 40pt
      place(dx: x-ack, dy: y-b - 10pt, rect(width: w-ack, height: bar-h, fill: c-frame, stroke: 0.5pt + black))
      place(dx: x-ack, dy: y-b - 5pt, block(width: w-ack, align(center, text(size: 9pt)[ACK])))

      draw-timeline(y-c, "C/E")
      let x-nav-rts = x-rts + w-rts
      let w-nav-rts = x-ack + w-ack - x-nav-rts
      place(dx: x-nav-rts, dy: y-c - 10pt, rect(width: w-nav-rts, height: bar-h, fill: c-nav, stroke: 0.5pt + black))
      place(dx: x-nav-rts, dy: y-c - 5pt, block(width: w-nav-rts, align(center, text(size: 10pt)[NAV- RTS])))

      draw-timeline(y-d, "D/F")
      let x-nav-cts = x-cts + w-cts
      let w-nav-cts = x-ack + w-ack - x-nav-cts
      place(dx: x-nav-cts, dy: y-d - 10pt, rect(width: w-nav-cts, height: bar-h, fill: c-nav, stroke: 0.5pt + black))
      place(dx: x-nav-cts, dy: y-d - 5pt, block(width: w-nav-cts, align(center, text(size: 10pt)[NAV- CTS])))

    })
  ]
)

