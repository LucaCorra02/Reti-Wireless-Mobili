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

=== Implementazione
#figure(
  image("/assets/implementazione.png", width: 80%),
  caption: [Schema dell'implementazione dell'Orthogonal Frequency Division Multiplexing.],
)

#pagebreak()

#nota[
  1. *Trasmettitore (parte alta)*:
  Il _Bit Stream_, come detto in precedenza, passa da *seriale* a *parallelo*, facendolo diventare un insieme di tanti flussi lenti per essere inviato alle varie sotto-portanti. Successivamente, si utilizza l'*IFFT* per passare dal dominio delle frequenze a quello del tempo e il risultato fa in modo tale da produrre un blocco di campioni digitali (*_Parallel to Serial_*) da spedire uno a uno. Infine, viene aggiunto un prefisso ciclico, che ha lo scopo di proteggere da "echi" che disturberebbero il segnale.

  2. *Canale di trasmissione (freccia curva)*:
  Qui il segnale viaggia nell'aria e, dal trasmettitore, arriva al ricevitore.

  3. *Ricevitore (parte bassa)*:
  Per prima cosa, viene rimosso il prefisso aggiunto al termine delle operazioni del trasmettitore. In seguito, la trasformazione *_Serial to Parallel_* prepara i campioni per l'elaborazione matmatica, grazie all'*FFT* e viene ricomposto infine il flusso di bit tramite la fase di *_Parallel to Serial_*.
]

#attenzione[
  In generale, *Multiple Access* $!=$ *Multiplexing*: far passare più segnali contemporaneamente non significa far comunicare più utenti allo stesso tempo.
]

== Spread Spectrum
Tradotto letteralmente sarebbe "_Spettro Espanso_", questo perché è una tecnica che consiste nel trasmette un segnale occupando uno spettro di frequenze *più ampio*. Le motivazioni dell'utilizzo di questa tecnica sono le seguenti:
- *Segnale più robusto*: informalmente, possiamo dire che spalmando il segnale lungo una banda più ampia, questo lo renda più resiliente a rumore e interferenze. 
- *Cifratura del segnale*: essendo una tecnica nata in ambito militare, la sicurezza collegata al segnale è di primaria importanza. Solo trasmettitore e ricevitore conoscono infatti il _codice di spreading_ e, anche se non si tratta di una vera e propria crittografia che protegge i dati matematicamente, è una sorta di "mimetismo fisico" che protegge la comunicazione.
- *Accesso multiplo*: molti utenti possono utilizzare la stessa banda contemporaneamente senza interferenze.

#nota[
  Per quanto riguarda il concetto di *accesso multiplo*, ci si rifà al concetto di utilizzo di codici diversi per potersi sovrapporre, durante la comunicazione, senza disturbarsi.
  #esempio[
    Un esempio informale e intuitivo per capire questo aspetto è il seguente: immaginiamo di essere in una stanza assieme ad altre persone e che tutte parlino allo stesso tempo. Supponiamo inoltre che queste persone siano divise in coppie e che ognuna di esse parli una lingua diversa. Il filtro linguistico permette di "non impazzire" (è il concetto di *ortogonalità*): se io sono il ricevitore della prima coppia, che parla in italiano, il mio cervello è settato per comprendere solo quella lingua. Tutto ciò che mi arriva in cinese o finlandese, ad esempio, lo percepirò solo come rumore di fondo e non rappresenta in alcun modo l'informazione.
  ]
]

Concettualmente, lo spettro espanso è possibile schematizzarlo come segue:
#figure(
  image("/assets/Spread_Spectrum.png", width: 80%),
  caption: [Schema dello _Spread Spectrum_.],
)

