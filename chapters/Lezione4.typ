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

Tutti i livelli $mb("blu")$ rappresentano i _core protocols_, ovvero le componenti sempre presenti in un qualsiasi dispositivo bluetooth.


#nota()[
  Completamente diverso dallo stack TCP/IP o ISO/OSI.
]







Abbiamo i seguenti pezzi:

Tutti i livelli in blu, sono sempre presenti in un qualsiasi dispositivo bluetooth.

La linea rossa divide la parte hardware da quella sofware.

=== bluetooth Radio

Livello fisico

Si occupa di trasmettere e ricevere radio frequenze.
Gestisce:
- Gestione del frequency hopping
- Lo schema di modulazione di forwarder e correction
- Gestisce la potenza di trasmissione

=== Baseband

Si occupa di :
- Stabile la connessione con la pico-net
- Gestisce l'indirizzamento. Abbiamo sia l'indirizzo hardware del dispositivo che logico a livello di pico-net.
- Sincronizzazione e tempistiche di comunicazione, Time division duplex, frequency division duplex (2 trasmissioni divere).
- Gestisce la potenza di trasmissione

Duplex, come gestisco la trasmissione e la ricezione (il cavo ethernet è full-duplex). In ambito Wireless non si può fare o trasmettiano o riceviamo

=== LMP
Si tratta di un livello di controllo. Non trasmette dati ma li gestisce.

- Configura i collegamenti
- Gestisce la sicurezza

=== L2CAP

Siamo nella parte sofware. Si tratta di fatto di un protocollo che permette la convergenza di quello che c'è sopra adattandolo ai servizi offerti dai livelli inferiori.

=== SDP

serve per gestire cosa il dispositivo è in grado di fare (auricolari bluetooth fanno qualcosa di diverso da orologio bluetooth). Implementa un protocollo che permette ad un dispositivo che si conette alla pico-net di trovare il dispositivo con un certo profilo (cosa è in grado di fare) nella rete.

=== RFCOMM

emulatore di porta seriale. Non è fondamentale che ci sia

=== ALtro

Lo standard bluetooth intende riutilizzare il maggior numero di protocolli già esistenti. bluetooth si occupa tramite i suoi livelli proprietari di convertire il mondo esterno in quello bluetooth
//TODO aggiungere cosa sono i profili

== pico-net & scatternet

Active slave (AS): Membro attivo della rete. Al massino il suo indirizzo è $3$ bit.

Al più in una piconet ci possono essere 8 dispositivi che comunicano attiviamento (uno di quelli è il master)

Parked Salve (PS): Comunque parte della pico-net ma non ha accesso diretto alla comunicazione. Può ascoltare messaggi ma non puà comunicare attivamente. Il master decide se risvegliarlo, assegnandoli un active member address. Per farlo serve una parked member address, al massimo $255$ dispositivi (lo zero è riservato al master)

Stanby Salve (SS): Ci sono anche dei dispositivi che possono ascoltare messaggi ma sono esclusi dalla rete (non sono indirizzati).

#nota()[
  Lo standard bluetooth permette ad uno slave di far parte di più piconet.
]
Uno slave può essere una qualsiasi combinazione dei possibili stati nelle varie reti. In questo modo viene a crearsi una *scatternet*. Insieme di più pico-net (pico-net che condividono slave), tuttavia ogni pico-net è separata, ognuna è gestita dal proprio master.

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
