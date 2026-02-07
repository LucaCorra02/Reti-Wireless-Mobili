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

=== COmunicazione
FH:

TDD: In uno solot temporare la comunicazione avviene master slave mentre quello successivo slave master e cosi via. Nell'immagine gli indici delle frequenze pari (slot pari delle frequenze) abbiamo comunicazione master slave. Nell'istante di tempo successivo su una frequenza diversa abbiamo la comunciazione slave - master.

#nota()[
  La direzione è decisa a priori. Nelle frequenze pari (in termini di tempo e non nei canali) il master parla con gli slave e in quelle dispari viceversa
]

Tutti gli slave sono Sincronizzati temporalmente e condividono al stessa frequenza di frequency hopping (altrimenti non sarebbe possibile)

TDMA: Aggiugnere

//aggiungere imamgine
#esempio()[
  in TDMA il master decise di paralre con lo slave 2. In particolare lo slave 2 ascolterare sulla sequenza 2 del frequency holding. per tutti i 3 slot successivi il master non cambia la frequenza. Una volta scelto una frequenza non la cambia (i clock sono distributii).\
  Lo slave risponde sulal frequenza $5$. Il metronomo assoluto della pico-net continua a battere ogni $225 "ms"$. Chi dovrà parlare in questo istante dovrà usare la frequenza $5$ in base alla frequency hopping globale.

  #nota()[
    GLi slot possono essere solo dispari. Con la rigidità del TDM, tutti i dispositivi della pico-net sanno che sulle freuqnze pari devono ascoltare, sulle frequenze pari sanno che possono comunicare.

    Si tratta di una convenzione. La frequency hopping viene data dal master, ogni tot secondi c'è alternanza e se si trasmette su più slot non si cambia frequenza. La frequenza successiva non dipenderà dalla precedente ma da quella globale.

    In questo modo non c'è comunicazione.
  ]
  #attenzione()[
    é come se la trasmissione fosse sincrona implicitamente, la sincronia viene gestita dal master.
  ]
]

=== Scatternet FH + CDMA

In alcuni momenti (non si sa quali ) dei 79 canali che possiamo usare ci può essere una sovrapposzione, lo stesso canale viene utilizzato. Lo slave riceve un interferenza in quanto si sta trasmettendo sulla stessa frequenza.

Soluzione:
- Non risolvere il problema, usare molti meno canali
- CDMA, comunicare sulla stessa frequenza senza interferenza.

Il master comunica un codice ortogonale per la propia piconet. Nella comunicazione oltre al frequency hopping usiamo anche CDMA.

Quando lo slave di mezzo vuole comunicare o ascoltare deve utilizzare il codice della piconet di riferimento.

#nota()[
  Non è una soluzione totale, ma è parziale, mitiga di molto il problema.
]

== Baseband SCO & ACL

// riguardare

=== Formato frame
- Access code:
  - Ha un preambolo per sincronizzare la parte radio.
  Acces Code può essere (o uno o l'altro):
  - CAC: identifica la piconet
  - DAC: derivato dall'hardware dello slave, serve per dire che un certo messaggio è destinato a quel dispositivo
  - IAC: usato per trovare l'indirizzo di un dispositivo
- Head:
  - AMA: indirizzo del membro attivo della piconet (master o slave)
  - Type: identifica se è un canale SCO o ACL
  - Flow: per le ACL
  - ARQN: parte per la ritrasmissione
  - SEQN: sequence number
  - HEC: Conrollo degli errori
- Payload (30 byte per SCO o variabile per ACL):

== Controllo degli errori
//aggungere imamgine
Abbiamo uan comunicazione tra un singolo master e un singolo slave.
Il bit scritto nel header è il SEQN (sequence number), il bit è relativo all'ACK.

- La prima trasmissione master slave ha SEQN 0. Lo slave risponde un ACK con SEQN 0.
- il master trasmetter il SEQN del pacchetto succevvo, ovvero 1. tuttavia la trasmissione fallisce
- lo slave non riceve, siccome si aspettava un pacchetto con SEQN $1$ risponde con un NAK pari a $1$. Lo slave si aspettava di ricevere qualcosa (turno del master), comuncia di nona aver ricevuto SEQN.

- più avanti nella figura fallisce l'ACK. Il master nella frequenza 5 si apettava l'ACK dello slave ma non è arrivato, il master assume che sia stao perso. Il master rimandera messagio con SEQN $1$

- lo slave lo riveve, siccome lo ha già nel buffer viene scartato. QUesta volta l'ACK arriva.

- Alla fine viene trasferito il messaggio successivo (SEQN modulo 2 = 0).

#nota()[
  Se non ci fosse questa alternanza rigida (sincronismo implicito) non basterebbe un controllo dell'errore così semlice.

  Basta un solo bit per controllare il flusso. Se trasmetto l'1 e rivevo conferma di aver ricevuto 1 il successivo è lo 0.
]

== Link manager protocol (LMP)

Come arriviamo dallo stanby mode (non sappiamo frequency hopping, come contattare i master ecc) alla modalità attiva essendo in una modalità distributia.

L'idea è scegliere un sotto-insieme (non tutti per evitare interferenze) di canali in cui il Master chiede se ci sono dei dispositivi (inquiring message) che si vogliono conettere, lo slave ascolta (ogni tanto per risparmiare batteria). Allo stesso modo il master fa polling tra i vari canali (wake-up channel) di connessione durante in un certo intervallo.

#attenzione()[
  Tutto questo meccanismo è non coordinato
]
Il master ogni tanto trasmesse un inquiry packet (intervallo di tempo fissato). Lo slave ogni tanto scansiona il canale di connessione. Se lo slave intercetta il segnsle non risponde subito ma aspetta un  *random backoff time*. In modo tale da evitare collisioni con altri slave che si vogliono collegare.

il random backoff è calcolato apposta per cercare di beccare la sincronizzazione del master.

Una volta che il master ha scoperto la presenza di uno slave viene dato l'accesso allo slave. Vengono comunicati:
- l'indirizzo
- il frequency hopping

Inoltre viene uitlizzato semrpe un insieme di canali standard specifici (più piccoli), in quanto lo slave non è ancora a conoscenza del frequency hopping.
