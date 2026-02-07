#import "../template.typ": *

= ISM Band

*ISM* (Industrial, Scientific, Medical) si tratta di uno spettro riservato per usi industirali, scientifci e medici.\
Chiunque voglia costruire un dispositivo che comunica tramite questo range di frequenze non deve acquistare una licenza per trasmettere (non è ad uso esclusivo dell'operatore), è quindi *unlicensed*.

#esempio()[
  Ad esempio il microonde e il wifi lavorano sulla stessa frequenza. Il microonde potrebbe andare a interferire con il segnale wifi o bluetooth.
]
La banda ISM viene utilizzata anche per scopi non-ISM:
- Bluetooth: ISM $2.4 "Ghz"$
- WiFi: ISM $2.4 "Ghz" "/" 5 "Ghz"$
- ZigBee: ISM $915 "Mhz" "/" 2.4 "Ghz"$

== Pulse Code Modulation (PCM)

#informalmente()[
  L'idea è campionare un segnale al fine di ottenere tutte le frequenze di cui è composto.
]

Si tratta di una codifica *lossless* per onde. Partendo da un segnale continuo, il metodo utilizza un campionamento dell'ascissa del segnale a intervalli regolari; i valori letti vengono poi *quantizzati* (valore più vicino) in ordinata e infine digitalizzati (in genere codificati in forma binaria). Tanto è più fitto il campionamento e di conseguenza la "griglia" di punti, tanto più siamo in grado di determinare i vari livelli del segnale.

#attenzione()[
  La frequenza di campionamento *deve* essere il doppio della frequenza massima del campione ( Per il teorema di campionamento di Shannon)
]

#esempio()[
  #align(center)[
    #block(width: 360pt, height: 200pt)[
      #let w = 300pt
      #let h = 170pt
      #let offsetX = 35pt
      #let offsetY = 10pt

      // Bordo del grafico
      #place(dx: offsetX, dy: offsetY, rect(width: w, height: h, stroke: 1pt + black, fill: white))

      // Griglia orizzontale e etichette Y
      #for i in range(0, 17) {
        let yPos = offsetY + i * h / 16
        place(dx: offsetX, dy: yPos, line(length: w, stroke: 0.5pt + gray.lighten(40%)))
        // Etichette asse Y (invertite perché Y cresce verso il basso)
        let label = 16 - i
        place(dx: offsetX - 20pt, dy: yPos - 5pt, text(size: 8pt, str(label)))
      }

      // Griglia verticale
      #for i in range(0, 26) {
        let xPos = offsetX + i * w / 25
        place(dx: xPos, dy: offsetY, line(length: h, angle: 90deg, stroke: 0.5pt + gray.lighten(40%)))
      }

      // Dati del segnale campionato
      #let pts = (
        (0, 8),
        (1, 9),
        (2, 11),
        (3, 13),
        (4, 14),
        (5, 15),
        (6, 15),
        (7, 15),
        (8, 14),
        (9, 13),
        (10, 12),
        (11, 10),
        (12, 8),
        (13, 5),
        (14, 3),
        (15, 2),
        (16, 1),
        (17, 0),
        (18, 0),
        (19, 0),
        (20, 1),
        (21, 2),
        (22, 4),
        (23, 6),
        (24, 7),
      )

      // Disegna le linee rosse tra i punti campionati
      #for i in range(pts.len() - 1) {
        let p1 = pts.at(i)
        let p2 = pts.at(i + 1)
        let x1 = offsetX + p1.at(0) * w / 25
        let y1 = offsetY + h - (p1.at(1) * h / 16)
        let x2 = offsetX + p2.at(0) * w / 25
        let y2 = offsetY + h - (p2.at(1) * h / 16)

        // Converti in numeri puri dividendo per 1pt
        let dx = (x2 - x1) / 1pt
        let dy = (y2 - y1) / 1pt
        let dist = calc.sqrt(dx * dx + dy * dy) * 1pt
        let angle = calc.atan2(dx, dy)

        place(dx: x1, dy: y1, line(length: dist, angle: angle, stroke: 2pt + red))
      }

      // Disegna i punti blu sui valori campionati
      #for pt in pts {
        let x = offsetX + pt.at(0) * w / 25
        let y = offsetY + h - (pt.at(1) * h / 16)
        place(dx: x - 3pt, dy: y - 3pt, circle(radius: 3pt, fill: blue, stroke: none))
      }
    ]
  ]
  L'onda $mr("sinusoidale")$ è campionata a intervalli regolari asse $X$ (punti $mb("blu")$). Per ogni campione, uno dei valori disponibili sull'asse delle $Y$, in genere viene approssimato al più vicino. Questo produce una rappresentazione discreta del segnale di ingresso che può essere facilmente codificata in digitale.\
  In figura i valori campionati sono quantizzati con i valori $8, 9, 11, dots$. Codificando questi valori in binario otteniamo parole di $4$ bit.

  Per la voce dovremmo utilizzare frequenza di campionamento PCM a $8$ bit $8000"Hz"-> 64 "Kbps"$ (il segnale vole è a $300-3400"HZ"$). Con $8$ bit possiamo coodificare $256$ livelli di segnale.
]

= Standard bluetooth ($802.15.1$)

Bluetooth aderisce come tutte le altre tecnologie per le comunicazioni a corto raggio allo standard $802.15.x$. In particolare, bluetooth rientra nello standard $802.15.1$.

Un'altra tecnologia che usa questo standard sono le Visible-Light-Comunication (VLC), trasmissione del segnale attraverso la luce. Altamente direzionale e mascherabile.

La struttura di bluetooth è *fortemente gerarchica*. I dispositivi sono all'interno di una *_piconet_*, composta da:
- Un solo *master node*: Esso ha il compito di coordinare l'intera attività della rete.
- Uno o più *slave*: dispositivi appartenenti alla rete.

Si tratta quindi di una topologia di rete master-slave. Gli slave comunicano solo con quanto deciso dal master, sia in termini di tempo che di frequenze.

Inoltre, bluetooth presenta le seguenti caratteristiche:
- *Corto raggio* (10-50 metri)
- Lavora sulla banda ISM $2.4 "GHz"$ (la stessa del WiFi)
- Il data rate può variare ($2.1 "Mbps"-24 "Mbps"$)

Solitamente questa tecnologia viene utilizzata per sostituire i cavi, come punto di accesso per dati e voce e per comunciazione ad hoc con altri dispositivi bluetooth.

Inoltre, i dispositivi bluetooth si differenziano in base alla classe di potenza:
- Power Class 1: $100 "mW"$ (100 metri senza ostacoli)
- Power Class 2: $2.5 "mW"$ (10 metri)
- Power class 3: $1 "mW"$ (1-2 metri)


== Stack di bluetooth

L'architettura di bluetooth è composta dalle seguenti parti:
- Livello fisico.
- Livello Data-Link, con il relativo layer di controllo.
- Livello _adattatore_, permette di convogliare e adattare tutto il traffico proveniente dall'esterno.

#align(center)[
  #cetz.canvas(length: 1.2cm, {
    import cetz.draw: *

    // Definizione colori
    let core-color = rgb("#2E4A6F")
    let cable-color = black
    let telephony-color = rgb("#8B4545")
    let adopted-color = rgb("#6B4545")

    // Funzione helper per disegnare box
    let draw-box(x, y, w, h, txt, fill-color, txt-color: white, txt-size: 9pt) = {
      rect((x, y), (x + w, y + h), fill: fill-color, stroke: black)
      content((x + w / 2, y + h / 2), text(size: txt-size, fill: txt-color, weight: "bold", txt))
    }

    // Legenda (in alto a sinistra)
    let legend-x = 3
    let legend-y = 11
    let legend-box-size = 0.4
    let legend-spacing = 0.5

    draw-box(legend-x, legend-y, legend-box-size, legend-box-size, "", core-color)
    content(
      (legend-x + legend-box-size + 0.2, legend-y + legend-box-size / 2),
      text(size: 10pt, "Core protocols"),
      anchor: "west",
    )

    draw-box(legend-x, legend-y - 1 * legend-spacing, legend-box-size, legend-box-size, "", cable-color)
    content(
      (legend-x + legend-box-size + 0.2, legend-y - 1 * legend-spacing + legend-box-size / 2),
      text(size: 10pt, "Cable replacement protocol"),
      anchor: "west",
    )

    draw-box(legend-x, legend-y - 2 * legend-spacing, legend-box-size, legend-box-size, "", telephony-color)
    content(
      (legend-x + legend-box-size + 0.2, legend-y - 2 * legend-spacing + legend-box-size / 2),
      text(size: 10pt, "Telephony control protocols"),
      anchor: "west",
    )

    draw-box(legend-x, legend-y - 3 * legend-spacing, legend-box-size, legend-box-size, "", adopted-color)
    content(
      (legend-x + legend-box-size + 0.2, legend-y - 3 * legend-spacing + legend-box-size / 2),
      text(size: 10pt, "Adopted protocols"),
      anchor: "west",
    )

    // Architettura dei protocolli (parte destra)
    let base-x = 7
    let base-y = 5

    // Bluetooth Radio (livello più basso)
    draw-box(base-x, base-y, 8, 0.6, "Bluetooth Radio", core-color, txt-size: 12pt)

    // Baseband
    draw-box(base-x, base-y + 0.7, 8, 0.6, "Baseband", core-color, txt-size: 12pt)

    // LMP (Link Manager Protocol)
    draw-box(base-x + 3.5, base-y + 1.4, 4.5, 0.5, "Link Manager Protocol (LMP)", core-color, txt-size: 11pt)

    // Linea rossa tratteggiata (divisione HW/SW)
    let line-y = base-y + 2.0
    set-style(stroke: (paint: red, thickness: 2pt, dash: "dashed"))
    line((base-x + -2, line-y), (base-x + 10, line-y))
    set-style(stroke: (paint: black, thickness: 1pt))

    // L2CAP
    let l2cap-y = base-y + 2.1
    draw-box(
      base-x,
      l2cap-y,
      8,
      0.6,
      "Logical Link Control and Adaptation Protocol (L2CAP)",
      core-color,
      txt-size: 10pt,
    )

    // Audio (a sinistra, separato)
    let audio-x = base-x - 2.5
    let audio-y = base-y + 2.3
    draw-box(audio-x, audio-y + -0.1, 1.2, 0.5, "Audio", adopted-color, txt-size: 11pt)

    // Control (a destra di LMP)
    let control-x = base-x + 8.2
    let control-y = base-y + 2.2
    draw-box(control-x, control-y, 1.5, 0.5, "Control", adopted-color, txt-size: 11pt)

    // RFCOMM
    let rfcomm-x = base-x + 0.5
    let rfcomm-y = base-y + 2.8
    draw-box(rfcomm-x, rfcomm-y, 4.5, 0.5, "RFCOMM", cable-color, txt-size: 12pt)

    // UDP/TCP + IP + PPP (colonna sinistra sopra RFCOMM)
    let udp-x = base-x + 0.5
    let udp-y = base-y + 3.5
    draw-box(udp-x, udp-y, 1.3, 0.5, "UDP/TCP", adopted-color, txt-size: 10pt)

    let ip-y = base-y + 4.1
    draw-box(udp-x, ip-y, 1.3, 0.5, "IP", adopted-color, txt-size: 11pt)

    let ppp-y = base-y + 4.7
    draw-box(udp-x, ppp-y, 1.3, 0.5, "PPP", adopted-color, txt-size: 11pt)

    // vCard/vCal
    let vcard-y = base-y + 5.4
    draw-box(udp-x, vcard-y, 1.3, 0.5, "vCard/vCal", adopted-color, txt-size: 9pt)

    // OBEX
    let obex-y = base-y + 6.0
    draw-box(udp-x, obex-y, 1.3, 0.5, "OBEX", adopted-color, txt-size: 11pt)

    // AT commands (centro sopra RFCOMM)
    let at-x = base-x + 2.0
    let at-y = base-y + 3.5
    draw-box(at-x, at-y, 1.4, 1.6, "AT\ncommands", telephony-color, txt-size: 10pt)

    // WAE + WAP (a destra, sopra L2CAP)
    let wae-x = base-x + 3.5
    let wae-y = base-y + 2.8
    draw-box(wae-x, wae-y + 0.8, 1.3, .8, "WAE", adopted-color, txt-size: 11pt)
    draw-box(wae-x, base-y + 0.8 + 3.7, 1.3, 0.6, "WAP", adopted-color, txt-size: 11pt)

    // TCS BIN (a destra)
    let tcs-x = base-x + 5.5
    let tcs-y = base-y + 4.4
    draw-box(tcs-x, tcs-y + 0.4, 1.3, 0.7, "TCS BIN", telephony-color, txt-size: 10pt)

    // SDP (estrema destra)
    let sdp-x = base-x + 7.0
    let sdp-y = base-y + 2.8
    draw-box(sdp-x, sdp-y + 2, 1.8, 0.7, "SDP", core-color, txt-size: 13pt)

    // Linee di connessione (nere)
    set-style(stroke: (paint: black, thickness: 1.5pt))

    // Radio -> Baseband (centro)
    line((base-x + 4, base-y + 0.6), (base-x + 4, base-y + 0.7))

    // Baseband -> LMP (centro)
    line((base-x + 4, base-y + 1.3), (base-x + 4, base-y + 1.4))

    // Baseband -> Audio (sinistra, linea diretta)
    line((audio-x + 0.65, audio-y + -0.1), (audio-x + 0.65, base-y + 1.0))
    line((base-x, base-y + 1.0), (audio-x + 0.6, base-y + 1.0))

    // Baseband -> L2CAP (lato sinistro del baseband)
    line((base-x + 1, base-y + 1.3), (base-x + 1, l2cap-y))

    // LMP -> Control (a destra)
    line((control-x + 0.75, control-y), (control-x + 0.75, base-y + 1.6))

    line((14.9, control-y + -0.6), (control-x + 0.75, base-y + 1.6))


    // L2CAP -> RFCOMM (lato sinistro)
    line((rfcomm-x + 1, l2cap-y + 0.6), (rfcomm-x + 1, rfcomm-y))

    // UDP/TCP -> IP -> PPP -> RFCOMM (stack verticale a sinistra)
    line((udp-x + 0.65, udp-y), (udp-x + 0.65, rfcomm-y + 0.9))

    // AT commands -> RFCOMM (centro)
    line((at-x + 0.7, at-y), (at-x + 0.7, rfcomm-y + 0.5))

    // vCard/vCal -> OBEX -> RFCOMM (stessa colonna UDP/TCP)
    line((udp-x + 0.65, vcard-y + -2.), (udp-x + 0.65, rfcomm-y + 0.4))

    // TCS BIN -> L2CAP (lato destro)
    line((tcs-x + 0.65, tcs-y + 0.4), (tcs-x + 0.65, l2cap-y + 0.6))

    // SDP -> L2CAP (estrema destra)
    line((sdp-x + 0.9, sdp-y + 2), (sdp-x + 0.9, l2cap-y + 0.6))
  })
]

Tutti i livelli $mb("blu")$ rappresentano i _core protocols_, ovvero le componenti sempre presenti in un qualsiasi dispositivo bluetooth. La linea $mr("rossa")$ divide la parte hardware da quella sofware.

#nota()[
  Completamente diverso dallo stack TCP/IP o ISO/OSI.
]

=== Layer Bluetooth Radio

Si tratta del livello fisico. Si occupa di ricevere e trasmettere radio frequenze, in particolare:
- Gestisce il *Frequency Hopping*.
- Decide lo schema di modulazione in base al canale
- Determina la potenza della trasmissione

Il Bluetooth opera nella banda dei $2.4 "GHz"$, che è molto affollata. Per evitare eccessive interferenze viene utilizzato il Frequency-hopping spread spectrum (*FHSS*) nel seguente modo:

- Divisione dello Spettro: La banda viene divisa in canali più piccoli. Tipicamente per bluetooth classico vengono creati $79$ canali da $1 "MHz"$ ciascuno.

- Hop: Il segnale non sta fermo. _Salta_ da un canale all'altro seguendo uno schema pseudocasuale. In particolare viene spostata la frequenza centrale:
$
  f_c = 2402 + underbrace(k, "Numero"\ "canale") "Mhz"
$

#nota()[
  Il trasmettitore (Master) e il ricevitore (Slave) devono conoscere esattamente lo stesso schema di salti. Questa sequenza è determinata dal clock del Master e dal suo indirizzo univoco.
]

I $mg("vantaggi")$ introdotti sono:
- Prevenzione delle interferenze
- Sicurezza: Resistenza a intercettazione e jamming. Un attaccante dovrebbe conoscere l'esatta sequenza di salti e la tempistica precis
- Coesistenza (CDMA).

=== Layer Baseband

Questo livello si occupa di :
- Stabilire la connessione con la _piconet_
- *Gestione dell'indirizzamento*. Ogni dispositivo nella rete presenta sia un'indirizzo hardware (del dispositivo) che uno logico (a livello di pico-net).
- Sincronizzazione e tempistiche di comunicazione. Vengono utilizzati Time division duplex (TDD) e Time division Multipe Access (TDMA).
- Gestisce la potenza della trasmissione (indicazioni passate a livello radio)

La gestione della comunicazione è *Duplex*. A differenza della trasmissione via cavo (cavo ethernet full-duplex), in ambito wireless non possiamo trasmettere e ricevere nello stesso istante.

=== Link Manager Protocol (LMP)

Si tratta di un *livello di controllo*. Non trasmette dati ma li gestisce:
- Configura i collegamenti tra dispositivi
- Gestisce i *collegamenti attivi*
- Aggiunge funzionalità di Sicurezza e cifratura

=== Logic Link Control and Adaptation Protocol (L2CAP)

Primo livello della parte _software_. Il compito principale è di fare da *adattatore* tra i procolli di servizio di livello superiore e il livello baseband.

Inoltre, offre ai livelli superiori serivzi _connectionless e connection-oriented_.

=== Service Discovery Protocol (SDP)

Permette di *gestire le informazioni sul dispositivo* corrente. In particolare conosce:
- Servizi disponibili sul dispositivo
- Caratteristiche del dispositivo

Inoltre, implementa un protocollo che permette ad un dispositivo che si conette alla piconet di trovare un dispositivo con un certo profilo (cosa è in grado di fare) aderente alle sue richieste.

=== Radio Frequency Communication (RFCOMM)

Si tratta di un protocollo che *emula una porta seriale*, simulando la comunicazione via cavo.

=== Altri livelli

Lo standard bluetooth intende *riutilizzare il maggior numero di protocolli già esistenti*. Bluetooth si occupa, tramite i suoi livelli proprietari, di convertire il mondo esterno in quello bluetooth.

In particolare lo standard bluetooth fornisce i cosi detti *_profili_*. Essi indicano un particolare modello di utilizzo dell'architettura (ovvero quali componenti utilizza per supportare determinate applicazioni).

#esempio()[
  Ad esempio per il trasferimento di file, un dispositivo deve seguire il seguente profilo:
  - Protocolli esterni: OBEX, RFCOMM
  - Layer interni: SDP, L2CAP
]

== Pico-net & Scatternet

Come detto in precedenza, nella piconet ogni dispositivo può avere due etichette:

- *Active slave (AS)*: Membro attivo della rete. Al massimo il suo indirizzo è su `3 bit` *Active Member Address (AMA)* ($0$ è il master).

  #nota()[
    Al più in una piconet ci possono essere $8$ ($2^3$) dispositivi che comunicano attiviamento (compreso il master).
  ]

- *Parked Salve (PS)*: Si tratta di un dispositivo che fa comunque parte della piconet ma *non ha accesso diretto alla comunicazione*. Può ascoltare i messaggi ma non può comunicare attivamente. Il master decide se risvegliarlo, assegnandoli un indirizzo AMA.\
  Ogni dispositivo possiede un *parked member address (PMA)* su `8 bit`, al massimo $255$ ($2^8$) dispositivi. L'indirizzo zeresimo è riservato al master.

- *Stanby Salve (SS)*: Ci sono anche dei dispositivi che sono conosciuti, ma sono esclusi dalla rete (*non sono indirizzati*). Essi possono essere in una quantità illimitata.

Siccome lo standard bluetooth permette ad *uno slave di far parte di più piconet*. In questo modo si viene a creare una *scatternet*: insieme di più piconet che condividono slave tra di loro.

#nota()[
  Ogni piconet è separata, ciascuna è gestita dal proprio master.
]

#align(center)[
  #cetz.canvas(length: 1cm, {
    import cetz.draw: *

    // Colori
    let node-color = rgb("#87CEEB")
    let text-color = black

    // Funzione per disegnare un nodo
    let draw-node(pos, label) = {
      rect(
        (pos.at(0) - 0.4, pos.at(1) - 0.3),
        (pos.at(0) + 0.4, pos.at(1) + 0.3),
        fill: node-color,
        stroke: 1pt + black,
        radius: 0.1,
      )
      content(pos, text(size: 10pt, fill: text-color, weight: "bold", label))
    }

    // Piconet A (cerchio tratteggiato sinistra) - SI INTERSECA con B
    circle((5, 5), radius: 3.8, stroke: (dash: "dashed", thickness: 1.5pt, paint: gray))
    content((2.2, 8.5), text(size: 11pt, fill: gray, weight: "bold", "Piconet A"))

    // Piconet B (cerchio tratteggiato destra) - SI INTERSECA con A
    circle((9, 5), radius: 3.8, stroke: (dash: "dashed", thickness: 1.5pt, paint: gray))
    content((11.8, 8.5), text(size: 11pt, fill: gray, weight: "bold", "Piconet B"))

    // Etichetta Scatternet (in alto al centro)
    content((7, 9.5), text(size: 12pt, fill: gray, weight: "bold", "Scatternet"))

    // Nodi Piconet A (solo nella parte sinistra)
    draw-node((2.5, 6.5), "SS") // Standby Slave in alto a sinistra
    draw-node((3.5, 5), "M") // MASTER A - nella Piconet A
    draw-node((3.2, 3.5), "AS") // Active Slave in basso a sinistra
    draw-node((3.8, 7.5), "PS") // Parked Slave in alto
    draw-node((5, 3), "AS") // Active Slave in basso

    // Nodo nell'intersezione (SOLO AS - condiviso tra le due piconet)
    draw-node((7, 5), "AS") // Active Slave al centro dell'intersezione - UNICO NODO CONDIVISO

    // Nodi Piconet B (solo nella parte destra)
    draw-node((10.5, 5), "M") // MASTER B - nella Piconet B
    draw-node((11.5, 6.5), "PS") // Parked Slave in alto a destra
    draw-node((10.8, 3.5), "SS") // Standby Slave in basso a destra
    draw-node((10.2, 7.5), "PS") // Parked Slave in alto
    draw-node((9, 3), "AS") // Active Slave in basso

    // Frecce - Piconet A (connessioni dal Master A agli slave)
    set-style(stroke: (paint: gray.darken(20%), thickness: 1.2pt))
    line((3.7, 4.8), (6.6, 4.9), mark: (end: ">")) // AS centrale -> Master A
    line((3.5, 4.7), (3.4, 3.8), mark: (end: ">")) // Master A -> AS basso
    line((3.8, 5.2), (4.7, 3.3), mark: (end: ">")) // Master A -> AS basso destro

    // Frecce tratteggiate per PS e SS (Piconet A)
    set-style(stroke: (paint: gray, thickness: 1pt, dash: "dashed"))
    line((2.8, 6.3), (3.3, 5.3)) // SS -> Master A
    line((3.8, 7.2), (3.5, 5.3)) // PS -> Master A

    // Frecce - Piconet B (connessioni dal Master B agli slave)
    set-style(stroke: (paint: gray.darken(20%), thickness: 1.2pt))
    line((10.1, 4.9), (7.4, 4.9), mark: (end: ">")) // AS centrale -> Master B
    line((10.5, 4.7), (9.3, 3.3), mark: (end: ">")) // Master B -> AS basso

    // Frecce tratteggiate per PS e SS (Piconet B)
    set-style(stroke: (paint: gray, thickness: 1pt, dash: "dashed"))
    line((11.2, 6.3), (10.7, 5.3)) // PS -> Master B
    line((10.4, 7.2), (10.5, 5.3)) // PS -> Master B
    line((10.5, 3.8), (10.5, 4.7)) // SS -> Master B
  })
]

== Comunicazione piconet

All'interno di una piconet possono esistere diversi schemi di comunicazione.

=== FH + TDD + TDMA

La comunicazione avviene tramite:
- *Frequency hopping (FH)*: sequenza specifica decisa dal master e condivisa all'interno della piconet.

- *Time Division Duplex (TDD)*: serve per implementare le due direzioni nella comunicazione $M -> S -> M$. In uno slot temporale la comunicazione avviene $M -> S$, mentre in quello successivo $S -> M$ e cosi via.

- *Time Division Multiple Access (TDMA)*: permette di gestire più dispositivi (slave) che vogliono comunicare all'interno della piconet. Lo spazio di comunicazione viene frammentato tra i vari dispositivi dal master, esso decide quale slave può parlare e per quanti slot di tempo.

#informalmente()[
  La trasmissione è come se fosse sincrona implicitamente, la sincronia viene gestita dal master.
]

#esempio()[
  Esempio di comunicazione tra master e $3$ slave. Tutti gli slave sono sincronizzati temporalmente e condividono la stessa frequenza di frequency hopping.

  #nota()[
    La direzione nella comunicazione è decisa a priori. Nelle frequenze pari (in termini di tempo e non di canali) il master parla con gli slave, viceversa negli slot di tempo dispari
  ]

  #figure[
    #align(center)[
      #cetz.canvas(length: 0.9cm, {
        import cetz.draw: *

        let slot-width = 1.0
        let row-height = 1.0
        let num-slots = 12
        let start-x = 1
        let start-y = 5.5

        // Funzione per disegnare un pacchetto trasmesso (rettangolo con tratteggio)
        let draw-transmitted(x, y, w, label) = {
          // Rettangolo con riempimento tratteggiato
          rect((x, y - 0.35), (x + w, y + 0.35), fill: rgb("#87CEEB"), stroke: 1.3pt + blue)
          // Aggiungi linee diagonali per simulare il tratteggio
          for i in range(0, int(w * 8)) {
            line((x + i * 0.15, y - 0.35), (x + i * 0.15 + 0.25, y + 0.35), stroke: 0.7pt + white)
          }
        }

        // Funzione per disegnare un pacchetto ricevuto (rettangolo tratteggiato)
        let draw-received(x, y, w, label) = {
          rect((x, y - 0.35), (x + w, y + 0.35), fill: none, stroke: (paint: blue, thickness: 1.3pt, dash: "dotted"))
          rect((x, y - 0.35), (x + w, y + 0.35), fill: rgb("#87CEEB").lighten(60%), stroke: none)
        }

        // Funzione per disegnare una freccia
        let draw-arrow(x, y, direction) = {
          if direction == "down" {
            line((x, y + 0.45), (x, y - 0.45), mark: (end: ">"), stroke: 1pt + black)
          } else {
            line((x, y - 0.45), (x, y + 0.45), mark: (end: ">"), stroke: 1pt + black)
          }
        }

        // Disegna gli slot temporali (etichette in alto)
        for i in range(num-slots) {
          let x = start-x + i * slot-width
          content((x + slot-width / 2, start-y + 0.7), text(size: 8pt, $f_#i$))
          // Linee verticali tratteggiate per separare gli slot
          if i > 0 {
            line((x, start-y - 4), (x, start-y + 0.4), stroke: (
              paint: gray.lighten(40%),
              dash: "dashed",
              thickness: 0.7pt,
            ))
          }
        }

        // Etichette delle righe
        content((start-x - 0.7, start-y), text(size: 9pt, weight: "bold", "Master"))
        content((start-x - 0.7, start-y - 1.3), text(size: 9pt, "Slave 1"))
        content((start-x - 0.7, start-y - 2.4), text(size: 9pt, "Slave 2"))
        content((start-x - 0.7, start-y - 3.5), text(size: 9pt, "Slave 3"))

        // Linee orizzontali per le timeline
        line((start-x, start-y), (start-x + num-slots * slot-width, start-y), stroke: 0.9pt + black, mark: (end: ">"))
        content((start-x + num-slots * slot-width + 0.4, start-y), text(size: 8pt, "Time"))

        line((start-x, start-y - 1.3), (start-x + num-slots * slot-width, start-y - 1.3), stroke: 0.9pt + black, mark: (
          end: ">",
        ))
        content((start-x + num-slots * slot-width + 0.4, start-y - 1.3), text(size: 8pt, "t"))

        line((start-x, start-y - 2.4), (start-x + num-slots * slot-width, start-y - 2.4), stroke: 0.9pt + black, mark: (
          end: ">",
        ))
        content((start-x + num-slots * slot-width + 0.4, start-y - 2.4), text(size: 8pt, "t"))

        line((start-x, start-y - 3.5), (start-x + num-slots * slot-width, start-y - 3.5), stroke: 0.9pt + black, mark: (
          end: ">",
        ))
        content((start-x + num-slots * slot-width + 0.4, start-y - 3.5), text(size: 8pt, "t"))

        // Master trasmette in slot pari (f0, f2, f4)
        draw-transmitted(start-x, start-y, slot-width, "f0")
        draw-transmitted(start-x + 2 * slot-width, start-y, slot-width, "f2")
        draw-transmitted(start-x + 4 * slot-width, start-y, slot-width, "f4")

        // Da f6 a f8: comunicazione prolungata con Slave 2 (3 slot consecutivi sulla stessa frequenza)
        draw-transmitted(start-x + 6 * slot-width, start-y, 3 * slot-width, "f6-f8")

        draw-transmitted(start-x + 10 * slot-width, start-y, slot-width, "f10")

        // Slave 1: riceve f0, trasmette f1
        draw-arrow(start-x + 0.5, start-y - 0.5, "down")
        draw-received(start-x, start-y - 1.3, slot-width, "f0")
        draw-arrow(start-x + 1.5, start-y - 1.3 + 0.4, "up")
        draw-transmitted(start-x + slot-width, start-y - 1.3, slot-width, "f1")

        // Slave 2: riceve f2, trasmette f3
        draw-arrow(start-x + 2 * slot-width + 0.5, start-y - 1.2, "down")
        draw-received(start-x + 2 * slot-width, start-y - 2.4, slot-width, "f2")
        draw-arrow(start-x + 3 * slot-width + 0.5, start-y - 2.4 + 0.4, "up")
        draw-transmitted(start-x + 3 * slot-width, start-y - 2.4, slot-width, "f3")

        // Slave 2: riceve f6-f8 (pacchetto lungo), trasmette f9
        draw-arrow(start-x + 7 * slot-width, start-y - 1.2, "down")
        draw-received(start-x + 6 * slot-width, start-y - 2.4, 3 * slot-width, "f6-f8")
        draw-arrow(start-x + 9 * slot-width + 0.5, start-y - 2.4 + 0.4, "up")
        draw-transmitted(start-x + 9 * slot-width, start-y - 2.4, slot-width, "f9")

        // Slave 3: riceve f10, trasmette f11
        draw-arrow(start-x + 10 * slot-width + 0.5, start-y - 2.3, "down")
        draw-received(start-x + 10 * slot-width, start-y - 3.5, slot-width, "f10")
        draw-arrow(start-x + 11 * slot-width + 0.5, start-y - 3.5 + 0.4, "up")
        draw-transmitted(start-x + 11 * slot-width, start-y - 3.5, slot-width, "f11")

        // Indicatore "1 slot time" in basso
        let indicator-y = start-y - 4.6
        line((start-x, indicator-y), (start-x, indicator-y + 0.25), stroke: 0.9pt + black)
        line((start-x + slot-width, indicator-y), (start-x + slot-width, indicator-y + 0.25), stroke: 0.9pt + black)
        line((start-x, indicator-y + 0.12), (start-x + slot-width, indicator-y + 0.12), stroke: 0.9pt + black, mark: (
          start: ">",
          end: ">",
        ))
        content((start-x + slot-width / 2, indicator-y - 0.25), text(size: 8pt, "1 slot time"))

        // Legenda
        let legend-x = start-x + 5.5
        let legend-y = indicator-y - 0.7

        draw-transmitted(legend-x, legend-y, 0.7, "")
        content((legend-x + 1.5, legend-y), text(size: 8pt, "= transmitted packet"), anchor: "west")

        draw-received(legend-x, legend-y - 0.5, 0.7, "")
        content((legend-x + 1.5, legend-y - 0.5), text(size: 8pt, "= received packet"), anchor: "west")
      })
    ]]

  Supponiamo di essere al $6$ slot di tempo.:
  - In TDMA il master decise di paralre con lo slave $2$. In particolare lo slave $2$ ascolterà sulla frequenza $f_6$ del frequency holding. Per tutti i $3$ slot successivi il master *non cambia la frequenza* (viene mantenuta la frequenza $f_6$ per tutto lo sloto).\

  - Lo slave risponde sulla frequenza $f_9$.

  #nota()[
    Questo offset è presente in quanto il metronomo assoluto della piconet continua a battere ogni $625 mu s$. Chi dovrà parlare in un certo istante dovrà usare la *frequenza $f_i$* in base alla *frequency hopping globale*.

    La frequency hopping viene scelta dal master, ogni tot secondi si _cambia_. Se si trasmette su *più slot temporali* *non* viene cambiata frequenza. La frequenza successiva non dipenderà dalla precedente ma da quella globale.

    Inoltre, a causa della rigidità del modello il tempo di trasmissione può impiegare *solo slot di durata dispari*.
  ]
]

=== Scatternet FH + CDMA

All'interno di una scatternet la frequency hopping viene decisa dal relativo master e condivisa all'interno della piconet. *Ogni piconet* avrà una sequenza diversa e sara *completamente autonoma*.

Un AS connesso a più piconet deve essere in grado di gestire le varie connessioni in maniera indipendente (anche a livello di capacità fisica del processore).

In alcuni momenti (non si sa quali) sui $79$ canali utilizzabili si può verificare una sovrapposzione: viene utilizzato lo stesso canale. Lo slave riceve di conseguenza un'interferenza in quanto si sta trasmettendo sulla stessa frequenza. Possibili soluzioni:

- Non risolvere il problema, usare molti meno canali. FH su un sotto-insieme di canali ($>= 20, < 79$).

- *CDMA*, per evitare interferenze tra piconet. Il master comunica un *codice ortogonale* per la propia piconet. Quando uno slave vuole comunicare o ascoltare, deve utilizzare il codice della piconet di riferimento.

#nota()[
  *Non* è una *soluzione totale*, ma è parziale, mitiga di molto il problema.
]

== Collegamenti Baseband: SCO & ACL

All'interno del livello Baseband esistono due tipi di collegamenti tra master e slave.

*Synchronous Connection-Oriented (SCO)*: Si tratta di un collegamento *orientato alla connessione sincrona*, principalmente utilizzato per la trasmissione di *dati real-time* come la voce. Le caratteristiche principali sono:
- *Simmetrico*: stessa banda in entrambe le direzioni (master $->$ slave e slave $->$ master)
- *Slot riservati*: il master riserva slot temporali fissi e periodici per la comunicazione SCO
- *Senza ritrasmissione*: i pacchetti persi non vengono ritrasmessi (meglio perdere qualche dato che introdurre ritardi)
- *Payload fisso*: tipicamente $30$ byte per pacchetto
- *Latenza bassa e costante*: ideale per applicazioni real-time
- *Circuit-switched*: il canale è sempre disponibile una volta stabilito

#esempio()[
  Un collegamento SCO viene utilizzato per le chiamate vocali Bluetooth: il master riserva slot temporali regolari per garantire un flusso audio continuo senza interruzioni.
]

*Asynchronous Connection-Less (ACL)*: Si tratta di un collegamento *asincrono senza connessione*, utilizzato per la trasmissione di *dati generici*. Le caratteristiche principali sono:
- *Asimmetrico*: può allocare più banda in una direzione rispetto all'altra
- *Slot dinamici*: gli slot vengono assegnati dinamicamente dal master in base alle necessità
- *Con ritrasmissione*: supporta meccanismi di controllo degli errori e ritrasmissione (ARQ)
- *Payload variabile*: dimensione del payload variabile in base alle esigenze
- *Throughput variabile*: dipende dalle condizioni del canale e dal carico della rete
- *Packet-switched*: i pacchetti vengono inviati quando necessario

#esempio()[
  Un collegamento ACL viene utilizzato per il trasferimento di file o per la navigazione web: la ritrasmissione garantisce l'integrità dei dati e la banda può essere allocata asimmetricamente (più in download che in upload).
]

#nota()[
  In una piconet possono coesistere sia collegamenti SCO che ACL. Il master gestisce entrambi i tipi attraverso lo scheduling degli slot temporali.
]

== Formato frame Baseband

Ogni frame Baseband è composto da tre parti principali:


*Access Code* ($72$ bit): Serve per la sincronizzazione e l'identificazione. Ha un preambolo per sincronizzare la parte radio del ricevitore. L'Access Code può essere di tre tipi:
- *CAC (Channel Access Code)*: identifica univocamente la piconet. Derivato dall'indirizzo del master
- *DAC (Device Access Code)*: derivato dall'indirizzo hardware dello slave, serve per indicare che un certo messaggio è destinato a quel dispositivo specifico
- *IAC (Inquiry Access Code)*: usato nella fase di scoperta per trovare dispositivi nelle vicinanze

*Header* ($54$ bit): Contiene informazioni di controllo per la gestione del collegamento:
- *AM_ADDR (Active Member Address)*: indirizzo del membro attivo della piconet (master o slave) su $3$ bit

- *Type*: identifica il tipo di pacchetto e se utilizza un canale SCO o ACL ($4$ bit)
- *Flow*: controllo di flusso per i collegamenti ACL ($1$ bit)
- *ARQN (Automatic Repeat reQuest)*: acknowledgment per la ritrasmissione ($1$ bit)
- *SEQN (Sequence Number)*: numero di sequenza per ordinare i pacchetti ($1$ bit)
- *HEC (Header Error Check)*: controllo degli errori dell'header ($8$ bit)

Il header viene trasmesso tre volte per garantire robustezza agli errori.

*Payload* (variabile): Dimensione variabile in base al tipo di pacchetto:
- *SCO*: payload fisso di $30$ byte

- *ACL*: payload variabile, può occupare $1$, $3$ o $5$ slot temporali consecutivi (fino a circa $340$ byte)

== Controllo degli errori con Stop-and-Wait ARQ

Il protocollo Bluetooth utilizza uno schema di controllo degli errori *Stop-and-Wait ARQ* semplificato grazie alla natura sincrona della comunicazione TDD.

#esempio()[
  Consideriamo una comunicazione tra un master e uno slave:

  #figure[
    #align(center)[
      #cetz.canvas(length: 0.9cm, {
        import cetz.draw: *

        let slot-width = 1.5
        let master-y = 4.5
        let slave-y = 1.5
        let num-slots = 9
        let start-x = 1.5

        // Funzione per disegnare un pacchetto pieno (trasmesso)
        let draw-packet-full(x, y, seqn, corrupted: false) = {
          rect((x, y - 0.3), (x + 0.65, y + 0.3), fill: rgb("#87CEEB"), stroke: 1.3pt + blue)
          content((x + 0.325, y), text(size: 11pt, fill: black, weight: "bold", str(seqn)))
          if corrupted {
            line((x, y - 0.3), (x + 0.65, y + 0.3), stroke: 2.5pt + red)
            line((x, y + 0.3), (x + 0.65, y - 0.3), stroke: 2.5pt + red)
          }
        }

        // Funzione per disegnare un pacchetto vuoto/tratteggiato (ricevuto/atteso)
        let draw-packet-dashed(x, y, seqn) = {
          rect((x, y - 0.3), (x + 0.65, y + 0.3), fill: rgb("#E6F3FF"), stroke: (
            paint: blue,
            thickness: 1.3pt,
            dash: "dotted",
          ))
          content((x + 0.325, y), text(size: 11pt, fill: black, weight: "bold", str(seqn)))
        }

        // Etichette frequenze in alto
        for i in range(num-slots) {
          let x = start-x + i * slot-width
          content((x + 0.425, master-y + 0.9), text(size: 9pt, $f_#i$))
          // Linee verticali tratteggiate
          if i > 0 {
            line((x, master-y - 3.8), (x, master-y + 0.6), stroke: (
              paint: gray.lighten(50%),
              dash: "dashed",
              thickness: 0.6pt,
            ))
          }
        }

        // Etichette Master e Slave
        content((start-x - 1.1, master-y), text(size: 10pt, weight: "bold", "Master"))
        content((start-x - 1.1, slave-y), text(size: 10pt, weight: "bold", "Slave"))

        // Timeline Master
        line((start-x, master-y), (start-x + num-slots * slot-width, master-y), stroke: 1pt + black, mark: (end: ">"))
        content((start-x + num-slots * slot-width + 0.6, master-y), text(size: 9pt, "t"))

        // Timeline Slave
        line((start-x, slave-y), (start-x + num-slots * slot-width, slave-y), stroke: 1pt + black, mark: (end: ">"))
        content((start-x + num-slots * slot-width + 0.6, slave-y), text(size: 9pt, "t"))

        // Slot f0: Master trasmette 0
        draw-packet-full(start-x + 0.175, master-y, 0)

        // Slot f0 ricevuto: Slave riceve 0
        draw-packet-dashed(start-x + 0.175, slave-y, 0)
        line((start-x + 0.5, master-y - 0.35), (start-x + 0.5, slave-y + 0.35), stroke: 1.2pt + black, mark: (end: ">"))

        // Slot f1: Slave trasmette ACK
        draw-packet-full(start-x + 1 * slot-width + 0.175, slave-y, 0)
        content((start-x + 1 * slot-width + 0.5, slave-y - 0.65), text(size: 8pt, weight: "bold", "ACK"))

        // Slot f1 ricevuto: Master riceve ACK
        draw-packet-dashed(start-x + 1 * slot-width + 0.175, master-y, 0)
        line(
          (start-x + 1 * slot-width + 0.5, slave-y + 0.3),
          (start-x + 1 * slot-width + 0.5, master-y + 0.35),
          stroke: 1.2pt + black,
          mark: (end: ">"),
        )

        // Slot f2: Master trasmette 1, ma corrotto
        draw-packet-full(start-x + 2 * slot-width + 0.175, master-y, 1, corrupted: true)
        line(
          (start-x + 2 * slot-width + 0.5, master-y - 0.35),
          (start-x + 2 * slot-width + 0.5, slave-y + 0.35),
          stroke: (paint: red, thickness: 1.5pt, dash: "dashed"),
          mark: (end: ">"),
        )

        // Slot f3: Slave trasmette NAK
        draw-packet-full(start-x + 3 * slot-width + 0.175, slave-y, 1)
        content((start-x + 3 * slot-width + 0.5, slave-y - 0.65), text(size: 8pt, weight: "bold", "NAK"))

        // Slot f3 ricevuto: Master riceve NAK
        draw-packet-dashed(start-x + 3 * slot-width + 0.175, master-y, 1)
        line(
          (start-x + 3 * slot-width + 0.5, slave-y + 0.35),
          (start-x + 3 * slot-width + 0.5, master-y + 0.35),
          stroke: 1.2pt + black,
          mark: (end: ">"),
        )

        // Slot f4: Master ritrasmette 1
        draw-packet-full(start-x + 4 * slot-width + 0.175, master-y, 1)

        // Slot f4 ricevuto: Slave riceve 1
        draw-packet-dashed(start-x + 4 * slot-width + 0.175, slave-y, 1)
        line(
          (start-x + 4 * slot-width + 0.5, master-y - 0.35),
          (start-x + 4 * slot-width + 0.5, slave-y + 0.35),
          stroke: 1.2pt + black,
          mark: (end: ">"),
        )

        // Slot f5: Slave trasmette ACK, ma si perde
        draw-packet-full(start-x + 5 * slot-width + 0.175, slave-y, 1)
        content((start-x + 5 * slot-width + 0.5, slave-y - 0.65), text(size: 8pt, weight: "bold", "ACK"))
        line(
          (start-x + 5 * slot-width + 0.5, slave-y + 0.35),
          (start-x + 5 * slot-width + 0.5, master-y + 0.35),
          stroke: (paint: red, thickness: 1.5pt, dash: "dashed"),
          mark: (end: ">"),
        )

        // Slot f6: Master ritrasmette 1 (duplicato)
        draw-packet-full(start-x + 6 * slot-width + 0.175, master-y, 1)

        // Slot f6 ricevuto: Slave riceve duplicato (aspetta 0)
        draw-packet-dashed(start-x + 6 * slot-width + 0.175, slave-y, 0)
        content((start-x + 6 * slot-width + 0.5, slave-y + 0.75), text(size: 7pt, fill: gray, "duplicate detected as"))
        content((start-x + 6 * slot-width + 0.5, slave-y + 1.05), text(size: 7pt, fill: gray, "SEQN = 0 expected"))
        line(
          (start-x + 6 * slot-width + 0.5, master-y - 0.35),
          (start-x + 6 * slot-width + 0.5, slave-y + 0.35),
          stroke: 1.2pt + black,
          mark: (end: ">"),
        )

        // Slot f7: Slave trasmette ACK
        draw-packet-full(start-x + 7 * slot-width + 0.175, slave-y, 1)
        content((start-x + 7 * slot-width + 0.5, slave-y - 0.65), text(size: 8pt, weight: "bold", "ACK"))

        // Slot f7 ricevuto: Master riceve ACK
        draw-packet-dashed(start-x + 7 * slot-width + 0.175, master-y, 1)
        line(
          (start-x + 7 * slot-width + 0.5, slave-y + 0.35),
          (start-x + 7 * slot-width + 0.5, master-y + 0.35),
          stroke: 1.2pt + black,
          mark: (end: ">"),
        )

        // Slot f8: Master trasmette 0
        draw-packet-full(start-x + 8 * slot-width + 0.175, master-y, 0)

        // Slot f8 ricevuto: Slave riceve 0
        draw-packet-dashed(start-x + 8 * slot-width + 0.175, slave-y, 0)
        line(
          (start-x + 8 * slot-width + 0.5, master-y - 0.35),
          (start-x + 8 * slot-width + 0.5, slave-y + 0.35),
          stroke: 1.2pt + black,
          mark: (end: ">"),
        )

        // Legenda
        let legend-x = start-x
        let legend-y = 0.2

        draw-packet-full(legend-x, legend-y, 0)
        content((legend-x + 1, legend-y), text(size: 8pt, "or"), anchor: "west")
        draw-packet-full(legend-x + 1.5, legend-y, 1)
        content((legend-x + 2.5, legend-y), text(size: 8pt, "= sequence number, SEQN in packet header"), anchor: "west")

        line(
          (legend-x + 8.5, legend-y),
          (legend-x + 9.5, legend-y),
          stroke: (paint: red, thickness: 1.5pt, dash: "dashed"),
          mark: (end: ">"),
        )
        content((legend-x + 10, legend-y), text(size: 8pt, "= packet corrupted"), anchor: "west")
      })
    ]
  ]

  + *Trasmissione iniziale* ($f_0$): il master invia un pacchetto con SEQN $= 0$. Lo slave lo riceve correttamente e risponde con un ACK ($f_1$)

  + *Pacchetto corrotto* ($f_2$): il master trasmette il pacchetto con SEQN $= 1$, ma la trasmissione fallisce (pacchetto corrotto)

  + *NAK implicito* ($f_3$): lo slave non riceve nulla. Siccome si aspettava un pacchetto nel turno del master, risponde con un NAK, comunicando di non aver ricevuto il pacchetto atteso

  + *Ritrasmissione* ($f_4$): il master ritrasmette il pacchetto con SEQN $= 1$. Questa volta arriva correttamente allo slave

  + *ACK perso* ($f_5$): lo slave invia un ACK, ma questo si perde. Il master, non avendo ricevuto l'ACK, assume che il pacchetto sia stato perso

  + *Duplicato scartato* ($f_6$): il master ritrasmette nuovamente con SEQN $= 1$. Lo slave riceve il pacchetto duplicato, ma avendo già il pacchetto con SEQN $= 1$ nel buffer (e aspettandosi SEQN $= 0$), lo scarta. Invia nuovamente l'ACK ($f_7$)

  + *Prosecuzione* ($f_8$): finalmente l'ACK arriva correttamente. Il master può procedere con il messaggio successivo (SEQN $= 0$ modulo $2$)
]

#nota()[
  Grazie all'alternanza rigida tra slot master $->$ slave e slave $->$ master (sincronismo implicito gestito dal TDD), è sufficiente un *singolo bit* per il controllo del flusso.

  Se trasmetto il pacchetto $1$ e ricevo conferma, il successivo sarà lo $0$. Il sequence number alterna tra $0$ e $1$ (SEQN modulo $2$).
]

== Connessione alla piconet

Come fa un dispositivo a passare dallo *standby mode* (non conosce il frequency hopping, non sa come contattare i master) alla *modalità attiva* all'interno di una piconet?

=== Fase di Discovery (Inquiry)

Il processo di scoperta funziona nel seguente modo:

+ *Master in inquiry*: il master sceglie un sotto-insieme specifico di canali (non tutti i $79$ per evitare interferenze) chiamati *inquiry channels*. Su questi canali trasmette periodicamente *inquiry packet* ogni $625 mu s$ (uno slot BT) per chiedere se ci sono dispositivi che vogliono connettersi

+ *Slave in scan*: lo slave, per risparmiare energia, scansiona i canali di connessione *periodicamente* (non in modo continuo). L'inquiry scan dura circa $11.25 "ms"$ e viene eseguito con intervalli di $1.28$ o $2.56$ secondi. Quando intercetta un inquiry packet, non risponde immediatamente

+ *Random backoff*: lo slave attende un *random backoff time* prima di rispondere. Questo meccanismo evita collisioni con altri slave che potrebbero voler connettersi contemporaneamente. Il backoff è calcolato in modo da sincronizzarsi con il timing del master

+ *Inquiry response*: dopo il backoff, lo slave risponde al master comunicando il proprio indirizzo hardware (BD_ADDR)

#attenzione()[
  Tutto questo meccanismo è *non coordinato* e *distribuito*. Master e slave devono trovare un accordo senza una sincronizzazione preesistente.
]

//TODO FI
#esempio()[
  Esempio di fase di discovery tra un master e uno slave:

  #figure[
    #align(center)[
      #cetz.canvas(length: 1cm, {
        import cetz.draw: *

        let slot-width = 0.35
        let master-y = 3.5
        let slave-y = 1.5
        let num-inquiry = 30
        let start-x = 1

        // Timeline Master
        line((start-x, master-y), (start-x + num-inquiry * slot-width, master-y), stroke: 1.2pt + black, mark: (
          end: ">",
        ))
        content((start-x - 0.8, master-y), text(size: 9pt, weight: "bold", "MASTER"))
        content((start-x + num-inquiry * slot-width + 0.5, master-y), text(size: 9pt, "t"))

        // Timeline Slave
        line((start-x, slave-y), (start-x + num-inquiry * slot-width, slave-y), stroke: 1.2pt + black, mark: (end: ">"))
        content((start-x - 0.8, slave-y), text(size: 9pt, weight: "bold", "SLAVE"))
        content((start-x + num-inquiry * slot-width + 0.5, slave-y), text(size: 9pt, "t"))

        // Etichetta slot BT
        content((start-x + 6, master-y + 0.8), text(size: 8pt, "BT slot 625μs"))

        // Etichetta durata totale
        content((start-x + num-inquiry * slot-width / 2, master-y + 1.2), text(size: 8pt, "5.12 secondi"))

        // Inquiry packets del master (pattern casuale di verdi e bianchi e rossi)
        let inquiry-pattern = (1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1)
        for i in range(num-inquiry) {
          let x = start-x + i * slot-width
          if inquiry-pattern.at(i) == 1 {
            rect(
              (x, master-y - 0.25),
              (x + slot-width - 0.02, master-y + 0.25),
              fill: rgb("#90EE90"),
              stroke: 0.8pt + black,
            )
          } else {
            rect((x, master-y - 0.25), (x + slot-width - 0.02, master-y + 0.25), fill: white, stroke: 0.8pt + black)
          }
        }

        // Legenda inquiry packet
        rect((start-x, master-y - 1), (start-x + 0.3, master-y - 0.6), fill: rgb("#90EE90"), stroke: 0.8pt + black)
        content((start-x + 0.8, master-y - 0.8), text(size: 7pt, "Inquiry packet"), anchor: "west")

        // Inquiry scan dello slave - primi tentativi falliti
        // Scan 1 (fallito)
        let scan1-x = start-x + 2 * slot-width
        rect((scan1-x - 0.15, slave-y - 0.3), (scan1-x + 0.95, slave-y + 0.3), fill: rgb("#E0E0E0"), stroke: 1pt + blue)
        line((scan1-x + 0.4, master-y - 0.3), (scan1-x + 0.4, slave-y + 0.35), stroke: 1pt + gray, mark: (end: ">"))
        // X rossa per indicare fallimento
        line((scan1-x + 0.2, slave-y - 0.15), (scan1-x + 0.6, slave-y + 0.15), stroke: 2pt + red)
        line((scan1-x + 0.2, slave-y + 0.15), (scan1-x + 0.6, slave-y - 0.15), stroke: 2pt + red)

        // Scan 2 (fallito)
        let scan2-x = start-x + 8 * slot-width
        rect((scan2-x - 0.15, slave-y - 0.3), (scan2-x + 0.95, slave-y + 0.3), fill: rgb("#E0E0E0"), stroke: 1pt + blue)
        line((scan2-x + 0.4, master-y - 0.3), (scan2-x + 0.4, slave-y + 0.35), stroke: 1pt + gray, mark: (end: ">"))
        // X rossa per indicare fallimento
        line((scan2-x + 0.2, slave-y - 0.15), (scan2-x + 0.6, slave-y + 0.15), stroke: 2pt + red)
        line((scan2-x + 0.2, slave-y + 0.15), (scan2-x + 0.6, slave-y - 0.15), stroke: 2pt + red)

        // Scan 3 (successo!)
        let scan3-x = start-x + 15 * slot-width
        rect(
          (scan3-x - 0.15, slave-y - 0.3),
          (scan3-x + 0.95, slave-y + 0.3),
          fill: rgb("#90EE90"),
          stroke: 1.2pt + green.darken(20%),
        )
        line(
          (scan3-x + 0.4, master-y - 0.3),
          (scan3-x + 0.4, slave-y + 0.35),
          stroke: 1.2pt + green.darken(20%),
          mark: (end: ">"),
        )
        // Checkmark verde per indicare successo
        line((scan3-x + 0.2, slave-y), (scan3-x + 0.35, slave-y - 0.12), stroke: 2.5pt + green.darken(30%))
        line((scan3-x + 0.35, slave-y - 0.12), (scan3-x + 0.6, slave-y + 0.18), stroke: 2.5pt + green.darken(30%))

        // Random backoff e risposta
        let response-x = start-x + 20 * slot-width
        rect(
          (response-x - 0.15, slave-y - 0.3),
          (response-x + 0.5, slave-y + 0.3),
          fill: rgb("#87CEEB"),
          stroke: 1.2pt + blue,
        )
        line((response-x + 0.15, slave-y - 0.35), (response-x + 0.15, master-y + 0.35), stroke: 1.2pt + blue, mark: (
          end: ">",
        ))

        // Etichetta random backoff
        content((scan3-x + 2.5, slave-y - 0.8), text(size: 7pt, "Random Backoff"), anchor: "center")
        line((scan3-x + 0.9, slave-y - 0.35), (response-x - 0.2, slave-y - 0.35), stroke: (
          paint: black,
          thickness: 0.8pt,
          dash: "dashed",
        ))
        line((scan3-x + 0.9, slave-y - 0.5), (scan3-x + 0.9, slave-y - 0.35), stroke: 0.8pt + black)
        line((response-x - 0.2, slave-y - 0.5), (response-x - 0.2, slave-y - 0.35), stroke: 0.8pt + black)

        // Etichette inquiry scan
        content((start-x + 5.5, slave-y - 1.3), text(size: 7pt, "Inquiry scan"))
        content((start-x + 5.5, slave-y - 1.6), text(size: 7pt, "Time 11.25 ms"))

        // Etichetta scan interval
        content((start-x + 5, slave-y - 2.1), text(size: 7pt, "Scan interval 1,28 | 2,56 s"))
        line((scan1-x + 0.4, slave-y - 1.9), (scan2-x + 0.4, slave-y - 1.9), stroke: 0.8pt + black, mark: (
          start: ">",
          end: ">",
        ))
        line((scan1-x + 0.4, slave-y - 0.35), (scan1-x + 0.4, slave-y - 1.9), stroke: 0.8pt + black)
        line((scan2-x + 0.4, slave-y - 0.35), (scan2-x + 0.4, slave-y - 1.9), stroke: 0.8pt + black)
      })
    ]
    caption: [Fase di Discovery: Inquiry tra Master e Slave]
  ]

  Il diagramma mostra come:
  - Il master trasmette continuamente inquiry packets (rettangoli $mg("verdi")$) ogni $625 mu s$
  - Lo slave effettua inquiry scan periodici (rettangoli $mb("blu")$) con lunghi intervalli tra uno scan e l'altro
  - I primi due scan falliscono ($mr("X rossa")$) perché non coincidono con l'invio di un inquiry packet
  - Il terzo scan ha successo (checkmark verde) intercettando un inquiry packet
  - Lo slave attende un random backoff prima di rispondere per evitare collisioni
]

=== Fase di Paging (Connessione)

Una volta che il master ha scoperto la presenza di uno slave, inizia la fase di *paging* per stabilire la connessione:
+ Il master invia *page packet* sullo slave utilizzando il suo indirizzo hardware (DAC)

+ Lo slave risponde e inizia la negoziazione dei parametri di connessione

+ Il master comunica allo slave:
  - *Indirizzo logico AMA* (Active Member Address) nella piconet
  - *Sequenza di frequency hopping* da utilizzare
  - *Clock offset* per la sincronizzazione temporale

+ La connessione viene stabilita e lo slave entra in modalità *attiva* (active slave)

#nota()[
  Durante le fasi di inquiry e paging viene utilizzato sempre un *insieme ridotto di canali standard* (inquiry/paging channels), proprio perché lo slave non è ancora a conoscenza della sequenza di frequency hopping specifica della piconet.
]
