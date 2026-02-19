#import "../template.typ": *

= QoS in WiFi e Reti Veicolari

== IEEE 802.11e - EDCA (Enhanced Distributed Channel Access)

Lo standard *IEEE 802.11e* introduce meccanismi di *Quality of Service (QoS)* nelle reti WiFi attraverso l'*EDCA (Enhanced Distributed Channel Access)*, un'evoluzione del DCF che permette di differenziare il traffico in base alla priorità.

=== Access Categories (AC)

EDCA definisce *quattro categorie di accesso* (Access Categories) che mappano diversi tipi di traffico a livelli di priorità differenti. Ogni categoria è caratterizzata da quattro parametri principali che ne determinano il comportamento nell'accesso al canale.

#align(center)[
  #figure(
    {
      set text(size: 0.75em)
      table(
        columns: (2fr, 1fr, 1fr, 1fr, 1.5fr, 2fr),
        align: center + horizon,
        fill: (col, row) => if row == 0 { 
          rgb("#4472C4") 
        } else if row == 1 {
          rgb("#C00000")
        } else if row == 2 {
          rgb("#FFC000")
        } else if row == 3 {
          rgb("#70AD47")
        } else {
          rgb("#A6A6A6")
        },
        text(fill: white, weight: "bold")[Access\ Category],
        text(fill: white, weight: "bold")[CW_min],
        text(fill: white, weight: "bold")[CW_max],
        text(fill: white, weight: "bold")[AIFSN],
        text(fill: white, weight: "bold")[TXOP\ Limit],
        text(fill: white, weight: "bold")[Tipo di\ Traffico],
        
        text(fill: white, weight: "bold")[AC_VO\ (Voice)], 
        [3], [7], [2], [1.5 ms], [VoIP, telefonia],
        
        text(fill: white, weight: "bold")[AC_VI\ (Video)], 
        [7], [15], [2], [3.0 ms], [Streaming video],
        
        text(fill: white, weight: "bold")[AC_BE\ (Best Effort)], 
        [15], [1023], [3], [0], [Web, email],
        
        text(fill: white, weight: "bold")[AC_BK\ (Background)], 
        [15], [1023], [7], [0], [Trasferimenti file],
      )
    },
    caption: [Parametri EDCA per le quattro Access Categories]
  )
]

I quattro parametri che definiscono il comportamento di ciascuna *Access Category* sono:

/ *CW_min (Contention Window Minimum)*: Valore minimo della finestra di contesa. Determina il *limite inferiore* del *random backoff*. Valori più bassi significano tempi di attesa minori e quindi maggiore priorità.

/ *CW_max (Contention Window Maximum)*: Valore massimo della finestra di contesa dopo collisioni multiple. Ad ogni collisione, la CW viene raddoppiata fino a raggiungere CW_max. 

/ *AIFSN (Arbitration Inter-Frame Space Number)*: Numero di slot time da attendere dopo SIFS prima di poter accedere al canale. La formula è:
  $ "AIFSN" = "SIFS" + "N" "SlotTime" $
  *Valori* più *alti* di AIFSN significano *priorità più bassa*.

/ *TXOP Limit (Transmission Opportunity)*: Tempo massimo (in microsecondi) per cui una stazione può mantenere il *controllo del canale* dopo averlo ottenuto. Un valore di 0 significa che si può trasmettere un solo frame.

#esempio[
*Traffico Voice (AC_VO)*: 
- CW_min = $3$, CW_max = $7$: finestre molto piccole per accesso rapido
- AIFSN = $2$: attesa minima dopo SIFS
- TXOP = $1.5 "ms"$: può trasmettere più frame voce consecutivi

*Traffico Background (AC_BK)*:
- CW_min = $15$, CW_max = $1023$: finestre grandi, attesa più lunga
- AIFSN = $7$: deve attendere più a lungo prima di tentare l'accesso
- TXOP = $0$: trasmette un solo frame alla volta
]

=== Meccanismo di Contesa Interno ed Esterno

Quando una stazione ha traffico appartenente a diverse Access Categories, EDCA implementa un *doppio meccanismo di contesa*:

#align(center)[
  #figure(
    cetz.canvas(length: 0.7cm, {
      import cetz.draw: *

      let box-style = (stroke: black, radius: 0.2)
      let w = 2.5
      let h = 1
      let gap-y = 0.3

      // Four AC queues
      rect((0, 3.5), (w, 3.5 + h), ..box-style, fill: rgb("#C00000"))
      content((w/2, 3.5 + h/2), text(fill: white, weight: "bold", size: 0.8em)[AC_VO])

      rect((0, 2.5 - gap-y), (w, 2.5 - gap-y + h), ..box-style, fill: rgb("#FFC000"))
      content((w/2, 2.5 - gap-y + h/2), text(fill: white, weight: "bold", size: 0.8em)[AC_VI])

      rect((0, 1.5 - 2*gap-y), (w, 1.5 - 2*gap-y + h), ..box-style, fill: rgb("#70AD47"))
      content((w/2, 1.5 - 2*gap-y + h/2), text(fill: white, weight: "bold", size: 0.8em)[AC_BE])

      rect((0, 0.5 - 3*gap-y), (w, 0.5 - 3*gap-y + h), ..box-style, fill: rgb("#A6A6A6"))
      content((w/2, 0.5 - 3*gap-y + h/2), text(fill: white, weight: "bold", size: 0.8em)[AC_BK])

      // Internal contention
      let x-int = w + 1.5
      rect((x-int, 1.5), (x-int + 2, 2.5), ..box-style, fill: rgb("#D9E2F3"))
      content((x-int + 1, 2), text(weight: "bold", size: 0.8em)[Contesa\ Interna])

      // Arrows to internal contention
      for i in range(4) {
        let y-from = 3.5 - i * (1 + gap-y) + h/2
        line((w, y-from), (x-int, 2), mark: (end: ">"), stroke: (thickness: 1pt))
      }

      // Winner to external contention
      let x-ext = x-int + 3.5
      rect((x-ext, 1.5), (x-ext + 2, 2.5), ..box-style, fill: rgb("#E7E6E6"))
      content((x-ext + 1, 2), text(weight: "bold", size: 0.8em)[Contesa\ Esterna])

      line((x-int + 2, 2), (x-ext, 2), mark: (end: ">"), stroke: (thickness: 1.5pt))
      content((x-int + 2.70, 2.7), text(size: 0.7em)[Vincitore])

      // To channel
      let x-ch = x-ext + 3
      rect((x-ch, 1.5), (x-ch + 2, 2.5), ..box-style, fill: rgb("#4472C4"))
      content((x-ch + 1, 2), text(fill: white, weight: "bold", size: 0.8em)[Canale\ Fisico])

      line((x-ext + 2, 2), (x-ch, 2), mark: (end: ">"), stroke: (thickness: 1.5pt))

      // Labels
      content((x-int + 1, 0.5), text(size: 0.7em)[AIFSN e CW\ per AC])
      content((x-ext + 1, 0.5), text(size: 0.7em)[CSMA/CA\ Standard])
    }),
    caption: [Meccanismo di contesa in EDCA]
  )
]

1. *Contesa Interna* (Contesa intra-stazione): All'interno della stazione, le diverse AC competono tra loro utilizzando i rispettivi parametri _EDCA_ (AIFSN, CW_min, CW_max). La *AC con priorità più alta* (_AIFSN_ più basso) vince tipicamente la contesa interna.

2. *Contesa Esterna* (Contesa tra stazioni): La AC vincente della contesa interna compete poi con le trasmissioni di altre stazioni sul *canale fisico* utilizzando CSMA/CA standard.

#nota[
  In caso di collisione interna (due AC pronte simultaneamente), vince sempre la AC (acces category) con priorità più alta. La AC con priorità più bassa deve comportarsi come se avesse subito una collisione esterna (raddoppia la *CW*).
]

La combinazione intelligente dei parametri EDCA permette una *differenziazione efficace* del traffico, garantendo certi livelli di QoS:

#align(center)[
  #figure(
    cetz.canvas(length: 0.6cm, {
      import cetz.draw: *

      let time-scale = 0.8
      let y-base = 0
      
      // Timeline
      line((0, y-base), (20, y-base), mark: (end: ">"), stroke: (thickness: 1.5pt))
      content((20.5, y-base), anchor: "west", text(weight: "bold")[Tempo])

      // SIFS
      rect((0, y-base), (1*time-scale, y-base + 0.6), fill: rgb("#E74C3C"), stroke: black)
      content((0.5*time-scale, y-base + 0.3), text(fill: white, size: 0.7em, weight: "bold")[SIFS])

      // AIFS for different ACs
      let aifs-vo = 2
      let aifs-vi = 2
      let aifs-be = 3
      let aifs-bk = 7

      // AC_VO
      rect((1*time-scale, y-base + 2.5), (1*time-scale + aifs-vo*time-scale, y-base + 2.5 + 0.5), fill: rgb("#C00000"), stroke: black)
      content((1*time-scale + aifs-vo*time-scale/2, y-base + 2.75), text(fill: white, size: 0.65em)[AIFS[VO]])
      
      // Backoff VO
      rect((1*time-scale + aifs-vo*time-scale, y-base + 2.5), (1*time-scale + aifs-vo*time-scale + 1.5*time-scale, y-base + 2.5 + 0.5), fill: rgb("#FFB6C1"), stroke: (dash: "dashed"))
      content((1*time-scale + aifs-vo*time-scale + 0.75*time-scale, y-base + 2.75), text(size: 0.6em)[BO])

      // AC_VI
      rect((1*time-scale, y-base + 1.8), (1*time-scale + aifs-vi*time-scale, y-base + 1.8 + 0.5), fill: rgb("#FFC000"), stroke: black)
      content((1*time-scale + aifs-vi*time-scale/2, y-base + 2.05), text(fill: white, size: 0.65em)[AIFS[VI]])
      
      rect((1*time-scale + aifs-vi*time-scale, y-base + 1.8), (1*time-scale + aifs-vi*time-scale + 2.5*time-scale, y-base + 1.8 + 0.5), fill: rgb("#FFE6B3"), stroke: (dash: "dashed"))
      content((1*time-scale + aifs-vi*time-scale + 1.25*time-scale, y-base + 2.05), text(size: 0.6em)[Backoff])

      // AC_BE
      rect((1*time-scale, y-base + 1.1), (1*time-scale + aifs-be*time-scale, y-base + 1.1 + 0.5), fill: rgb("#70AD47"), stroke: black)
      content((1*time-scale + aifs-be*time-scale/2, y-base + 1.35), text(fill: white, size: 0.65em)[AIFS[BE]])
      
      rect((1*time-scale + aifs-be*time-scale, y-base + 1.1), (1*time-scale + aifs-be*time-scale + 4*time-scale, y-base + 1.1 + 0.5), fill: rgb("#D4E6C4"), stroke: (dash: "dashed"))
      content((1*time-scale + aifs-be*time-scale + 2*time-scale, y-base + 1.35), text(size: 0.6em)[Backoff])

      // AC_BK
      rect((1*time-scale, y-base + 0.4), (1*time-scale + aifs-bk*time-scale, y-base + 0.4 + 0.5), fill: rgb("#A6A6A6"), stroke: black)
      content((1*time-scale + aifs-bk*time-scale/2, y-base + 0.65), text(fill: white, size: 0.65em)[AIFS[BK]])
      
      rect((1*time-scale + aifs-bk*time-scale, y-base + 0.4), (1*time-scale + aifs-bk*time-scale + 5*time-scale, y-base + 0.4 + 0.5), fill: rgb("#E6E6E6"), stroke: (dash: "dashed"))
      content((1*time-scale + aifs-bk*time-scale + 2.5*time-scale, y-base + 0.65), text(size: 0.6em)[Backoff])

      // Labels
      content((-1.5, y-base + 2.75), anchor: "east", text(size: 0.7em, weight: "bold")[Voice])
      content((-1.5, y-base + 2.05), anchor: "east", text(size: 0.7em, weight: "bold")[Video])
      content((-1.5, y-base + 1.35), anchor: "east", text(size: 0.7em, weight: "bold")[Best Effort])
      content((-1.5, y-base + 0.65), anchor: "east", text(size: 0.7em, weight: "bold")[Background])
    }),
    caption: [Temporizzazione EDCA: AC con priorità più alta accedono prima al canale]
  )
]

#attenzione()[
  Il sistema EDCA garantisce che *non* ci sia *starvation*: anche il traffico _Background_ (AC_BK) prima o poi accederà al canale. Tuttavia, in condizioni di carico elevato, le AC a bassa priorità subiranno ritardi significativi, per garantire QoS ai servizi real-time.
]

=== Configurazione a Livello MAC

I servizi QoS vengono richiesti a *livello MAC* in base alla configurazione dell'applicazione. Il mapping tipico è:

- *VoIP/Telefonia* → AC_VO (massima priorità)
- *Video streaming* → AC_VI (alta priorità)
- *Navigazione web, email* → AC_BE (priorità normale)
- *Download, backup* → AC_BK (priorità minima)

#attenzione[
  La configurazione EDCA deve essere coordinata tra Access Point e stazioni. L'AP comunica i parametri EDCA nei beacon frame. Configurazioni errate o aggressive (es. tutti i client che usano AC_VO) possono degradare le performance  complessive della rete.
]

== Applicazioni Veicolari con 802.11p

*IEEE 802.11p* è progettato per comunicazioni veicolari *V2V* (Vehicle-to-Vehicle) e *V2I* (Vehicle-to-Infrastructure). Le caratteristiche operative principali sono:

- *Assenza di Access Point*: Le reti sono completamente ad-hoc, i *veicoli comunicano direttamente*
- *Topologia dinamica*: I vicini cambiano continuamente (velocità relativa fino a 200+ km/h)
- *Nessuna associazione*: Eliminato il processo di beacon/associazione per ridurre la latenza
- *Comunicazione asincrona*: *Eventi imprevedibili* richiedono radio sempre in ascolto
- *Messaggi di notifica*: Focus su BSM (Basic Safety Messages) periodici piuttosto che flussi dati continui

#attenzione[
In 802.11p *non* vengono *utilizzati ACK* per i messaggi broadcast (BSM). Questo riduce l'overhead ma richiede ripetizione periodica dei messaggi (tipicamente 10 Hz) per garantire la consegna.
]

=== Gestione Multi-Canale in 802.11p

IEEE 1609.4 definisce la gestione dei canali in ambiente WAVE, alternando tra:

- *CCH (Control Channel)*: Canale 178 (5890 MHz) per messaggi safety-critical
- *SCH (Service Channels)*: Canali 172, 174, 176, 180, 182, 184 per applicazioni non-safety

Ogni stazione implementa *contesa EDCA* sia per il CCH che per gli SCH, con code di priorità interne:

#align(center)[
  #figure(
    cetz.canvas(length: 0.65cm, {
      import cetz.draw: *

      let box-style = (stroke: black, radius: 0.15)
      let w = 2
      let h = 0.8
      
      // Left side - Internal queuing
      content((1, 5.8), text(weight: "bold", size: 0.9em)[Code Interne])
      
      rect((0, 4.5), (w, 4.5 + h), ..box-style, fill: rgb("#C00000"))
      content((w/2, 4.5 + h/2), text(fill: white, size: 0.75em, weight: "bold")[Safety])
      
      rect((0, 3.5), (w, 3.5 + h), ..box-style, fill: rgb("#FFC000"))
      content((w/2, 3.5 + h/2), text(size: 0.75em, weight: "bold")[Event])
      
      rect((0, 2.5), (w, 2.5 + h), ..box-style, fill: rgb("#70AD47"))
      content((w/2, 2.5 + h/2), text(fill: white, size: 0.75em, weight: "bold")[Service])
      
      rect((0, 1.5), (w, 1.5 + h), ..box-style, fill: rgb("#A6A6A6"))
      content((w/2, 1.5 + h/2), text(fill: white, size: 0.75em, weight: "bold")[Background])

      // Internal contention
      let x-cont = 3.5
      rect((x-cont, 3), (x-cont + 1.8, 4.2), ..box-style, fill: rgb("#D9E2F3"))
      content((x-cont + 0.9, 3.6), text(size: 0.75em, weight: "bold")[Contesa\ Interna])

      for i in range(4) {
        let y-from = 4.5 - i + h/2
        line((w, y-from), (x-cont, 3.6), mark: (end: ">"), stroke: (thickness: 0.8pt))
      }

      // Channel selection
      let x-sel = x-cont + 3
      rect((x-sel, 4.5), (x-sel + 1.5, 5 + h), ..box-style, fill: rgb("#E74C3C"))
      content((x-sel + 0.75, 4.7 + h/2), text(fill: white, size: 0.75em, weight: "bold")[CCH\ (178)])
      
      rect((x-sel, 2.5), (x-sel + 1.5, 3.2 + h), ..box-style, fill: rgb("#3498DB"))
      content((x-sel + 0.7, 2.9 + h/2), text(fill: white, size: 0.75em, weight: "bold")[SCH])

      line((x-cont + 1.8, 3.6), (x-sel, 4.9), mark: (end: ">"), stroke: (thickness: 1pt), fill: rgb("#df1212"))
      content((x-cont + 1.8, 4.6), anchor: "south", text(size: 0.65em)[Alta\ priorità])
      
      line((x-cont + 1.8, 3.6), (x-sel, 2.9), mark: (end: ">"), stroke: (thickness: 1pt), fill: rgb("#473ce7"))
      content((x-cont + 2.0, 2.7), anchor: "north", text(size: 0.65em)[Bassa\ priorità])

      // External contention
      let x-ext = x-sel + 2.5
      rect((x-ext, 2), (x-ext + 2.2, 5.2), ..box-style, fill: rgb("#E7E6E6"))
      content((x-ext + 1.1, 3.6), text(size: 0.70em, weight: "bold")[Contesa\ Esterna\ CSMA/CA])

      line((x-sel + 1.5, 4.9), (x-ext, 3.6), mark: (end: ">"), stroke: (thickness: 1pt))
      line((x-sel + 1.5, 2.9), (x-ext, 3.6), mark: (end: ">"), stroke: (thickness: 1pt))

      // Physical channel
      let x-phy = x-ext + 3
      rect((x-phy, 2.5), (x-phy + 1.8, 4.5), ..box-style, fill: rgb("#4472C4"))
      content((x-phy + 0.95, 3.6), text(fill: white, size: 0.75em, weight: "bold")[Canale\ Wireless])

      line((x-ext + 2, 3.6), (x-phy, 3.6), mark: (end: ">"), stroke: (thickness: 1.2pt))
    }),
    caption: [Architettura EDCA multi-canale in 802.11p/WAVE]
  )
]

#nota[
I messaggi safety-critical (BSM) hanno priorità massima e vengono trasmessi sul CCH. I servizi applicativi (infotainment, aggiornamenti mappe) utilizzano gli SCH con priorità inferiore.
]

== Platooning Cooperativo

Il *platooning* è una tecnica di guida cooperativa dove multipli veicoli viaggiano in formazione ravvicinata, coordinando accelerazione e frenata per ridurre il consumo di carburante e migliorare la sicurezza.

=== Obiettivi e Benefici

/ *Riduzione consumi*: Diminuzione della resistenza aerodinamica per i veicoli seguenti (fino al 15-20% di risparmio)

/ *Aumento capacità stradale*: Distanze inter-veicolari ridotte permettono maggiore densità di traffico

/ *Sicurezza*: Coordinamento automatizzato riduce i rischi di collisione a catena

/ *Comfort*: Guida semi-automatica riduce lo stress del conducente

=== Legge di Controllo del Platooning

Ogni veicolo nel platoon esegue una *legge di controllo* che calcola l'accelerazione desiderata basandosi su:

#align(center)[
  #figure(
    cetz.canvas(length: 0.7cm, {
      import cetz.draw: *

      let box-style = (stroke: black, radius: 0.2)
      
      // Input boxes
      rect((0, 5), (2.5, 6), ..box-style, fill: rgb("#4472C4"))
      content((1.25, 5.5), text(fill: white, size: 0.8em, weight: "bold")[Dati Leader\ $(x_L, v_L, a_L)$])
      
      rect((0, 3.5), (2.5, 4.5), ..box-style, fill: rgb("#70AD47"))
      content((1.25, 4), text(fill: white, size: 0.8em, weight: "bold")[Dati Precedente\ $(x_(i-1), v_(i-1))$])
      
      rect((0, 2), (2.5, 3), ..box-style, fill: rgb("#FFC000"))
      content((1.25, 2.5), text(fill: white, size: 0.8em, weight: "bold")[Dati Propri\ $(x_i, v_i, a_i)$])

      // Control law box
      rect((4, 2.5), (7, 5.5), ..box-style, fill: rgb("#E7E6E6"))
      content((5.5, 4.5), text(size: 0.85em, weight: "bold")[Legge di Controllo])
      content((5.5, 3.8), text(size: 0.75em)[Calcolo distanza\ desiderata])
      content((5.5, 3.2), text(size: 0.75em)[Correzione errore])
      content((5.5, 2.8), text(size: 0.75em)[Controllo PID])

      // Arrows
      line((2.5, 5.5), (4, 4.5), mark: (end: ">"), stroke: (thickness: 1pt))
      line((2.5, 4), (4, 4), mark: (end: ">"), stroke: (thickness: 1pt))
      line((2.5, 2.5), (4, 3.5), mark: (end: ">"), stroke: (thickness: 1pt))

      // Output
      rect((8.5, 3), (11, 4.5), ..box-style, fill: rgb("#C00000"))
      content((9.75, 3.75), text(fill: white, size: 0.85em, weight: "bold")[Accelerazione\ Desiderata\ $a_i^"des"$])

      line((7, 4), (8.5, 3.75), mark: (end: ">"), stroke: (thickness: 1.2pt))
    }),
    caption: [Schema della legge di controllo per il platooning]
  )
]

*Input*:
- Stato del *veicolo leader* $L$: posizione $x_L$, velocità $v_L$, accelerazione $a_L$
- Stato del *veicolo precedente* $i-1$: posizione $x_(i-1)$, velocità $v_(i-1)$
- Stato del *veicolo proprio* $i$: posizione $x_i$, velocità $v_i$, accelerazione $a_i$

*Output*:
- Accelerazione desiderata $a_i^"des"$ da applicare al veicolo

=== CACC (Cooperative Adaptive Cruise Control)

Il *CACC* è un'estensione dell'ACC (Adaptive Cruise Control) che utilizza comunicazioni V2V per migliorare le performance del platoon.

==== ACC vs CACC

/ *ACC tradizionale*: Utilizza solo sensori locali (radar, lidar, camera) per misurare la distanza e velocità relativa del veicolo precedente. La policy tipica è:
  $ d_"des" = d_0 + h times v_i $
  dove $d_0$ è la distanza minima di sicurezza e $h$ è il time-gap (tipicamente 1.5-2 secondi).

/ *CACC*: Aggiunge comunicazioni wireless per ricevere informazioni sullo stato del veicolo precedente e del leader, permettendo:
  - *Distanze inter-veicolari costanti* indipendenti dalla velocità
  - *Risposte più rapide* a cambiamenti di accelerazione del leader
  - *Maggiore stabilità* della formazione

#align(center)[
  #figure(
    cetz.canvas(length: 0.7cm, {
      import cetz.draw: *

      // ACC scenario
      content((4, 6.5), text(weight: "bold", size: 1em)[ACC Tradizionale])
      
      // Vehicles at different speeds
      let v1-low = (0, 5)
      let v2-low = (2, 5)
      
      rect((v1-low.at(0), v1-low.at(1)), (v1-low.at(0) + 0.8, v1-low.at(1) + 0.5), fill: rgb("#4472C4"), stroke: black)
      content((v1-low.at(0) + 0.4, v1-low.at(1) + 0.25), text(fill: white, size: 0.7em, weight: "bold")[V1])
      
      rect((v2-low.at(0), v2-low.at(1)), (v2-low.at(0) + 0.8, v2-low.at(1) + 0.5), fill: rgb("#70AD47"), stroke: black)
      content((v2-low.at(0) + 0.4, v2-low.at(1) + 0.25), text(fill: white, size: 0.7em, weight: "bold")[V2])
      
      line((v1-low.at(0) + 0.8, v1-low.at(1) + 0.25), (v2-low.at(0), v2-low.at(1) + 0.25), mark: (start: "|", end: "|"), stroke: (thickness: 0.8pt))
      content((1.4, v1-low.at(1) + 0.6), text(size: 0.65em)[$d_1$])
      
      let v1-high = (5, 5)
      let v2-high = (8, 5)
      
      rect((v1-high.at(0), v1-high.at(1)), (v1-high.at(0) + 0.8, v1-high.at(1) + 0.5), fill: rgb("#4472C4"), stroke: black)
      content((v1-high.at(0) + 0.4, v1-high.at(1) + 0.25), text(fill: white, size: 0.7em, weight: "bold")[V1])
      
      rect((v2-high.at(0), v2-high.at(1)), (v2-high.at(0) + 0.8, v2-high.at(1) + 0.5), fill: rgb("#70AD47"), stroke: black)
      content((v2-high.at(0) + 0.4, v2-high.at(1) + 0.25), text(fill: white, size: 0.7em, weight: "bold")[V2])
      
      line((v1-high.at(0) + 0.8, v1-high.at(1) + 0.25), (v2-high.at(0), v2-high.at(1) + 0.25), mark: (start: "|", end: "|"), stroke: (thickness: 0.8pt))
      content((6.9, v1-high.at(1) + 0.6), text(size: 0.65em)[$d_2 > d_1$])
      
      content((1, 4.3), text(size: 0.7em)[Bassa velocità])
      content((6.5, 4.3), text(size: 0.7em)[Alta velocità])

      // CACC scenario
      content((4, 2.5), text(weight: "bold", size: 1em)[CACC])
      
      let v1-cacc = (0, 1)
      let v2-cacc = (2, 1)
      let v3-cacc = (4, 1)
      
      rect((v1-cacc.at(0), v1-cacc.at(1)), (v1-cacc.at(0) + 0.8, v1-cacc.at(1) + 0.5), fill: rgb("#C00000"), stroke: black)
      content((v1-cacc.at(0) + 0.4, v1-cacc.at(1) + 0.25), text(fill: white, size: 0.7em, weight: "bold")[L])
      
      rect((v2-cacc.at(0), v2-cacc.at(1)), (v2-cacc.at(0) + 0.8, v2-cacc.at(1) + 0.5), fill: rgb("#4472C4"), stroke: black)
      content((v2-cacc.at(0) + 0.4, v2-cacc.at(1) + 0.25), text(fill: white, size: 0.7em, weight: "bold")[V1])
      
      rect((v3-cacc.at(0), v3-cacc.at(1)), (v3-cacc.at(0) + 0.8, v3-cacc.at(1) + 0.5), fill: rgb("#70AD47"), stroke: black)
      content((v3-cacc.at(0) + 0.4, v3-cacc.at(1) + 0.25), text(fill: white, size: 0.7em, weight: "bold")[V2])
      
      line((v1-cacc.at(0) + 0.8, v1-cacc.at(1) + 0.25), (v2-cacc.at(0), v2-cacc.at(1) + 0.25), mark: (start: "|", end: "|"), stroke: (thickness: 0.8pt))
      content((1.4, v1-cacc.at(1) - 0.4), text(size: 0.65em)[$d_"const"$])
      
      line((v2-cacc.at(0) + 0.8, v2-cacc.at(1) + 0.25), (v3-cacc.at(0), v3-cacc.at(1) + 0.25), mark: (start: "|", end: "|"), stroke: (thickness: 0.8pt))
      content((3.4, v1-cacc.at(1) - 0.4), text(size: 0.65em)[$d_"const"$])
      
      // Communication arrows
      line((0.4, 1.6), (2.4, 1.6), mark: (end: ">"), stroke: (paint: blue, thickness: 1pt, dash: "dashed"))
      line((2.4, 1.7), (4.4, 1.7), mark: (end: ">"), stroke: (paint: blue, thickness: 1pt, dash: "dashed"))
      
      content((4, 0.3), text(size: 0.7em)[Distanza costante con V2V])
    }),
    caption: [Confronto tra ACC e CACC: gestione della distanza inter-veicolare]
  )
]

#nota[
CACC permette distanze costanti indipendenti dalla velocità, migliorando l'efficienza aerodinamica. Tuttavia, è meno conservativo rispetto ad ACC in termini di sicurezza, richiedendo comunicazioni affidabili.
]

=== Problematiche di Comunicazione in Platooning

==== Hidden Terminal e Propagazione Multi-hop

In formazioni lunghe, i veicoli in coda potrebbero non ricevere direttamente i messaggi del leader a causa della limitata portata radio (~300 m in 802.11p).

#align(center)[
  #figure(
    cetz.canvas(length: 0.7cm, {
      import cetz.draw: *

      // Leader
      rect((0, 2), (0.8, 2.5), fill: rgb("#C00000"), stroke: black)
      content((0.4, 2.25), text(fill: white, size: 0.7em, weight: "bold")[L])
      
      // Intermediate vehicles
      for i in range(1, 6) {
        let x = i * 1.5
        let col = if i <= 3 { rgb("#4472C4") } else { rgb("#A6A6A6") }
        rect((x, 2), (x + 0.8, 2.5), fill: col, stroke: black)
        content((x + 0.4, 2.25), text(fill: white, size: 0.7em, weight: "bold")[F#i])
      }
      
      // Last vehicle
      rect((9, 2), (9.8, 2.5), fill: rgb("#E74C3C"), stroke: black)
      content((9.4, 2.25), text(fill: white, size: 0.7em, weight: "bold")[F6])

      // Coverage range of leader
      circle((0.4, 2.25), radius: 5, stroke: (paint: rgb("#C00000"), thickness: 1.5pt, dash: "dashed"), fill: none)
      content((0.4, 2.25 + 5.3), text(size: 0.7em, fill: rgb("#C00000"))[Range Leader])

      // Problem indicator
      line((9.4, 1.5), (9.4, 0.5), mark: (end: ">"), stroke: (paint: red, thickness: 2pt))
      content((9.4, 0), text(size: 0.75em, fill: red, weight: "bold")[F6 fuori range!])
    }),
    caption: [Problema del terminale nascosto nel platooning: F6 non riceve direttamente dal leader]
  )
]

*Soluzione*: Ogni veicolo che riceve i dati del leader li *ritrasmette* insieme ai propri dati, implementando una propagazione multi-hop implicita.

==== Problemi di Sincronizzazione e Latenza

I clock dei veicoli non sono sincronizzati, causando propagazione di informazioni con timestamp differenti.

#esempio[
*Scenario problematico*:
1. Tempo $T_0$: Leader invia BSM con stato $(x_L, v_L, a_L)$ al tempo $T_0$
2. Tempo $T_1$: F6 riceve i dati del leader da F1, ma sono già vecchi di $Delta T_1 = T_1 - T_0$
3. Tempo $T_2$: F6 ritrasmette i dati del leader (timestamp $T_0$) insieme ai suoi
4. Tempo $T_3$: Leader invia un nuovo aggiornamento, ma F11 (fuori range) non lo riceve
5. F11 riceve i dati di F6 al tempo $T_4$, contenenti:
   - Stato di F6 aggiornato al tempo $T_4$ ✓
   - Stato del leader vecchio al tempo $T_0$ ✗ (lag di $T_4 - T_0$)

*Conseguenza*: F11 calcola la legge di controllo basandosi su una "fotografia vecchia" dello stato del leader. Man mano che si accumulano ritardi, la reattività del platoon peggiora.
]

#align(center)[
  #figure(
    cetz.canvas(length: 0.6cm, {
      import cetz.draw: *

      // Timeline
      let t0-x = 2
      let t1-x = 4
      let t2-x = 6
      let t3-x = 8
      let t4-x = 10

      line((0, 0), (12, 0), mark: (end: ">"), stroke: (thickness: 1.5pt))
      content((12.5, 0), anchor: "west", text(weight: "bold")[Tempo])

      // Time markers
      for (x, label) in ((t0-x, $T_0$), (t1-x, $T_1$), (t2-x, $T_2$), (t3-x, $T_3$), (t4-x, $T_4$)) {
        line((x, -0.2), (x, 0.2), stroke: (thickness: 1pt))
        content((x, -0.6), text(size: 0.75em, weight: "bold")[#label])
      }

      // Leader transmissions
      let y-leader = 3
      content((0, y-leader), anchor: "east", text(size: 0.8em, weight: "bold")[Leader])
      
      line((t0-x, y-leader), (t0-x + 0.5, y-leader - 0.8), mark: (end: ">"), stroke: (paint: rgb("#C00000"), thickness: 1.5pt))
      content((t0-x + 0.8, y-leader - 0.5), anchor: "west", text(size: 0.65em, fill: rgb("#C00000"))[BSM($T_0$)])
      
      line((t3-x, y-leader), (t3-x + 0.5, y-leader - 0.8), mark: (end: ">"), stroke: (paint: rgb("#C00000"), thickness: 1.5pt))
      content((t3-x + 0.8, y-leader - 0.5), anchor: "west", text(size: 0.65em, fill: rgb("#C00000"))[BSM($T_3$)])

      // F6 operations
      let y-f6 = 1.5
      content((0, y-f6), anchor: "east", text(size: 0.8em, weight: "bold")[F6])
      
      circle((t1-x, y-f6), radius: 0.15, fill: blue)
      content((t1-x, y-f6 + 0.5), anchor: "south", text(size: 0.6em, fill: blue)[Riceve\ $T_0$])
      
      line((t2-x, y-f6), (t2-x + 0.5, y-f6 - 0.6), mark: (end: ">"), stroke: (paint: blue, thickness: 1.2pt))
      content((t2-x + 1.2, y-f6 - 0.3), anchor: "west", text(size: 0.6em, fill: blue)[TX: F6($T_2$)\ + L($T_0$)])

      // F11 operations
      let y-f11 = -1
      content((0, y-f11), anchor: "east", text(size: 0.8em, weight: "bold")[F11])
      
      content((t3-x, y-f11 + 0.6), text(size: 0.6em, fill: red)[✗ Non riceve $T_3$])
      
      circle((t4-x, y-f11), radius: 0.15, fill: rgb("#FFC000"))
      content((t4-x, y-f11 - 0.7), anchor: "north", text(size: 0.6em, fill: rgb("#FFC000"))[Riceve dati\ da F6])
      
      // Staleness indicator
      line((t0-x, -2), (t4-x, -2), mark: (start: "|", end: "|"), stroke: (paint: red, thickness: 1.5pt))
      content((6, -2.5), text(size: 0.7em, fill: red, weight: "bold")[Lag = $T_4 - T_0$])
    }),
    caption: [Problema di sincronizzazione: F11 riceve dati del leader obsoleti]
  )
]

#attenzione[
Il sistema di platooning è progettato per tollerare latenze fino a circa 100-200 ms. Ritardi superiori compromettono la stabilità del controllo. La dinamica del platoon tipicamente cambia su scale temporali dell'ordine del secondo, quindi latenze di pochi cicli di BSM (100-200 ms) sono gestibili, ma l'accumulo progressivo di ritardi può degradare le performance.
]

=== Convergenza e Stabilità

Nonostante i problemi di latenza, sistemi di platooning ben progettati mantengono la *convergenza*:

- L'errore di distanza ($e_i = d_i - d_"des"$) tende a zero nel tempo
- Il platoon si stabilizza su velocità e spaziatura uniformi
- Piccole perturbazioni vengono smorzate lungo la formazione

Tuttavia, ritardi eccessivi possono causare *string instability*, dove oscillazioni si amplificano propagandosi all'indietro nel platoon.

== AODV - Ad hoc On-Demand Distance Vector Routing

Il protocollo *AODV* (RFC 3561) è un protocollo di routing reattivo progettato per *reti wireless ad-hoc*, dove ogni nodo può agire come router senza infrastruttura centralizzata.

=== Caratteristiche Generali

/ *Reti ad-hoc*: Ogni nodo può instradare pacchetti per altri nodi, creando una topologia mesh dinamica

/ *On-demand (Reattivo)*: Le route vengono create solo quando necessario, riducendo l'overhead in reti con traffico sporadico

/ *Stateless*: Lo stato delle route è effimero, mantenuto solo finché necessario (con timeout)

/ *Distance Vector*: Ogni nodo mantiene tabelle di routing indicando la direzione (next hop) e la distanza (hop count) verso le destinazioni

=== Obiettivi di Progettazione

- *Gestire la dinamicità*: Adattarsi a topologie che cambiano frequentemente
- *Auto-inizializzazione*: Nessuna configurazione manuale, scoperta automatica delle route
- *Loop-free*: Prevenire cicli di routing attraverso numeri di sequenza
- *Convergenza rapida*: Creare route velocemente quando richiesto
- *Robustezza*: Rilevare e reagire rapidamente a rotture di link

=== Architettura e Messaggi di Controllo

AODV definisce tre tipi principali di messaggi di controllo, trasmessi come pacchetti UDP sulla porta 654:

#align(center)[
  #figure(
    cetz.canvas(length: 0.7cm, {
      import cetz.draw: *

      let box-style = (stroke: black, radius: 0.2)
      let w = 3
      let h = 1.2

      // RREQ
      rect((0, 4), (w, 4 + h), ..box-style, fill: rgb("#4472C4"))
      content((w/2, 4 + h/2), text(fill: white, weight: "bold", size: 0.85em)[RREQ\ Route Request])
      content((w/2, 3.3), text(size: 0.7em)[Broadcast\ Ricerca percorso])

      // RREP
      rect((4.5, 4), (4.5 + w, 4 + h), ..box-style, fill: rgb("#70AD47"))
      content((4.5 + w/2, 4 + h/2), text(fill: white, weight: "bold", size: 0.85em)[RREP\ Route Reply])
      content((4.5 + w/2, 3.3), text(size: 0.7em)[Unicast\ Conferma percorso])

      // RERR
      rect((9, 4), (9 + w, 4 + h), ..box-style, fill: rgb("#E74C3C"))
      content((9 + w/2, 4 + h/2), text(fill: white, weight: "bold", size: 0.85em)[RERR\ Route Error])
      content((9 + w/2, 3.3), text(size: 0.7em)[Unicast/Broadcast\ Errore link])

      // Data packets
      rect((4.5, 1), (4.5 + w, 1 + h), ..box-style, fill: rgb("#FFC000"))
      content((4.5 + w/2, 1 + h/2), text(fill: white, weight: "bold", size: 0.85em)[DATA\ Pacchetti Dati])
      content((4.5 + w/2, 0.3), text(size: 0.7em)[Protocollo applicazione])

      // Legend
      content((6, 6.5), text(weight: "bold")[Livello di trasporto])
      content((2, 6), text(size: 0.7em)[Messaggi controllo: UDP porta 654])
      content((7.5, 6), text(size: 0.7em)[Dati: protocollo applicativo])
    }),
    caption: [Messaggi di controllo AODV e pacchetti dati]
  )
]

/ *RREQ (Route Request)*: Trasmesso in broadcast (IP 255.255.255.255) quando un nodo cerca un percorso verso una destinazione. Ogni nodo intermedio registra il percorso inverso per permettere la risposta.

/ *RREP (Route Reply)*: Trasmesso in unicast dalla destinazione (o da un nodo intermedio con informazioni fresche) verso l'originator lungo il percorso inverso creato dalla RREQ.

/ *RERR (Route Error)*: Trasmesso quando un link si rompe, invalidando le route che lo utilizzano.

#nota[
I messaggi di controllo AODV viaggiano a livello IP come pacchetti UDP porta 654. I pacchetti dati invece seguono il normale stack protocollare dell'applicazione. Entrambi utilizzano come base i pacchetti IP con indirizzi sorgente e destinazione.
]

=== Tabella di Routing

Ogni nodo AODV mantiene una tabella di routing con le seguenti informazioni per ogni destinazione:
/*
#align(center)[
  #figure(
    {
      set text(size: 0.75em)
      table(
        columns: (2.5fr, 4fr),
        align: (left, left),
        fill: (col, row) => if row == 0 { rgb("#4472C4") } else if calc.rem(row, 2) == 1 { rgb("#D9E2F3") } else { white },
        stroke: (x, y) => (
          left: 0.5pt,
          right: 0.5pt,
          top: if y == 0 { 1pt } else { 0.5pt },
          bottom: 1pt,
        ),
        text(fill: white, weight: "bold")[Campo], 
        text(fill: white, weight: "bold")[Descrizione],
        
        [Destination IP], [Indirizzo IP della destinazione],
        [Destination Sequence #], [Numero di sequenza della destinazione (freschezza)],
        [Valid Dest Seq Flag], [Indica se il sequence number è valido],
        [Route Status], [Valido, Invalido, Sospeso (in riparazione)],
        [Network Interface], [Interfaccia di rete da utilizzare],
        [Hop Count], [Numero di hop verso la destinazione],
        [Next Hop], [Prossimo nodo nel percorso],
        [Lifetime], [Tempo di scadenza della entry (timeout)],
      )
    },
    caption: [Struttura della entry nella tabella di routing AODV]
  )
]*/

=== Sequence Number

Il *Sequence Number* è il meccanismo fondamentale di AODV per garantire loop-freedom e freschezza delle informazioni:

/ *Incremento*: Il sequence number di un nodo viene incrementato solo dal nodo stesso in due casi:
  1. Quando inizia una nuova ricerca di percorso (RREQ)
  2. Quando risponde a una RREQ come destinazione (RREP)

/ *Aggiornamento*: Un nodo può aggiornare il sequence number di una entry nella sua tabella solo se:
  - Riceve informazioni più fresche (SN maggiore) per quella destinazione
  - È il nodo stesso (destinazione)
  - La entry scade (timeout)

/ *Confronto*: Quando si confrontano due route per la stessa destinazione:
  $ "SN"_1 > "SN"_2 => "Route"_1 "è più fresca" $
  $ "SN"_1 = "SN"_2 => "confronta hop count" ("minore è meglio") $

#nota[
Il sequence number cresce monotonicamente e garantisce che route loops non si formino, poiché solo informazioni più fresche (SN maggiore) vengono accettate.
]

=== Formato RREQ (Route Request)

Il messaggio RREQ contiene i seguenti campi principali:
/*
#align(center)[
  #figure(
    {
      set text(size: 0.75em)
      table(
        columns: (2fr, 1fr, 4fr),
        align: center + horizon,
        fill: (col, row) => if row == 0 { rgb("#4472C4") } else if calc.rem(row, 2) == 1 { rgb("#D9E2F3") } else { white },
        text(fill: white, weight: "bold")[Campo],
        text(fill: white, weight: "bold")[Bit],
        text(fill: white, weight: "bold")[Significato],
        
        [Type], [8], [Tipo di messaggio (1 = RREQ)],
        [Flags], [5], [J, R, *G*, *D*, *U*],
        [Reserved], [11], [Riservato],
        [Hop Count], [8], [Numero di hop dalla origine],
        [RREQ ID], [32], [Identificatore univoco della richiesta],
        [Destination IP], [32], [Indirizzo IP della destinazione cercata],
        [Destination Seq #], [32], [Ultimo SN noto della destinazione],
        [Originator IP], [32], [Indirizzo IP del nodo origine],
        [Originator Seq #], [32], [Sequence number del nodo origine],
      )
    },
    caption: [Formato del messaggio RREQ]
  )
]*/

*Flag importanti*:
- *G (Gratuitous RREP)*: Se settato, la destinazione invia anche una RREP all'indietro per creare una route bidirezionale
- *D (Destination Only)*: Solo la destinazione può rispondere, i nodi intermedi non possono inviare RREP anche se conoscono la route
- *U (Unknown Sequence Number)*: L'origine non conosce il SN della destinazione

=== Creazione e Propagazione RREQ

==== Quando Creare una RREQ

Un nodo crea una RREQ quando:
- Non ha una route valida verso la destinazione
- La route esistente è scaduta (lifetime = 0)
- La route è stata marcata come invalida (RERR ricevuto)

==== Step di Creazione

1. Incrementa il proprio SN: $"Originator_SN"++$
2. Incrementa RREQ_ID: $"RREQ_ID"++$
3. Se la destinazione è sconosciuta, imposta flag $U = 1$
4. Memorizza la coppia $("Originator_IP", "RREQ_ID")$ per rilevare duplicati
5. Imposta il TTL in base alla strategia di ricerca

==== Expanding Ring Search

Per ridurre l'overhead, AODV utilizza la tecnica *Expanding Ring Search*:

#align(center)[
  #figure(
    cetz.canvas(length: 0.7cm, {
      import cetz.draw: *

      let center = (5, 3)
      
      // Origin node
      circle(center, radius: 0.3, fill: rgb("#C00000"), stroke: black)
      content(center, text(fill: white, weight: "bold", size: 0.8em)[S])

      // Expanding circles
      for (r, label, col) in ((1.5, $"TTL"_"start"$, rgb("#4472C4")), (3, $"TTL"_"start" + "TTL"_"inc"$, rgb("#70AD47")), (4.5, $"TTL"_"diameter"$, rgb("#FFC000"))) {
        circle(center, radius: r, stroke: (paint: col, thickness: 1.5pt, dash: "dashed"), fill: none)
        content((center.at(0), center.at(1) + r + 0.4), text(size: 0.7em, fill: col)[#label])
      }

      // Timer indicators
      line((8, 5), (10, 5), mark: (end: ">"), stroke: (thickness: 1pt))
      content((9, 5.4), text(size: 0.7em)[Tempo])
      
      content((9, 4.5), text(size: 0.65em)[1° tentativo])
      content((9, 3.8), text(size: 0.65em)[Se fallisce...])
      content((9, 3.1), text(size: 0.65em)[2° tentativo])
      content((9, 2.4), text(size: 0.65em)[Se fallisce...])
      content((9, 1.7), text(size: 0.65em)[3° tentativo])
    }),
    caption: [Expanding Ring Search: ricerca progressiva con TTL crescente]
  )
]

*Parametri*:
- $"TTL"_"start"$: TTL iniziale basso (es. 2), assumendo destinazione vicina
- $"TTL"_"increment"$: Incremento ad ogni fallimento (es. +2)
- $"TTL"_"net_diameter"$: TTL massimo (es. 35), diametro massimo della rete

*Vantaggi*:
- Riduce overhead se la destinazione è vicina (caso comune)
- Evita flooding completo se non necessario

*Caso speciale*: Se esiste una entry invalida per la destinazione con hop count noto (es. 10), la ricerca parte con $"TTL" = 10$ invece di $"TTL"_"start"$.

==== Gestione Ricezione RREQ - Scarto

Quando un nodo riceve una RREQ, verifica se ha già visto la coppia $("Originator_IP", "RREQ_ID")$:

*Se già vista* (duplicato):
1. Scarta la RREQ (non inoltra)
2. Confronta $"Originator_SN"$ nella RREQ con quello in tabella:
   $ "SN"_"RREQ" > "SN"_"table" => "Aggiorna tabella" $
3. Aggiorna/crea il *percorso inverso* verso l'originator:
   - Next Hop = nodo da cui è arrivata la RREQ
   - Hop Count = Hop Count della RREQ + 1
   - Destination SN = Originator SN dalla RREQ

#esempio[
Nodo D riceve una RREQ duplicata da A via B:
- RREQ contiene: Originator IP = A, Originator SN = 200
- Tabella di D contiene: $angle.l A, E, 4, 199 angle.r$
- Azione: Scarta RREQ, ma aggiorna entry: $angle.l A, B, 2, 200 angle.r$
  (percorso più fresco via B in 2 hop invece che via E in 4 hop)
]

==== Gestione Ricezione RREQ - Inoltro

*Se non ancora vista*:
1. Memorizza $("Originator_IP", "RREQ_ID")$
2. Crea/aggiorna percorso inverso verso originator (come sopra)
3. Incrementa $"Hop_Count"++$
4. Aggiorna $"Destination_SN"$ nella RREQ se ne possiede uno più recente
5. Decrementa TTL: $"TTL"--$
6. Se $"TTL" > 0$: ritrasmette RREQ in broadcast

#align(center)[
  #figure(
    cetz.canvas(length: 0.6cm, {
      import cetz.draw: *

      // Network topology
      let nodes = (
        ("A", (2, 4)),
        ("B", (5, 5)),
        ("C", (8, 4)),
        ("D", (5, 2.5)),
        ("E", (2, 1)),
        ("F", (8, 1)),
        ("G", (11, 2.5)),
        ("H", (14, 3)),
      )

      // Draw nodes
      for (name, pos) in nodes {
        let col = if name == "A" { rgb("#C00000") } else if name == "H" { rgb("#70AD47") } else { rgb("#4472C4") }
        circle(pos, radius: 0.4, fill: col, stroke: black)
        content(pos, text(fill: white, weight: "bold")[#name])
      }

      // RREQ propagation arrows
      let arrows = (
        ((2, 4), (5, 5)),
        ((2, 4), (5, 2.5)),
        ((5, 5), (8, 4)),
        ((5, 2.5), (8, 4)),
        ((5, 2.5), (8, 1)),
        ((8, 4), (11, 2.5)),
        ((8, 1), (11, 2.5)),
        ((11, 2.5), (14, 3)),
      )

      for (start, end) in arrows {
        line(start, end, mark: (end: ">"), stroke: (paint: blue, thickness: 1.2pt, dash: "dashed"))
      }

      // Labels
      content((2, 5), anchor: "south", text(size: 0.75em, fill: rgb("#C00000"), weight: "bold")[Originator])
      content((14, 3.8), anchor: "south", text(size: 0.75em, fill: rgb("#70AD47"), weight: "bold")[Destination])
      
      content((4, 6), text(size: 0.7em, fill: blue)[RREQ\ Broadcast])
    }),
    caption: [Propagazione RREQ da A a H attraverso la rete]
  )
]

#nota[
Mentre la RREQ si propaga, ogni nodo intermedio costruisce il *percorso inverso* verso l'originator. Questo percorso sarà utilizzato dalla RREP per tornare indietro in unicast.
]

=== Generazione RREP (Route Reply)

Una RREP viene generata quando:
1. La RREQ raggiunge la destinazione finale
2. Un nodo intermedio ha una route valida e sufficientemente fresca verso la destinazione (se flag D=0)

*Condizione di freschezza* per risposta intermedia:
$ "Destination_SN"_"table" >= "Destination_SN"_"RREQ" $

La RREP viene trasmessa in *unicast lungo il percorso inverso* creato dalla RREQ.

#align(center)[
  #figure(
    cetz.canvas(length: 0.6cm, {
      import cetz.draw: *

      // Nodes
      let nodes = (
        ("A", (2, 3)),
        ("B", (5, 4)),
        ("D", (5, 2)),
        ("C", (8, 3)),
        ("H", (11, 3)),
      )

      for (name, pos) in nodes {
        let col = if name == "A" { rgb("#C00000") } else if name == "H" { rgb("#70AD47") } else { rgb("#4472C4") }
        circle(pos, radius: 0.4, fill: col, stroke: black)
        content(pos, text(fill: white, weight: "bold")[#name])
      }

      // RREQ forward (dashed blue)
      line((2, 3), (5, 4), mark: (end: ">"), stroke: (paint: blue, thickness: 1pt, dash: "dashed"))
      line((5, 4), (8, 3), mark: (end: ">"), stroke: (paint: blue, thickness: 1pt, dash: "dashed"))
      line((5, 2), (8, 3), mark: (end: ">"), stroke: (paint: blue, thickness: 1pt, dash: "dashed"))
      line((8, 3), (11, 3), mark: (end: ">"), stroke: (paint: blue, thickness: 1pt, dash: "dashed"))
      
      content((3.5, 3.7), anchor: "south", text(size: 0.6em, fill: blue)[RREQ])
      content((6.5, 3.6), anchor: "south", text(size: 0.6em, fill: blue)[RREQ])

      // RREP backward (solid green)
      line((11, 3), (8, 3), mark: (end: ">"), stroke: (paint: rgb("#70AD47"), thickness: 1.5pt))
      line((8, 3), (5, 4), mark: (end: ">"), stroke: (paint: rgb("#70AD47"), thickness: 1.5pt))
      line((5, 4), (2, 3), mark: (end: ">"), stroke: (paint: rgb("#70AD47"), thickness: 1.5pt))

      content((9.5, 3.3), anchor: "north", text(size: 0.65em, fill: rgb("#70AD47"), weight: "bold")[RREP])
      content((6.5, 3.3), anchor: "north", text(size: 0.65em, fill: rgb("#70AD47"), weight: "bold")[RREP])
      content((3.5, 3.3), anchor: "north", text(size: 0.65em, fill: rgb("#70AD47"), weight: "bold")[RREP])

      // Legend
      content((6.5, 0.5), text(size: 0.7em)[Percorso selezionato: A → B → C → H])
    }),
    caption: [RREP torna in unicast lungo il percorso inverso creato dalla RREQ]
  )
]

Ogni nodo intermedio che inoltra la RREP:
- Crea/aggiorna la route forward verso la destinazione
- Incrementa Hop Count nella RREP
- Imposta il lifetime della route

#nota[
*Criterio di selezione della route*: Se un nodo riceve multiple RREQ per la stessa ricerca:
1. Sequence Number maggiore vince (route più fresca)
2. A parità di SN, Hop Count minore vince (route più corta)

Solo la "migliore" RREQ viene inoltrata e utilizzata per costruire il percorso inverso.
]

=== Route Error (RERR)

Quando un link si rompe (es. un nodo si muove fuori range), i nodi adiacenti rilevano il fallimento e inviano RERR per invalidare tutte le route che utilizzavano quel link.

Il RERR viene propagato a monte verso tutti i nodi che utilizzavano la route rotta, permettendo loro di:
- Invalidare le entry nella routing table
- Eventualmente iniziare una nuova route discovery

#attenzione[
AODV è sensibile alla mobilità: link breaks frequenti causano overhead significativo di RERR e nuove RREQ. In reti altamente dinamiche, protocolli proattivi o ibridi potrebbero essere più efficienti.
]

=== Esempio Completo di Route Discovery

#esempio[
*Scenario*: Nodo A cerca una route verso H

*Stato iniziale*:
- Nodo F conosce: $angle.l H, G, 2, 139 angle.r$
- Nodo D conosce: $angle.l A, E, 4, 199 angle.r$

*RREQ da A*:
- Destination: H
- Dest SN: 140
- Originator: A
- Orig SN: 200
- Hop Count: 0

*Propagazione*:
1. A trasmette RREQ in broadcast
2. B riceve RREQ:
   - Non conosce A → crea entry: $angle.l A, A, 1, 200 angle.r$
   - Incrementa Hop Count → 1
   - Ritrasmette RREQ
3. D riceve RREQ da B:
   - Aveva entry: $angle.l A, E, 4, 199 angle.r$
   - RREQ ha SN = 200 > 199 → aggiorna: $angle.l A, B, 2, 200 angle.r$
   - Percorso più fresco e più corto!
4. RREQ raggiunge H attraverso il percorso A → B → C → H

*RREP da H*:
- H genera RREP e la invia in unicast verso A
- Ogni nodo intermedio (C, B) crea la forward route verso H
- A riceve RREP e può iniziare a trasmettere dati

*Percorso finale stabilito*: A ↔ B ↔ C ↔ H
]

#nota[
In caso di route multiple con stesso SN, vince quella con hop count minore. A parità di hop count, può essere selezionata quella ricevuta per prima (dipendente dall'implementazione).
]
