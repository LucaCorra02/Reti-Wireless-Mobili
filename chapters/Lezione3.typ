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

=== Frequency Hopping Spread Spectrum (FHSS)
Si tratta di una tecnica, che sfrutta lo _Spread Spectrum_, che utilizza il salto ("_hopping_") di frequenza per la trasmissione dell'informazione. È stata utilizzata per
le trasmissioni *Bluetooth* e per le prime reti *Wi-Fi*.

Tecnicamente, consiste nel determinare, ad ogni intervallo di tempo prestabilito, quale debba essere la frequenza utilizzata per la trasmissione del segnale. La frequenza viene cambiata in maniera pseudo-casuale (ad esempio, con le trasmissioni *Bluetooth 802.15.1*, la frequenza muta ogni $625 mu s$).

Schema di funzionamento:

#figure(
  image("/assets/FHSS.png", width: 80%),
  caption: [Schema del _Frequency Hopping Spread Spectrum_.],
)

Dallo schema, è possibile notare come la *Channel Table* debba essere la medesima sia per _TX_ sia per _RX_: permette di scegliere la frequenza da utilizzare, in base ad un valore pseudo-casuale. Il tempo di _hopping_ è predefinito, ma serve un _seed_ per la frequenza di valori pseudo-casuali usati per determinare la frequenza di cui sopra.

Il vantaggio principale consiste nella resistenza al *rumore/jamming*: una frequenza sola compromessa, non compromette potenzialmente il deterioramente di tutta la trasmissione. È inoltre una tecnica particolarmente sicura poiché, se un utente malintenzionato volesse ascoltare la trasmissione, non disponendo della sequenza di _hopping_, potrebbe leggere solo alcuni pezzi di messaggi. 

#esempio[
  Come detto precedentemente, questa tecnica è stata fondamentale per lo sviluppo delle comunicazioni *Bluetooth*. Consiste infatti nella divisione della banda, da $2.4 "GHz"$, in 79 canali. Vengono effettuati 1600 salti al secondo; questo è il motivo grazie al quale, se ci si trova all'interno di una stanza molto affollata tra apparecchi e *Wi-Fi*, il segnale delle cuffie *Bluetooth* che sto utilizzando è un segnale praticamente impossibile da colpire in maniera continuativa per disturbarne la comunicazione.
]

=== Direct Sequence Spread Spectrum (DSSS)
Possiamo pensare alla tecnica di *_Direct Sequence Spread Spectrum_* come una vera e propria _diliuzione_ del segnale: data un sequenza di $N$ bit, ognuno di essi viene rappresentato da un insieme di bit utilizzando un codice di _spread_ pseudo-casuale.

Intuitivamente, è possibile notare un problema che potrebbe nascere dall'uso di questa tecnica: se ho, ipoteticameente, un secondo di tempo per poter trasmettere un bit, dopo che quest'ultimo verrà trasformato in una _sequenza di chip_ (e quindi sarà formato da più di un solo bit), il tempo che avevo inizialmente a disposizione per la trasmissione del singolo bit non varia e dovrà essere utilizzato anche per trasmetterne di più.

Per ovviare a questo problema, le _sequenze di chip_ si fanno "durare meno": durano quindi $1/n$ del tempo dei bit di informazione. Inoltre, per il mantenimento dello stesso *data rate*, si utilizza $n$ volte la banda (con $n$ che equivale al fattore di _spreading_).

Infine, si effettua lo `XOR` degli $n$ bit utilizzati trasformando il bit singolo. L'utilizzo dello `XOR` è fondamentale, in quanto si tratta di un'operazione *reversibile*.

Un altro aspetto fondamentale è che, come ovvio che sia, ricevitore e trasmettitore conoscono la *sequenza do spreading* ed è così possibile, assieme all'inverso dello `XOR`, la decifratura del segnale trasmesso.

#nota[
  Schema di funzionamento ad alto livello:
  $
    "bit" -> "spread code" -> "M bit/Sequenza di chip" -> "bit" xor "Sequenza" -> "Info trasmessa"
  $
]

#pagebreak()

#esempio[
  #align(center)[
    #table(
      columns: (auto, 1.5em, 1.5em, 1.5em, 1.5em, 1.5em, 1.5em, 1.5em, 1.5em),
      inset: 5pt,
      align: center + horizon,
      stroke: 0.5pt,

      [*Bit informazione*], table.cell(colspan: 4)[*1*], table.cell(colspan: 4)[*0*],

      [*Sequenza di chip*], [0], [1], [1], [1], [0], [0], [1], [0],

      [*Trasmesso (XOR)*], [1], [0], [0], [0], [0], [0], [1], [0]
    )
  ]

  #figure(
  image("/assets/DSSS.png", width: 80%),
  caption: [Nello schema è possibile osservare il #text(fill: green)[segnale originale], la #text(fill: blue)[sequenza di chip] e #text(fill: red)[ciò che viene inviato al ricevitore].],
)
]

=== Code Division Multiple Access (CDMA)
Basandosi sullo *Spread Spectrum*, questa tecnica prevede ovviamente che agli utenti venga permesso di trasmettere contemporaneamente e sulla stessa frequenza senza disturbarsi. Il concetto di base, in questo caso, è che ogni utente abbia il proprio *codice di spreading*, in modo che siano ortogonali.

In questo caso si utilizza, al posto dello zero, il valore -1, per rendere più comodi i conti e le questioni legate proprio all'ortogonalità.

#nota[
  Due *codici di spreading* si dicono ortogonali se, sommati, la loro somma è zero per ogni bit che compone il risultato.
]

Come per la tecnica analizzata precedentemente, anche in questo caso non viene inviato il singolo bit, ma la stringa "trasformata", che il ricevitore avrà la possibilità di decifrare opportunamente.

Esempi di *sequenze di spreading*:
- *_Walsh_*: sono ortogonali e matematicamente "perfette". Non ci può quindi essere interferenza fra gli utenti nell'invio delle informazioni, ma allo stesso tempo il numero di queste sequenze è *limitato* ed è possibile generare solo 64 codici $!=$.
- *_PN, Gold, Kasami_*: questi codici *non* sono ortogonali, ma sono quasi infiniti. Si utilizzano tipicamente nei casi in cui vi sono tantissimi utenti in un ambiente e si accetta di avere rumore/interferenze pur di connettere tutti.

#attenzione[
  In questa tecnica, il trasmettitore è *anarchico*: si preoccupa solo di inviare le informazioni, senza preoccuparsi in alcun modo delle interferenze. È infatti compito del ricevitore di distinguere correttamente tutto ciò che gli arriva.
]

Il ricevitore calcola inoltre la seguente funzione:
$ 
  s_u(d) = sum_(i=1)^k d_i dot c_i 
$
Dove:
- $d ->$ Dati ricevuti, ovvero ciò che arriva all'antenna;
- $c ->$ Codice/Chip, ovvero la _sequenza di spreading_ che il ricevitore ha in memoria;
- $k ->$ Lunghezza del codice, il numero di chip da cui è composto.

È possibile considerare questa formula come un "filtro matematico": i segnali che corrispondono effettivamente al codice che ha il trasmettitore, danno un risultato grande, altrimenti uno uguale o molto vicino a zero.

#esempio[
  Esempio con 3 utenti:
  #align(center)[
    #table(
      columns: (auto, 2em, 2em, 2em, 2em, 2em, 2em),
      inset: 6pt,
      align: (col, row) => (if col == 0 { left } else { center } + horizon),
      stroke: 0.5pt + black,
      
      [User A], [1], [-1], [-1], [1], [-1], [1],
      [User B], [1], [1], [-1], [-1], [1], [1],
      [User C], [1], [1], [-1], [1], [1], [-1]
    )
  ]

  Ognuno di questi utenti ha a propria disposizione un codice univoco lungo 6 chip (di conseguenza, facendo riferimento alla formula di cui sopra, $k = 6$).

  Supponiamo ora che l'utente A voglia trasmettere il primo 1: deve spedire il codice così com'è (altrimenti avrebbe dovuto inviare il codice moltiplicato per -1). 

  Il ricevitore decodifica ciò che gli è arrivato e utilizza il codice, che ha in memoria, per decifrare:

  #align(center)[
    #table(
      columns: (auto, 2em, 2em, 2em, 2em, 2em, 2em, 2.5em),
      inset: 6pt,
      align: (col, row) => (if col == 0 { left } else { center } + horizon),
      stroke: 0.5pt + black,

      [Transmit (data bit = 1) A], [1], [-1], [-1], [1], [-1], [1], [],
      [Receiver codeword A], [1], [-1], [-1], [1], [-1], [1], [],
      [Multiplication], [1], [1], [1], [1], [1], [1], [=6]
    )
  ]

  Essendo il risultato, pari a 6, il massimo possibile (perché $k = 6$), allora sicuramente è stato ricevuto tutto correttamente.

  Ovviamente, se venisse usato il codice di A per decifrare un messaggio di B, il risultato sarebbe molto diverso:

  #align(center)[
    #table(
      columns: (auto, 2em, 2em, 2em, 2em, 2em, 2em, 2.5em),
      inset: 6pt,
      align: (col, row) => (if col == 0 { left } else { center } + horizon),
      stroke: 0.5pt + black,

      [Transmit (data bit = 1) B], [1], [1], [-1], [-1], [1], [1], [],
      [Receiver codeword A], [1], [-1], [-1], [1], [-1], [1], [],
      [Multiplication], [1], [-1], [1], [-1], [-1], [1], [=0]
    )
  ]

  In questo caso il risultato è 0, di conseguenza il ricevitore può essere sicuro che non sia stato A a trasmettere, ma un altro utente.
]

Più è alto il numero di utenti, maggiore dev'essere lo *_spreading factor_* (la lunghezza del codice), riducendo al contempo sia il rischio di interpretazioni sbagliate delle informazioni arrivate che del _data rate_ del dispositivo.

#nota[
  Questo sistema funziona correttamente se i segnali ricevuti hanno circa la stessa potenza, altrimenti non verrebbero interpretati correttamente i segnali inviati; da qui nascono difficoltà di trasmissione per dispositivi che si trovano lontani. Per ovviare a questo problema, che prende il nome di *Near-Far Problem*, si utilizzano potenze diverse in base alla distanza (di contro, si consuma più batteria del dispositivo).
]