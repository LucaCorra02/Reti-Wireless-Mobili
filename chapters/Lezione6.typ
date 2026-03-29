#import "../template.typ": *

== Problema del terminale nascosto

Per capire il concetto alla base del problema, immaginiamo il seguente scenario:

#figure(
  image("/assets/terminale_nascosto.png", width: 60%),
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
      place(dx: x-start-a + w-difs, dy: y-a - 5pt, line(
        start: (0pt, 0pt),
        end: (0pt, h-bar + 5pt),
        stroke: 1.5pt + frame-blue,
      ))
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
        fill: expl-red,
        stroke: 0.5pt + black,
        (0pt, -10pt),
        (5pt, -5pt),
        (12pt, -12pt),
        (8pt, -2pt),
        (18pt, 0pt),
        (8pt, 5pt),
        (15pt, 12pt),
        (3pt, 8pt),
        (0pt, 18pt),
        (-3pt, 8pt),
        (-12pt, 15pt),
        (-6pt, 3pt),
        (-18pt, 0pt),
        (-8pt, -3pt),
        (-15pt, -10pt),
        (-4pt, -6pt),
      ))

      place(dx: 5pt, dy: y-d, text(weight: "bold", size: 12pt)[D])
      place(dx: 25pt, dy: y-d + h-bar, line(length: 280pt, stroke: 1.5pt + black))

      place(dx: x-start-d, dy: y-d, rect(width: w-difs, height: h-bar, fill: light-blue, stroke: none))
      place(dx: x-start-d, dy: y-d - 5pt, line(start: (0pt, 0pt), end: (0pt, h-bar + 5pt), stroke: 1.5pt + frame-blue))
      place(dx: x-start-d + w-difs, dy: y-d - 5pt, line(
        start: (0pt, 0pt),
        end: (0pt, h-bar + 5pt),
        stroke: 1.5pt + frame-blue,
      ))
      place(dx: x-start-d, dy: y-d - 12pt, block(width: w-difs, align(center, text(size: 8pt)[DIFS])))
      place(dx: x-start-d, dy: y-d + 4pt, block(width: w-difs, align(center, text(size: 6pt)[Carrier Sense])))

      place(dx: x-frame-d, dy: y-d, rect(width: w-frame, height: h-bar, fill: frame-blue, stroke: none))
      place(dx: x-frame-d, dy: y-d + 4pt, block(width: w-frame, align(center, text(size: 8pt)[Frame D$->$B])))

      draw-check(x-start-d - 5pt, y-d + h-bar + 2pt)
      draw-check(x-frame-d - 5pt, y-d + h-bar + 2pt)
    })
  ],
)

La soluzione a questo problema risiede nell'invio di una *Request to Send (RTS)*, da parte di chi vuole trasmettere (il _sender_), verso *tutti* i terminali presenti nel proprio raggio di copertura. Questa richiesta contiene:
- l'indirizzo *MAC* della sorgente
- l'indirizzo *MAC* della destinazione
- la durata stimata dell'*RTS* (intesa come durata totale della trasmissione, comprensiva di eventuali ritrasmissioni in caso di collisione). Tale stima comprende SIFS + CTS + SIFS + Frame + SIFS + ACK, ovvero tutto il processo di comunicazione, compresi i tempi di attesa tra un messaggio e l'altro.

I terminali ai quali non è destinata la richiesta, scartano l'*RTS* e allocano un *Network Allocation Vector (NAV)*, che corrisponde a un tempo in cui sanno di non poter trasmettere (questo tempo viene stimato sulla base delle informazioni raccolte prima di scartare la *Request to Send*).

Il destinatario risponderà, nel caso in cui fosse libero, con un *Clear to Send CTS* a tutti i vicini nel suo raggio di copertura. Il CTS contiene:
- l'indirizzo *MAC* di sorgente
- l'indirizzo *MAC *della destinazione
- il tempo rimanente fino al termine della trasmissione. Questo tempo viene calcolato partendo dalla stima contenuta nell'*RTS*, sottraendo il tempo passato per "trovare" la destinazione.

#nota()[
  I pacchetti RTS e CTS *non sono pacchetti broadcast*. Sono pacchetti unicast, ovvero indirizzati esplicitamente a una sola specifica stazione.

  Tuttavia, vengono ricevuti/sentiti da tutte le stazioni nel raggio di copertura del mittente (RTS) o del destinatario (CTS) a causa del broadcast intrinseco del mezzo radio.
]

Dopo che il *CTS* viene ricevuto da tutti i terminali nel raggio del destinatario, questi ultimi riallocheranno un *NAV* per il tempo indicato nel *CTS*. Questo serve per avvisare tutti i terminali nel raggio del destinatatrio che un'altro nodo all'esterno vuole comunicare con il terminale destinatario.

Lo schema appena descritto è il seguente:

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
      place(dx: x-difs + w-difs, dy: y-a - 15pt, line(
        start: (0pt, 0pt),
        end: (0pt, bar-h + 5pt),
        stroke: 2pt + c-frame,
      ))
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

      let x-sense2 = x-sifs1 + w-sifs1 + 85pt
      let w-sense2 = 40pt
      place(dx: x-sense2, dy: y-a - 10pt, rect(width: w-sense2, height: bar-h, fill: c-sense, stroke: none))
      place(dx: x-sense2, dy: y-a - 15pt, line(start: (0pt, 0pt), end: (0pt, bar-h + 5pt), stroke: 2pt + c-frame))
      place(dx: x-sense2 + w-sense2, dy: y-a - 15pt, line(
        start: (0pt, 0pt),
        end: (0pt, bar-h + 5pt),
        stroke: 2pt + c-frame,
      ))
      place(dx: x-sense2, dy: y-a - 22pt, block(width: w-sense2, align(center, text(size: 10pt)[SIFS])))
      place(dx: x-sense2, dy: y-a - 6pt, block(width: w-sense2, align(center, text(size: 6pt)[Carrier Sense])))

      let x-frame = x-sense2 + w-sense2
      let w-frame = 80pt
      place(dx: x-frame, dy: y-a - 10pt, rect(width: w-frame, height: bar-h, fill: c-frame, stroke: 0.5pt + black))
      place(dx: x-frame, dy: y-a - 5pt, block(width: w-frame, align(center, text(size: 9pt)[FRAME A$->$B])))
      place(dx: x-frame + w-frame + 10pt, dy: y-a - 22pt, text(size: 10pt)[SIFS])

      draw-timeline(y-b, "B")

      let x-sense-b = x-rts + 50pt
      let w-sense-b = 40pt
      place(dx: x-sense-b, dy: y-b - 10pt, rect(width: w-sense-b, height: bar-h, fill: c-sense, stroke: none))
      place(dx: x-sense-b, dy: y-b - 15pt, line(start: (0pt, 0pt), end: (0pt, bar-h + 5pt), stroke: 2pt + c-frame))
      place(dx: x-sense-b + w-sense-b, dy: y-b - 15pt, line(
        start: (0pt, 0pt),
        end: (0pt, bar-h + 5pt),
        stroke: 2pt + c-frame,
      ))
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
  ],
)

== 802.11 Frammentazione
Il canale radio è molto sensibile alle interferenze e al rumore, di conseguenza è ragionevole *ridurre la dimensione* della _frame MAC_ (_frame LLC_ suddivisa in frammenti più piccoli, la cui dimensione cambia in base alle condizioni del canale).

#esempio[
  Supponiamo che la pioggia che cade a terra casualmente sia il rumore, mentre una persona che deve correre sotto la pioggia è il pacchetto che deve viaggiare lungo il canale radio. Avere un _frame_ piccolo, equivale a correre sotto la pioggia per 1 secondo, con meno probabilità di bagnarsi; al contrario, un _frame_ grande corrisponde a una corsa più duratura, con più gocce/rumore che colpiscono.
]

Possiamo immaginare la frammentazione così:

#figure(
  image("../assets/frammentazione.png"),
)

Chiaramente, per ogni frammento, è necessario aggiungere informazioni riguardo al *NAV*, per i dispotivi che non sono direttamente coinvolti nella comunicazione.

Inoltre, la *frammentazione* e la *correzione degli errori* viene sempre effettuata a livello *MAC*, tra dispositivo e *Access Point*: lasciare la correzione dei dati a livelli superiori (come ad esempio il _TCP_), porterebbe inevitabilmente a ritardi e tempi di trasmissione allungati, poiché sarebbe il destinatario ad accorgersi dell'errore e a chiedere una nuova trasmissione.

== 802.11 con infrastruttura

#figure(
  image("../assets/802.11_infrastruttura.png", width: 70%),
)

Dallo schema di questa infrastruttura è possibile distinguere tra:
- *Basic Service Set (BSS)*: Insieme di stazioni controllate da un singolo coordinatore/Access Point.
- *Extended Service Set (ESS)*: Insieme di più *BSS* interconnessi tramite un *sistema distribuito* (*DS*).

Il *sistema distribuito* è collegato alla _LAN_ tramite un router/bridge e l'*Extended Service Set* viene visto esternamente come un unico *Basic Service Set* per il *Logical Link Layer* (livello 2 _data link_), per funzionalità di roaming fra *AP* diversi.

=== Point Coordination Function (PCF)

Il PCF opera attraverso un *Point Coordinator (PC)*, tipicamente implementato nell'*Access Point* (AP), che controlla l'accesso al canale wireless interrogando sequenzialmente le stazioni che hanno richiesto di operare in modalità PCF.

#nota[
  Il PCF è stato progettato per supportare applicazioni *time-sensitive* come VoIP o streaming video, garantendo accesso deterministico al mezzo.
]

Nella modalità PCF, l'AP controlla l'accesso al canale radio:
+ Tutto il traffico passa dall'AP
+ Le stazioni associate ad AP usano DCF con tempistiche SIFS e DIFS per accedere al canale
+ AP usa *PIFS* In questo modo AP riesce ad _impossessarsi_ del canale radio prima delle
stazioni in attesa.

=== Beacon Frame

Per garantire il funzionamento corretto del *PCF*, l'*AP* necessita di prendere il controllo del canale radio prima delle stazioni in attesa. A questo proposito, l'*Access Point* invia periodicamente (ogni 10-100s) dei *beacon frame*, che contengono:
- Parametri operativi *PHY*: _bit rate_ e _Modulation Coding Scheme_, ovvero tutte le capacità fisiche dell'*AP*;
- Sincronizzazione: qualsiasi dispositivo voglia scambiare messaggi con l'*Access Point*, deve opportunamente sincronizzare il proprio clock;
- Supporto a *PCF*: informazioni utili per garantire il funzionamento di questa modalità;
- Invito per nuove stazioni non ancora associate.

==== Divisione del tempo

Ogni blocco temporale che compone un *superframe* è composto da 2 blocchi distinti:

- Parte con accesso *senza contesa* (CFP): necessaria per servizi _time-bounded_ (es. servizi in streaming in cui i dati devono viaggiare sicuri e senza ritardi). Periodo *controllato dal Point Coordinator* dove non c'è competizione per l'accesso al mezzo. Il PC interroga le stazioni in modalità round-robin.

- Parte con accesso *con contesa* (CP): necessaria per lo "smaltimento" del traffico normale (es. download di documenti e file multimediali, in cui un minimo ritardo o una collisione occasionale non è particolarmente grave). Periodo in cui le stazioni utilizzano il *DCF standard* (CSMA/CA) per accedere al canale.

Sostanzialmente, questa divisione è fondamentale perché l'*AP* si preoccupa di interrogare chi ha urgenza e lascia poi liberi tutti gli altri per i propri servizi.

#align(center)[
  #figure(
    cetz.canvas(length: 0.8cm, {
      import cetz.draw: *

      let w = 3.5
      let h = 1.2
      let gap = 0.3

      // CFP blocks
      rect((0, 0), (w, h), fill: rgb("#4472C4"), stroke: black)
      content((w / 2, h / 2), text(fill: white, weight: "bold", size: 0.9em)[CFP])

      rect((w + gap, 0), (2 * w + gap, h), fill: rgb("#ED7D31"), stroke: black)
      content((1.5 * w + gap, h / 2), text(fill: white, weight: "bold", size: 0.9em)[CP])

      rect((2 * w + 2 * gap, 0), (3 * w + 2 * gap, h), fill: rgb("#4472C4"), stroke: black)
      content((2.5 * w + 2 * gap, h / 2), text(fill: white, weight: "bold", size: 0.9em)[CFP])

      rect((3 * w + 3 * gap, 0), (4 * w + 3 * gap, h), fill: rgb("#ED7D31"), stroke: black)
      content((3.5 * w + 3 * gap, h / 2), text(fill: white, weight: "bold", size: 0.9em)[CP])

      // Time arrow
      line((0, -0.8), (4 * w + 3 * gap, -0.8), mark: (end: ">", fill: black))
      content((2 * w + 1.5 * gap, -1.2), text(weight: "bold")[Tempo])

      // Labels
      content((w / 2, h + 0.8), text(size: 0.8em)[Polling])
      content((1.5 * w + gap, h + 0.8), text(size: 0.8em)[CSMA/CA])
    }),
    caption: [Alternanza tra Contention-Free Period e Contention Period],
  )
]

#nota[
  Nella modalità *CDF*, tutti i dispositivi sono uguali: se c'è silezio, aspettano un tempo casuale e provano a trasmettere. Il difetto di questo sistema è che è imprevedibile.
  #esempio[
    Se voglio guardare un video in straming, non posso permettermi ritardi casuali. Serve invece garanzia che il pacchetto arrivi quando serve e non "forse tra 100 millisecondi se nessuno parla".
  ]

  Far prendere all'*AP* il comando di tutto risolve il problema: i dispositivi non si occupano di quando "prendere" il canale, ma è l'*AP* stesso che assegna i turni.
]

=== Interframe Spacing in PCF

Il PCF utilizza un *PIFS (PCF Interframe Space)* più corto del DIFS utilizzato dal DCF. Questo permette al Point Coordinator di ottenere priorità nell'accesso al canale rispetto alle stazioni in modalità DCF.

La *gerarchia degli interframe spacing* è:
$ "SIFS" < "PIFS" < "DIFS" $
dove:
- $"SIFS"$ (Short IFS): ~10 μs, usato per ACK e risposte immediate
- $"PIFS"$ (PCF IFS): ~30 μs, usato dal Point Coordinator
- $"DIFS"$ (DCF IFS): ~50 μs, usato dalle stazioni in DCF

=== Processo di Polling

Durante il Content free period, il Point Coordinator:

1. Al termine della comunicazione precedente, tutti i dispositivi cominciano ad attendere un tempo DIFS, ma l'AP aspetta un tempo PIFS, quindi prende il lock sul canale prima degli altri, iniziando il periodo di contesa
2. Trasmette un frame *CF-Poll* alla stazione successiva nella polling list
3. La stazione riceve il poll e può trasmettere un frame dati entro un *tempo SIFS* (per non rischiare di perdere il lock sul canale).
4. Se la stazione non ha dati da trasmettere, risponde con un *CF-Null*
5. Il processo continua fino alla fine del CFP

Lo schema del *Point Coordination Function (PCF)* è quindi il seguente:

#figure(
  align(center)[
    #scale(80%)[
      #box(width: 560pt, height: 280pt, {
        let cyan-c = rgb("#00AEEF")
        let line-c = rgb("#333333")
        let t-size = 8pt

        let nav-pat = pattern(size: (5pt, 5pt))[
          #place(line(start: (0pt, 5pt), end: (5pt, 0pt), stroke: 0.5pt + cyan-c))
        ]

        let draw-box(x, y, w, content) = {
          let h = 20pt
          place(dx: x, dy: y - h / 2, rect(width: w, height: h, fill: white, stroke: 1.2pt + cyan-c))
          place(dx: x, dy: y - h / 2, block(width: w, height: h, align(center + horizon, text(
            size: t-size,
            fill: cyan-c,
          )[#content])))
        }

        let delay-arrow(x1, x2, y, label, label-dy: -8pt) = {
          place(dx: x1, dy: y, line(start: (0pt, 0pt), end: (x2 - x1, 0pt), stroke: 0.7pt + line-c))
          place(dx: x2, dy: y, polygon(fill: line-c, (0pt, 0pt), (-4pt, 2.5pt), (-4pt, -2.5pt)))
          place(dx: x1 + (x2 - x1) / 2 - 12pt, dy: y + label-dy, block(width: 24pt, align(center, text(
            size: 7.5pt,
            fill: line-c,
          )[#label])))
        }

        let draw-break(x, y, h: 20pt) = {
          place(dx: x - 4pt, dy: y - h / 2, rect(width: 8pt, height: h, fill: white, stroke: none))
          place(dx: x - 2pt, dy: y - h / 2 + 2pt, line(start: (0pt, h - 4pt), end: (4pt, 0pt), stroke: 0.7pt + line-c))
          place(dx: x + 2pt, dy: y - h / 2 + 2pt, line(start: (0pt, h - 4pt), end: (4pt, 0pt), stroke: 0.7pt + line-c))
        }

        let y-pc = 70pt
        let y-st = 140pt
        let y-os = 200pt
        let y-top = 20pt
        let y-bot = 240pt

        let x0 = 85pt
        let w-pifs = 22pt
        let w-sifs = 18pt
        let w-box = 20pt
        let w-cfend = 24pt

        let x-dd1 = x0 + w-pifs
        let x-ud1 = x-dd1 + w-box + w-sifs
        let x-dd2 = x-ud1 + w-box + w-sifs
        let x-ud2 = x-dd2 + w-box + w-sifs
        let x-tick = x-ud2 + w-box + w-sifs
        let x-dd3 = x-tick + w-pifs
        let x-dd4 = x-dd3 + w-box + w-pifs
        let x-ud4 = x-dd4 + w-box + w-sifs
        let x-cfend = x-ud4 + w-box + w-sifs

        let x-break = 470pt
        let x-cfp-end = 500pt
        let x-sf-end = 540pt

        place(dx: x0, dy: y-top, line(start: (0pt, -5pt), end: (0pt, y-bot - y-top), stroke: 0.5pt + line-c))
        place(dx: x-sf-end, dy: y-top, line(start: (0pt, -5pt), end: (0pt, y-bot - y-top), stroke: 0.5pt + line-c))

        place(dx: x0, dy: y-top, line(start: (0pt, 0pt), end: (x-sf-end - x0, 0pt), stroke: 0.5pt + line-c))
        place(dx: x0, dy: y-top, polygon(fill: line-c, (0pt, 0pt), (4pt, 2.5pt), (4pt, -2.5pt)))
        place(dx: x-sf-end, dy: y-top, polygon(fill: line-c, (0pt, 0pt), (-4pt, 2.5pt), (-4pt, -2.5pt)))
        place(dx: x0 + (x-sf-end - x0) / 2 - 30pt, dy: y-top - 6pt, rect(fill: white, stroke: none)[#text(
          size: t-size,
        )[Superframe]])
        draw-break(x-break, y-top, h: 12pt)

        place(dx: x-cfp-end, dy: y-pc - 15pt, line(
          start: (0pt, 0pt),
          end: (0pt, y-bot - (y-pc - 15pt) + 5pt),
          stroke: 0.5pt + line-c,
        ))

        place(dx: x0, dy: y-bot, line(start: (0pt, 0pt), end: (x-cfp-end - x0, 0pt), stroke: 0.5pt + line-c))
        place(dx: x0, dy: y-bot, polygon(fill: line-c, (0pt, 0pt), (4pt, 2.5pt), (4pt, -2.5pt)))
        place(dx: x-cfp-end, dy: y-bot, polygon(fill: line-c, (0pt, 0pt), (-4pt, 2.5pt), (-4pt, -2.5pt)))
        place(dx: x0 + (x-cfp-end - x0) / 2 - 50pt, dy: y-bot - 6pt, rect(fill: white, stroke: none)[#text(
          size: t-size,
        )[Contention-free period]])
        draw-break(x-break, y-bot, h: 12pt)

        place(dx: x-cfp-end, dy: y-bot, line(
          start: (0pt, 0pt),
          end: (x-sf-end - x-cfp-end, 0pt),
          stroke: 0.5pt + line-c,
        ))
        place(dx: x-cfp-end, dy: y-bot, polygon(fill: line-c, (0pt, 0pt), (4pt, 2.5pt), (4pt, -2.5pt)))
        place(dx: x-sf-end, dy: y-bot, polygon(fill: line-c, (0pt, 0pt), (-4pt, 2.5pt), (-4pt, -2.5pt)))
        place(dx: x-cfp-end + (x-sf-end - x-cfp-end) / 2 - 25pt, dy: y-bot + 12pt, block(align(center, text(
          size: 7.5pt,
        )[Contention\ period])))
        place(dx: x-cfp-end + (x-sf-end - x-cfp-end) / 2, dy: y-bot + 10pt, line(
          start: (0pt, 0pt),
          end: (0pt, -5pt),
          stroke: 0.5pt + line-c,
        ))
        place(dx: x-cfp-end + (x-sf-end - x-cfp-end) / 2, dy: y-bot + 5pt, polygon(
          fill: line-c,
          (0pt, 0pt),
          (-2.5pt, 4pt),
          (2.5pt, 4pt),
        ))

        for y in (y-pc, y-st, y-os) {
          place(dx: x0 - 10pt, dy: y, line(start: (0pt, 0pt), end: (x-sf-end - x0 + 35pt, 0pt), stroke: 0.5pt + line-c))
          draw-break(x-break, y)
          place(dx: x-sf-end + 25pt, dy: y, polygon(fill: line-c, (0pt, 0pt), (-4pt, 3pt), (-4pt, -3pt)))
          place(dx: x-sf-end + 30pt, dy: y - 4pt, text(size: t-size)[Time])
        }

        let x-nav-end = x-cfend + w-cfend
        place(dx: x0, dy: y-os - 12pt, rect(width: x-nav-end - x0, height: 24pt, fill: nav-pat, stroke: 1.2pt + cyan-c))
        place(dx: x0 + (x-nav-end - x0) / 2 - 15pt, dy: y-os - 6pt, rect(
          width: 30pt,
          height: 12pt,
          fill: white,
          stroke: none,
        ))
        place(dx: x0 + (x-nav-end - x0) / 2 - 15pt, dy: y-os - 6pt, block(width: 30pt, height: 12pt, align(
          center + horizon,
          text(size: t-size, fill: cyan-c)[NAV],
        )))
        draw-break(x-break, y-os, h: 26pt)

        place(dx: 10pt, dy: y-pc - 4pt, text(size: t-size)[Point coordinator])
        place(dx: 10pt, dy: y-st - 4pt, text(size: t-size)[Stations 1, 2, 3, 4])
        place(dx: 10pt, dy: y-os - 4pt, text(size: t-size)[Other stations])

        place(dx: x0 - 62pt, dy: y-pc - 20pt, text(size: 7.5pt)[Medium busy])
        place(dx: x0 - 15pt, dy: y-pc - 16pt, line(start: (0pt, 0pt), end: (15pt, 0pt), stroke: 0.5pt + line-c))
        place(dx: x0, dy: y-pc - 16pt, polygon(fill: line-c, (0pt, 0pt), (-4pt, 2.5pt), (-4pt, -2.5pt)))

        place(dx: x0, dy: y-pc - 15pt, line(start: (0pt, 0pt), end: (0pt, 15pt), stroke: 0.5pt + line-c))
        delay-arrow(x0, x-dd1, y-pc - 10pt, "PIFS")
        draw-box(x-dd1, y-pc, w-box, "DD1")

        place(dx: x-dd1 + w-box, dy: y-pc, line(
          start: (0pt, 0pt),
          end: (0pt, y-st - y-pc - 10pt),
          stroke: 0.5pt + line-c,
        ))
        delay-arrow(x-dd1 + w-box, x-ud1, y-st - 10pt, "SIFS")
        draw-box(x-ud1, y-st, w-box, "UD1")

        place(dx: x-ud1 + w-box, dy: y-pc - 15pt, line(
          start: (0pt, 0pt),
          end: (0pt, y-st - y-pc + 15pt),
          stroke: 0.5pt + line-c,
        ))
        delay-arrow(x-ud1 + w-box, x-dd2, y-pc - 10pt, "SIFS")
        draw-box(x-dd2, y-pc, w-box, "DD2")

        place(dx: x-dd2 + w-box, dy: y-pc, line(
          start: (0pt, 0pt),
          end: (0pt, y-st - y-pc - 10pt),
          stroke: 0.5pt + line-c,
        ))
        delay-arrow(x-dd2 + w-box, x-ud2, y-st - 10pt, "SIFS")
        draw-box(x-ud2, y-st, w-box, "UD2")

        place(dx: x-ud2 + w-box, dy: y-pc - 15pt, line(
          start: (0pt, 0pt),
          end: (0pt, y-st - y-pc + 15pt),
          stroke: 0.5pt + line-c,
        ))
        delay-arrow(x-ud2 + w-box, x-tick, y-pc - 10pt, "SIFS")

        place(dx: x-tick, dy: y-pc - 15pt, line(start: (0pt, 0pt), end: (0pt, 15pt), stroke: 0.5pt + line-c))
        delay-arrow(x-tick, x-dd3, y-pc - 10pt, "PIFS")
        draw-box(x-dd3, y-pc, w-box, "DD3")

        place(dx: x-dd3 + w-box, dy: y-pc - 15pt, line(start: (0pt, 0pt), end: (0pt, 15pt), stroke: 0.5pt + line-c))
        delay-arrow(x-dd3 + w-box, x-dd4, y-pc - 10pt, "PIFS")
        draw-box(x-dd4, y-pc, w-box, "DD4")

        place(dx: x-dd4 + w-box, dy: y-pc, line(
          start: (0pt, 0pt),
          end: (0pt, y-st - y-pc - 10pt),
          stroke: 0.5pt + line-c,
        ))
        delay-arrow(x-dd4 + w-box, x-ud4, y-st - 10pt, "SIFS")
        draw-box(x-ud4, y-st, w-box, "UD4")

        place(dx: x-ud4 + w-box, dy: y-pc - 15pt, line(
          start: (0pt, 0pt),
          end: (0pt, y-st - y-pc + 15pt),
          stroke: 0.5pt + line-c,
        ))
        delay-arrow(x-ud4 + w-box, x-cfend, y-pc - 10pt, "SIFS")
        draw-box(x-cfend, y-pc, w-cfend, [CF\ end])

        place(dx: 15pt, dy: 265pt, text(size: t-size)[DDx = Downstream data/poll])
        place(dx: 165pt, dy: 265pt, text(size: t-size)[UDx = Upstream data])
        place(dx: 275pt, dy: 265pt, text(size: t-size)[CFend = Contention-free (period) end])
      })
    ]
  ],
)




#attenzione[
  Nonostante i vantaggi teorici, il PCF presenta diverse limitazioni che ne hanno limitato l'adozione pratica:
  - La maggior parte dei dispositivi 802.11 non implementa il PCF (è *opzionale*)
  - Difficoltà di coordinamento in presenza di *stazioni DCF e PCF miste*
  - *Overhead significativo* dovuto ai frame CF-Poll
  - Problemi con il "hidden node" che possono causare collisioni anche durante il CFP
]



== Formato frame MAC

#figure(
  align(center)[
    #scale(x: 90%, y: 90%)[
      #box(width: 510pt, height: 240pt, {
        let d-red = rgb("#9E353B")
        let d-blue = rgb("#2A5092")
        let l-blue = rgb("#A9CDE3")
        let txt-col = black

        let c-col(w, lbl, bg, txt, f-size: 7.5pt) = stack(
          dir: ttb,
          box(width: w, height: 14pt, align(center + bottom, pad(bottom: 3pt, text(size: 8pt)[#lbl]))),
          box(width: w, height: 26pt, rect(
            width: 100%,
            height: 100%,
            fill: bg,
            stroke: 0.8pt + black,
            inset: 0pt,
            align(center + horizon, text(size: f-size, fill: if bg == l-blue { black } else { white })[#txt]),
          )),
        )

        let s-arr(w, lbl) = box(width: w, height: 15pt, {
          place(left + horizon, dx: -1pt, polygon(fill: black, (0pt, 0pt), (3pt, 2.5pt), (3pt, -2.5pt)))
          place(right + horizon, dx: 1pt, polygon(fill: black, (0pt, 0pt), (-3pt, 2.5pt), (-3pt, -2.5pt)))
          place(center + horizon, line(length: 100%, stroke: 0.6pt + black))
          place(center + horizon, rect(fill: white, stroke: none, inset: 2pt, text(size: 8pt)[#lbl]))
        })

        place(dx: 0pt, dy: 0pt, stack(
          dir: ltr,
          stack(dir: ttb, box(width: 32pt, height: 14pt, align(right + bottom, text(size: 8pt)[bytes#h(4pt)])), box(
            width: 32pt,
            height: 26pt,
          )),
          c-col(18pt, "2", d-red, "FC"),
          c-col(18pt, "2", d-red, "D/I"),
          c-col(54pt, "6", d-red, "Address"),
          c-col(54pt, "6", d-blue, "Address"),
          c-col(54pt, "6", d-blue, "Address"),
          c-col(18pt, "2", d-blue, "SC"),
          c-col(54pt, "6", d-blue, "Address"),
          c-col(18pt, "2", d-blue, "QoS"),
          c-col(36pt, "4", d-blue, "HT"),
          c-col(108pt, "0 to 11,426", l-blue, "Data"),
          c-col(36pt, "4", d-red, "FCS"),
        ))

        place(dx: 32pt, dy: 45pt, s-arr(324pt, "Header"))
        place(dx: 356pt, dy: 45pt, s-arr(108pt, "Frame body"))
        place(dx: 464pt, dy: 45pt, s-arr(36pt, "Trailer"))

        place(dx: 32pt, dy: 75pt, grid(
          columns: (130pt, 140pt, 200pt),
          row-gutter: 8pt,
          text(size: 8pt)[FC = frame control],
          text(size: 8pt)[SC = sequence control],
          stack(dir: ltr, rect(width: 10pt, height: 10pt, fill: d-red, stroke: none), h(6pt), text(
            size: 8pt,
          )[Always present]),

          text(size: 8pt)[D/I = duration/connection ID],
          text(size: 8pt)[FCS = frame check sequence],
          stack(dir: ltr, rect(width: 10pt, height: 10pt, fill: d-blue, stroke: none), h(6pt), text(
            size: 8pt,
          )[Present only in certain frame types\ and sub-types]),

          text(size: 8pt)[QoS = QoS control], text(size: 8pt)[HT = high throughput control], [],
        ))

        place(dx: 202pt, dy: 125pt, text(
          size: 8pt,
        )[*High Throughput Control:* specifico per 802.11n, 802.11ac,\ and 802.11ad.])

        place(dx: 0pt, dy: 165pt, stack(
          dir: ltr,
          stack(dir: ttb, box(width: 32pt, height: 14pt, align(right + bottom, text(size: 8pt)[bits#h(4pt)])), box(
            width: 32pt,
            height: 26pt,
          )),
          c-col(42pt, "2", d-red, [Protocol\ version], f-size: 6.5pt),
          c-col(42pt, "2", d-red, "Type"),
          c-col(84pt, "4", d-red, "Subtype"),
          c-col(21pt, "1", d-red, [To\ DS], f-size: 6.5pt),
          c-col(21pt, "1", d-red, [From\ DS], f-size: 6pt),
          c-col(21pt, "1", d-red, "MF"),
          c-col(21pt, "1", d-red, "RT"),
          c-col(21pt, "1", d-red, "PM"),
          c-col(21pt, "1", d-red, "MD"),
          c-col(21pt, "1", d-red, "W"),
          c-col(21pt, "1", d-red, "O"),
        ))

        place(dx: 195pt, dy: 215pt, text(size: 9pt, weight: "bold")[Frame Control])

        place(path(stroke: 1.5pt + black, (32pt, 27pt), (10pt, 27pt), (10pt, 192pt), (32pt, 192pt)))
        place(dx: 32pt, dy: 192pt, polygon(fill: black, (0pt, 0pt), (-6pt, 3.5pt), (-6pt, -3.5pt)))
      })
    ]
  ],
)

I campi di colore #text(fill: red)[rosso] sono quelli sempre presenti in qualsiasi frame 802.11, mentre i rimanenti sono presenti solo se necessari.

Dalla freccia dall'alto verso il basso, è possibile notare il contenuto dei 2 byte di *Frame Control (FC)*. Tra i bit più importanti al suo interno, troviamo quelli riguardanti il *tipo* di frame:
- *00* $->$ *Management*: pacchetti che servono per gestire la rete e creare collegamenti;
- *01* $->$ *Controllo*: frame con lo scopo di aiutare la consegna dei dati, contenendo bit che servono a prenotare il canale o a confermare l'arrivo di un pacchetto;
- *10* $->$ *Data*: frame che contengono il *payload* vero e proprio.

Per quanto riguarda invece il secondo gruppo di byte, possiamo notare i contenuti relativi alla duranta rimanente, in $mu s$, della trasmissione e particolarmente utile per la gestione dei *NAV*.

Troviamo poi i byte sull'indirizzo di *destinazione* (possono esserci fino a 4 indirizzi). Al termine della frame vi è una parte preoposta al controllo e la correzione degli errori.

==== Porzione di ADDRESS
Nello schema precedente, abbiamo citato i possibili 4 indirizzi che possono essere presenti all'interno della frame MAC. Questa tabella riassume esaustivamente il contenuto di questi campi:

#pagebreak()

#align(center)[
  #text(size: 8pt)[
    #table(
      columns: (auto, auto, 1fr, 1fr, 1fr, 1fr, 1.3fr),
      align: center + horizon,
      inset: 6pt,
      stroke: 0.5pt + black,

      [*To*\ *DS*], [*From*\ *DS*], [*Address 1*], [*Address 2*], [*Address 3*], [*Address 4*], [*Caso di*\ *utilizzo*],

      [0],
      [0],
      [*DA*\ Indirizzo MAC\ destinazione],
      [*SA*\ Indirizzo MAC\ sorgente],
      [*BSSID*\ della cella/\ random se ad\ hoc],
      [-],
      [Rete ad hoc\ Rete con\ infrastruttura\ singola cella],

      [0],
      [1],
      [*DA*\ Indirizzo MAC\ destinazione\ all'interno di\ BSSID],
      [*BSSID*\ della cella a\ cui la frame è\ destinata],
      [*SA*\ Indirizzo MAC\ sorgente],
      [-],
      [Frame inviata\ attraverso DS\ ad un AP\ all'interno\ della cella che\ possiede\ BSSID\ dell'address 2],

      [1],
      [0],
      [*BSSID*\ della cella\ destinazione],
      [*SA*\ Indirizzo MAC\ sorgente],
      [*DA*\ Indirizzo MAC\ stazione che\ sta ricevendo],
      [-],
      [Frame inviata\ attraverso DS\ ad un AP di\ una cella\ diversa BSSID\ dell'address 1],

      [1],
      [1],
      [*RA*\ Indirizzo AP\ destinazione\ all'interno di\ DS],
      [*TA*\ Indirizzo AP\ sorgente\ all'interno di\ DS],
      [*DA*\ Indirizzo della\ stazione che\ sta ricevendo],
      [*SA*\ indirizzo della\ stazione che\ sta inviando],
      [Frame tra AP\ di celle\ differenti\ usando DS],
    )
  ]
]

Le ultime 3 righe fanno riferimento alla casistica in cui sono presenti più celle e serve routing tra di queste. I casi sono:
- $01$ From DS, verso un AP all'interno della cella, letto nell'indirizzo 2
- $10$ Verso il DS, indico cella e indirizzo di destinazione
- $11$ Da e Verso il DS, devo sapere da dove arriva e dove inviare, oltre che l'indirizzo originale e finale (routing tra celle)

== Orthogonal Frequency Division Multiple Access (OFDMA)
in Wi-Fi 6 viene utilizza una tecnica rivoluzionaria rispetto al passato (Wi-Fi 4 e 5) chiamata *OFDMA ( Orthogonal Frequency Division Multiple Access OFDM)*: Tale tecnica permette di suddividere il canale in più sottoportanti, assegnando a ciascun utente una porzione specifica del canale, *consentendo connettività a più dispositivi contemporaneamente*.

Nelle versioni precedenti, tutte le sottoportanti erano usate per un dispositivo alla volta (OFDM, dove M sta per Multiplexing). Con OFDMA c'è la possibilità di fornire gruppi di canali diversi a dispositivi diversi.

#informalmente()[
  I router non gestiscono più il traffico tramite una politcia _uno alla volta_, ma grazie ad una politica _tutti insieme_.
]

Dal punto di vista grafico, possiamo visualizzare l'utilizzo di *OFDM (Orthogonal Frequency-Division Multiplexing)* con *TDMA (Time Division Multiple Access)* così:

#align(center)[
  #text(size: 8pt)[
    #let b-dark = rgb("#3BA2F9")
    #let b-light = rgb("#CDE5FD")
    #let g-dark = rgb("#87C74C")
    #let g-light = rgb("#DDF0D1")
    #let y-dark = rgb("#FFBF00")
    #let y-light = rgb("#FCEFCB")
    #let r-dark = rgb("#CC0000")
    #let p-dark = rgb("#9966CC")
    #let p-light = rgb("#E2D1F0")

    #table(
      columns: (auto, 70pt, 70pt, 70pt, 70pt, 70pt),
      align: center + horizon,
      stroke: 0.5pt + black,

      [], [T1], [T2], [T3], [T4], [T5],

      [F1],
      table.cell(fill: b-dark)[],
      table.cell(fill: g-dark)[],
      table.cell(fill: y-dark)[],
      table.cell(fill: r-dark)[],
      table.cell(fill: p-dark)[],

      [F2],
      table.cell(fill: b-dark)[],
      table.cell(fill: g-dark)[],
      table.cell(rowspan: 4, fill: y-light)[Non necessario],
      table.cell(fill: r-dark)[],
      table.cell(fill: p-dark)[],

      [F3],
      table.cell(rowspan: 3, fill: b-light)[Non necessario],
      table.cell(fill: g-dark)[],
      table.cell(fill: r-dark)[],
      table.cell(rowspan: 3, fill: p-light)[Non necessario],

      [F4], table.cell(rowspan: 2, fill: g-light)[Non necessario], table.cell(fill: r-dark)[],

      [F5], table.cell(fill: r-dark)[],
    )
  ]
]

Con *OFDMA*, la situazione sarebbe leggermente diversa:

#align(center)[
  #text(size: 8pt)[
    #let b-dark = rgb("#3BA2F9")
    #let g-dark = rgb("#87C74C")
    #let y-dark = rgb("#FFBF00")
    #let r-dark = rgb("#CC0000")
    #let p-dark = rgb("#9966CC")

    #table(
      columns: (auto, 70pt, 70pt, 70pt, 70pt, 70pt),
      align: center + horizon,
      stroke: 0.5pt + black,

      [], [T1], [T2], [T3], [T4], [T5],

      [F1],
      table.cell(fill: b-dark)[],
      table.cell(fill: r-dark)[],
      table.cell(fill: y-dark)[],
      [],
      table.cell(fill: r-dark)[],

      [F2],
      table.cell(fill: b-dark)[],
      table.cell(fill: r-dark)[],
      table.cell(fill: p-dark)[],
      table.cell(fill: g-dark)[],
      table.cell(fill: r-dark)[],

      [F3],
      table.cell(fill: g-dark)[],
      table.cell(fill: r-dark)[],
      table.cell(fill: p-dark)[],
      table.cell(fill: g-dark)[],
      table.cell(fill: r-dark)[],

      [F4],
      table.cell(fill: g-dark)[],
      table.cell(fill: r-dark)[],
      table.cell(fill: b-dark)[],
      table.cell(fill: g-dark)[],
      table.cell(fill: r-dark)[],

      [F5],
      table.cell(fill: g-dark)[],
      table.cell(fill: r-dark)[],
      table.cell(fill: b-dark)[],
      [],
      table.cell(fill: r-dark)[],
    )
  ]
]

#nota[
  L'idea centrale di *OFDMA* e ridurre il tempo di attesa medio: invece di fare trasmissioni lunghe e seriali per tanti dispositivi, l'*Access Point* puo servire molti utenti insieme, anche con porzioni di banda diverse.

  Facendo questo *si complica lo scheduling*: al posto di assegnare solo lo slot di tempo bisogna assegnare tempo e gruppo di frequenze ad ogni applicazione.
]

=== Resource Unit (RU)

Come visto in precedenza, in *Wi-Fi 6 (802.11ax)*, il canale non viene piu visto come un unico blocco assegnato a un solo utente per volta, ma viene suddiviso in porzioni piu piccole dette *Resource Unit (RU)*.

Una *RU* e quindi un *insieme di sottoportanti OFDM contigue* assegnate a uno specifico terminale per una singola trasmissione. Si tratta dunque dell'unità base di suddivisione della banda.\
La dimensione delle RU è variabile e dipende dalla banda disponibile e da come l'AP vuole allocare le risorse agli utenti.

Le ampiezze piu comuni delle *RU* (espresse in numero di sottoportanti) sono:
- *26-tone RU*: tipicamente usata per traffico leggero (telemetria, IoT, piccoli pacchetti);
- *52-tone RU* e *106-tone RU*: compromesso tra efficienza e velocita;
- *242-tone RU* (e superiori): usata quando un utente necessita di throughput maggiore.

In modo intuitivo: piu grande e la *RU*, maggiore e la porzione di canale assegnata all'utente e quindi maggiore il bitrate potenziale.

#nota()[
  *Non* tutta la banda viene suddivisa in *RU*: una parte e riservata per il controllo e la gestione del canale, oltre che per garantire un *margine di guardia* tra le RU per evitare interferenze.
]

Alcune sottoportanti vengono utilizzate come *pilots*: Trasmettono un'onda definita dallo standard, in modo da permettere al ricevitore di stimare la qualità del canale e correggere eventuali distorsioni o interferenze. Tale trasmissioni vengono ripetute periodicamente per mantenere una stima aggiornata del canale, soprattutto in ambienti dinamici.

=== Identificazione delle RU

L'AP utilizza un campo specifico all'interno del frame di controllo per indicare quali RU sono state assegnate a ciascun utente. Questo campo, chiamato *Resource Allocation (RA) field*, contiene informazioni sulla posizione e dimensione della RU assegnata.

Ogni risorsa viene *identificata da un codice* (7 bit) che specifica la posizione della RU all'interno del canale, e da un campo che indica la dimensione della RU (ad esempio, 26-tone, 52-tone, ecc.). Ciascun codice rappresenta un' insieme di sottoportanti e il numero indica
il range di sottoportanti usate da quella RU.

#esempio()[
  Se un AP assegna a un utente la prima RU da $52$-tone in un canale da $20$ MHz (Uplink), significa che l'utente può utilizzare le sottoportanti fisiche con indice da $-121$ a $-70$ per la sua trasmissione.

  All'interno del Trigger Frame, il campo RU Allocation a $7$-bit assegnerà questa risorsa usando un singolo indice tabellare predefinito dallo standard:
  - Valore RU Allocation: $0100101$ (37 in decimale, che identifica univocamente la $"RU" 1 "da" 52-"tone"$.
]

Tali informazioni sono usate dai livelli PHY e MAC per instradare correttamente i dati al dispositivo destinatario e per garantire che solo il dispositivo assegnato alla RU possa accedere a quella porzione di canale durante la trasmissione.

=== Downlink DL-OFDMA

L'AP possiede dati da trasmettere e conosce la lista dei destinatari, ma deve anche comunicare l'assegnamento delle risorse.

#align(center)[
  #image("../assets/Downlink.png", width: 65%)
]

Viene usata una *Multi-User Request to Send (MU-RTS)*, un messaggio di controllo che ha il funzionamento di RTS (Request To Send) e assegnamento delle risorse. Permette alle stazioni designate all'interno del messaggio di trasmettere e allo stesso tempo, indica alle stazioni non interessate di allocare il NAV.

In questo modo le stazioni possono essere a conoscenza delle risorse a loro dedicate. Esse risponderanno con un CTS, in contemporanea (le frequenze sono ortogonali, non collidono). Per la risposta, ogni stazione ascolta solo la porzione di canale a lei associata.

Dopo il termine dei frame i dispositivi non mandano subito l'ack, ma l'AP aspetta tempo `SIFS` e invia un *Block Acknowledgement Request (BAR)*. I dispositivi rispondono in parallelo con un Block ACK.

#attenzione()[
  Se gli ACK fossero inviati immediatamente al termine della trasmissione, l'ACK di ogni dispositivo potrebbe andare perso se l'AP non è ancora in modalità di ricezione.
]

L'ordine è:
$
  "MU-RTS" -> "CTS" -> "Assegnamenti RU" -> "BAR" -> "ACK"
$

Ognuno di questi *intervallato da tempo SIFS*.

=== 4.4.2 Uplink UP-OFDMA

L'uplink è _meno prevedibile_ e richiede di sincronizzare tutti i dispositivi che si vuole trasmettano contemporaneamente. La *trasmissione* deve avvenire in modo *sincronizzato*. L'AP comunica ad ognio stazione la risorsa su cui trasmettere.

#align(center)[
  #image("../assets/Uplink.png", width: 65%)
]

Ci sono più step:
- *Buffer Status Report Poll (BSRP)*: l'AP chiede alle stazioni se hanno dati da trasmettere, in parallelo. Interroga un sottogruppo di stazioni per chiedere chi ha da dire qualcosa.

- I dispositivi rispondono con un *Buffer Status Report (BSR)*: le stazioni che hanno da trasmettere rispondono con una misura della quantità di dati (al fine di allocare le risorse).

- L'AP assegna risorse in base alle risposte delle stazioni e invia il *MU-RTS*, indicando la suddivisione delle RU che devono utilizzare per rispondere con le CTS (sincronizzazione della risposta).

- Le stazioni rispondono con un *CTS*.

- è presente un trigger aggiuntivo da parte dell'AP, al fine di sincronizzare i dispositivi. Tutte le stazioni devono trasmettere nello stesso momento (ad esempio tenendo in considerazione che chi è più lontano comincia prima). Inoltre, in questo istante avviene l'*assegnazione definitiva delle RU* per la trasmissione dei dati veri e propri (UL-PPDU), tramite il Basic Trigger Frame. Esso viene inviato dall'AP subito dopo aver ricevuto i CTS.

- Ogni stazione trasmette in parallelo sulle risorse che gli sono state allocate; se la trasmissione di una stazione dura meno, questa fa padding.

- Infine, se necessario, vengono inviati gli ack; *multi-station block acknowledgment (Multi-STA Block ack)* a tutte le stazioni che ne hanno fatto richiesta.

In banda 2.4GHz sono presenti *14 canali*, ma allo stesso tempo *non sovrapposti* possono essercene solo *3* (Canale 1, 6, 11). In quanto i canali sono larghi $20"MHz"$, ma la banda totale è di $83.5"MHz"$, quindi si ha una sovrapposizione tra i canali.


== 4.5 WLAN Security

All'interno di $"802.11"$ sono definite delle feature per la sicurezza. Per definizione il canale radio è molto esposto, tutti possono ascoltare/inviare su un canale intrinsecamente broadcast. Di conseguenza si ha la necessità di cifrare il canale anche a livello di data link.

*Wired Equivalent Privacy (WEP)*:
Caratteristiche:
- Algoritmo di cifratura RC4.
- *Opzionale*, non è obbligatorio attivarlo.
- Assenza di un sistema di gestione delle chiavi, tutto il traffico era cifrato allo stesso modo (la chiave non è la password wi-fi).
- Tutto il traffico viene cifrato con la stessa chiave.

*Robust Security Network (RSN)*: Per sopperire alle lacune di WEP è stato introdotto un emendamento allo standard $"802.11i"$. Viene definito l' RSN, con al suo interno diversi servizi:
- *Access control*: impone l'utilizzo di protocolli di sicurezza e assiste lo scambio delle chiavi.
- *Authentication*: definisce lo scambio tra utente e Authentication Server (AS) e genera le chiavi temporanee per la comunicazione sul canale radio.
- *Privacy with message integrity*: il payload MAC (LLC PDU) viene cifrato e viene aggiunto al messaggio una porzione dedicata al controllo dell'integrità.

#nota()[
  L'header MAC *non viene cifrato*, in quanto è necessario per il corretto instradamento dei pacchetti. La cifratura avviene solo a livello di payload, con l'aggiunta di un campo dedicato al controllo dell'integrità del messaggio (Message Integrity Check).
]

#align(center)[
  #image("../assets/Schema-Sicurezza.png", width: 60%)
]

L'autenticazione e la gestione delle chiavi avvengono in 4 fasi:

- *Discovery*: Consiste nella negoziazione tra AP e STA per decidere se è possibile stabilire una connessione e, in caso affermativo, quali servizi di sicurezza utilizzare. I passaggi sono:
  - L'AP manda il beacon, il quale fornisce anche i servizi RSN disponibili (la modalità di accesso alla cella).
  - Il dispositivo (STA) tramite il beacon capisce quali sono i servizi RSN che può utilizzare (negoziano le capabilities di ognuno, si decide la policy da utilizzare).
  - Associazione AP e STA, arrivano a un accordo sulle funzionalità di sicurezza da utilizzare  (sia AP che STA possono decidere di negare la connessione).

- *Authentication*: Consiste nell'autenticazione della stazione (STA) da parte dell'AP, al fine di garantire che solo dispositivi autorizzati possano accedere alla rete. I passaggi sono:
  - L'AP richiede al STA l'autenticazione tramite la comunicazione con un *Authentication Server (AS)*.
  - Il server può essere remoto in caso di utilizzo di *Extensible Authentication Protocol (EAP)*.

- *Key management*: generazione delle chiavi specifiche per il singolo dispositivo.

- *Protected data transfer*: una volta ottenuta la chiave, si comincia la comunicazione cifrata.
- Chiusura della connessione.

In particolare, la fase di *authentication* e *key management* è quella più complessa, in quanto è necessario garantire la sicurezza della chiave di sessione (KS) generata, evitando che un attaccante possa intercettarla o indovinarla:

#align(center)[
  #image("../assets/key-exchange.png", width: 70%)
]


+ Viene inviato un *nonce* (numero casuale) da AP a Client. Esso serve a garantire l'unicità della sessione e a prevenire attacchi di replay, in quanto ogni sessione avrà un nonce diverso.

+ La chiave di *sessione $"KS"$* viene calcolata dal client a partire dai MAC address, i nonce e la master key (generata a partire dalla password della rete). La master key è un segreto condiviso tra AP e Client, derivato dalla password della rete Wi-Fi.

  #nota()[
    Utilizzando i MAC address e i nonce, si garantisce che la chiave di sessione sia unica per ogni connessione, anche se la stessa password viene utilizzata da più dispositivi.
  ]

  Una volta calcolata la chiave di sessione, il client invia al AP un messaggio di autenticazione, che include il nonce del client e un *Message Integrity Check (MICS)*, che è una sorta di codice di integrità del messaggio dipendente dalla sessione (quindi, in parte, dalla session key). Questo MICS serve a garantire che il messaggio non sia stato alterato durante la trasmissione.

+ *L'AP* una volta ricevuto il messaggio di autenticazione, può *calcolare la stessa chiave di sessione* ($"KS"$) del client utilizzando le stesse informazioni (MAC address, nonce e master key). Se l'AP riesce a calcolare la stessa $"KS"$, significa che il client è autenticato correttamente.

  L'AP invia il MICS e la *chiave di gruppo $"KG"$* al client, cifrandola con la chiave di sessione $"KS"$. La chiave di gruppo è utilizzata per cifrare i dati trasmessi a tutti i dispositivi nella rete, mentre la chiave di sessione è specifica per la comunicazione tra AP e client.


+ Il Client verifica che l'AP ha calcolato la chiave di sessione $"KS"$ in modo corretto, confrontando il MICS ricevuto con quello che lui stesso ha calcolato. Se i due *MICS corrispondono*, significa che l'AP è autenticato correttamente e che la chiave di sessione è valida.

  Il Client risponde con un messaggio di conferma (ack), cifrato con la chiave di sessione $"KS"$. Questo ack serve a confermare che il client ha ricevuto correttamente la chiave di gruppo e che è pronto per iniziare la comunicazione cifrata.


#nota()[
  Il segreto per la sicurezza sta nella *master key* (il resto sarebbe pubblicamente accessibile). Il presupposto è che l'attaccante non ne sia a conoscenza. Nelle varie versioni di EAP cambia il metodo con cui la chiave viene generata, per mantenere valido questo presupposto.

  Attacchi di tipo MitM vengono evitati grazie ad integrity check e nonce.
]

=== Protezione dati

Lo standard $"802.11i"$ considera $2$ alternative:

- *TKIP (WPA)*: aggiunge un codice di integrità a $64$ bit usando MAC di sorgente e destinazione; per la confidenzialità viene usato RC4; cambiamenti solo software rispetto a WEP.

- *CCMP (WPA-2)*: integrità della cifratura tramite cipher-block chaining (CBC); integrità e confidenzialità tramite AES 128 bit.

Tra i due cambia l'algoritmo di cifratura:
- Per il primo non serve cambiare nulla a livello hardware
- Per il secondo serve il supporto a CBC con AES.


== WiFi Protected Setup (WPS)

Viene usato per *evitare di utilizzare la password*, su alcuni dispositivi tale funzionalità può essere comoda.

All'interno del protocollo ci sono $3$ tipi di dispositivi:

+ *Registrer*: entità che autorizza o revoca una stazione (AP o esterno)

+ *AP*

+ *Enrollee*: la stazione che vuole accedere

In questo protocollo non è necessario conoscere la password, ma è necessario che il dispositivo Enrollee sia autorizzato da un *Registrer* (che può essere l'AP o un dispositivo esterno).

Le modalità di attivazione di un dispositivo sono due:
- *PIN*: può essere dell'AP da immettere sul dispositivo Enrollee, oppure dell'Enrollee da immettere sull'AP. In questo modo si autorizza il dispositivo a connettersi alla rete senza dover inserire la password.

- *Push Button*: pressione di un bottone su AP ed Enrollee, la procedura rimane attiva per massimo $2$ minuti. Associazione FIFO (il primo che entra è autenticato).
