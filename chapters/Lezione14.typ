#import "../template.typ": *

== Architettura eNodeB

La gestione degli eNodeB viene cambiata rispetto a LTE. Se in LTE avevamo un eNodeB che gestiva tutte le funzioni di controllo e data plane, in 5G avvien una *separazione tra* la parte di data plane *Remote Radio Head* (RRH) e la parte di controllo *Base Band Unit* (BBU).

L'idea è che di inserire la parte di controllo (*BBU*) in un *data center centralizzato*, mentre la parte di data plane (RRH) rimane distribuita geograficamente. La gestione dei vari RRH è quindi _centralizzata_. Inoltre, la BBU viene virtualizzata e diventa una *Virtual Base Band Unit* (vBBU). Essa può essere istanziata dinamicamente in base al traffico e alle esigenze della rete.

I vantaggi di questa operazione riguardano principalmente il lato economico, in particolare:

- *Riduzione CAPEX* (Investimento di capitale): Si ha una *riduzione del numero di componenti hardware* necessari per costruire la rete (meno BBU dentro le stazioni radio). Questo si traduce in un risparmio sui costi di acquisto e installazione, serve meno capitale di investimento per costruire la rete


- *Riduzione OPEX* (Investimento di esercizio: quanto costa far funzionare la rete): Grazie alla virtualizzazione è alla centralizzazione, si ha una *riduzione dei costi operativi* (manutenzione, consumi energetici, spazio occupato). Inoltre grazie alle virtual BBE l'allocazione delel risorse viene ottimizzata.

- *Incremento prestazionale*: Se il traffico in una certa cella aumenta, possono essere istanziate più vBBU per gestire più utenti. Inoltre, la *densificazione è più sostenibile*: vengono installati più siti radiomobili (macro, pico, Femto) di dimensioni diverse. Si sfrutta la scalabilità orizzontale per la loro gestione tramite vBBU.


== Cloud Computing

Il Cloud computing è un paradigma che permette di accedere a risorse computazionali in modo flessibile e scalabile attraverso internet.

Caratteristiche principali:
- *Varietà dei serivizi*: Offre diversi tipi di servizi.

- *Scalabilità dinamica* orizzontale in base al traffico (traffico più alto aumento le istanze di un servizio).

- *Riduzione di CAPEX e OPEX*: non faccio spese in anticipo, ma pago solamente per quello che consumo.

- *Alta affidabilità e disponibilità*: Se un server si guasta, le istanze vengono spostate su altri server. Inoltre, vengono garantite anche la ridondanza e replica dei dati.

- *Alti livelli di virtualizzazione e utilizzo del hardware*: L'utilizzo del hardware è efficiente, in quanto i core delle varie macchine possono essere utilizzati per più istanze.

Da un punto di vista architetturale, il cloud viene posizionato dietro il livello _internet_. Davanti al layer _internet_, andiamo a posizionare la rete mobile (rete ISP), a sua volta divisa in :
- *Rete Mobile Core*: si occupa di gestire la parte di controllo e data plane della rete mobile.

- *Mobile edge*: è la parte di rete che si trova più vicina all'utente, in cui vengono posizionate le stazioni radio (eNodeB) e i mini-datacenter (MEC host).

#nota[
  Il percorso che i dati di un UE devono fare è il seguente:
  Da UE a gatawey della rete mobile. Da cui i dati vengono instradati verso un AS (Autonomous System) che contiene gli internet service provider (ISP) che offrono servizi di cloud computing.
]

$mr("Problemi")$:
- *Elevata latenza* (distanza tra utente e data center): Latenza elevata solamente per attreversare la rete mobile. Solitamente i servizi cloud sono _lontani_

- *Elevato jitter* (variazione della latenza): La *latenza non è stabile*, ma varia nel tempo. Questo è un problema per applicazioni real time (es. gaiming, videochiamate).

  #nota()[
    Il round trip time (RTT) è elevato e variabile. Applicazioni con _buffer stream_ permettono di nascondere l'effetto del jitter (ad esempio video straming), ma per applicazioni real time è un problema.
  ]


Utenti in prossimità utilizzando cloud e non in modalità peer.

=== MEC (ETSI)

Per evitare le problematiche relative al cloud si è pensato di *avvicinare la computazione all'utente finale*, posizionando i servizi più vicini possibile all'utente, in modo da ridurre latenza e jitter.

Tale concetto prende il nome di *MEC* (Mobile edge computing) oppure *MEC* (Multi-access edge computing):

Data una rete geograficamente distribuita e eterogenea (nodi con diversi tipi di capacità computazionale), l'idea è che man mano che ci trasferiamo dai dispositivi edge (UE) al cloud, la capacità computazionale aumenta, ma di conseguenza anche la latenza.

#nota()[
  Più vicini siamo all'utente finale minore è la latenza, ma minore è la capacità computazionale.
]

Si crea quindi un *problema di assegnazione*: dove posizione i *nodi di computazione (moduli)* in una rete geograficamente distribuita, in modo da soddisfare i requisiti dei servizi e sfruttare al meglio le risorse della rete. Tipicamente bisogna tenere in considerazione:
- *Requisiti del modulo*: requisiti di risorse (CPU, memoria, ecc.) per eseguire un modulo in un certo nodo della rete.

- *Requisiti dei link*: requisiti di latenza per mandare un dato da un modulo all'altro.

#nota[
  è l'*orchestratore* che si occupa di risolvere questo problema di assegnazione, decidendo dove istanziare i vari moduli dell'applicazione (solitamente microservizi).
]

==== Architettura ESTI MEC
L'ESTI ha proposto uno standard per l'architettura MEC

#figure(
  align(center)[
    #cetz.canvas(length: 0.75cm, {
      import cetz.draw: *

      let color-mgmt = rgb("#E8F4F8")
      let color-host = rgb("#FFF9E6")
      let color-platform = rgb("#E6F2FF")
      let color-nfvi = rgb("#F0F0F0")
      let color-network = rgb("#FFE6E6")


      // Freccia verticale "Management and Orchestration"
      content((0.9, 14.25), text(size: 10pt, "Management and Orchestration"), anchor: "center")

      // Box MEC system level management (in alto al centro)
      rect((4.5, 13), (14.5, 15.5), stroke: black + 1.5pt, fill: color-mgmt, radius: 0.1)
      content((9.5, 15), text(size: 8pt, weight: "bold", "MEC system level management"))

      // Linea tratteggiata sotto management
      line((0, 12.7), (15, 12.7), stroke: (paint: gray, thickness: 0.8pt, dash: "dashed"))

      // Box principale MEC host (grande box centrale)
      rect((4.5, 2.5), (11.5, 12.3), stroke: black + 1.5pt, fill: white, radius: 0.1)
      content((8, 11.85), text(size: 8pt, weight: "bold", "MEC host"))


      // Box MEC applications (in alto dentro MEC host)
      rect((4.8, 9.3), (11.2, 11.5), stroke: black + 1pt, fill: color-platform, radius: 0.1)
      content((8, 11.1), text(size: 7.5pt, weight: "bold", "MEC applications"))

      // Quattro box MEC app
      let app-y = 10.1
      for i in range(4) {
        let x-pos = 5.2 + i * 1.5
        rect((x-pos, app-y - 0.5), (x-pos + 1.2, app-y + 0.3), stroke: black + 0.6pt, fill: white, radius: 0.08)
        content((x-pos + 0.6, app-y - 0.1), text(size: 6pt, "MEC app"))
      }

      // Box MEC platform
      rect((4.8, 6.8), (11.2, 9.0), stroke: black + 1pt, fill: color-platform, radius: 0.1)
      content((8, 8.6), text(size: 7.5pt, weight: "bold", "MEC platform"))

      // Contenuto MEC platform
      content((8, 8.1), text(size: 6pt, "..."))
      content((8, 7.6), text(size: 6pt, "..."))
      content((8, 7.1), text(size: 6pt, "..."))

      // Box Virtualisation infrastructure (NFVI)
      rect((4.8, 4.5), (11.2, 6.5), stroke: black + 1pt, fill: color-nfvi, radius: 0.1)
      content((8, 6.15), text(size: 7.5pt, weight: "bold", "Virtualisation infrastructure"))
      content((8, 5.85), text(size: 6.5pt, "(e.g. NFVI)"))

      // Sotto-elementi NFVI
      content((8, 5.3), text(size: 6pt, "Virtual compute"))
      content((8, 5.0), text(size: 6pt, "Virtual storage"))
      content((8, 4.7), text(size: 6pt, "Virtual network"))

      // Box Data plane dentro MEC host (in basso)
      rect((4.8, 2.8), (11.2, 4.2), stroke: black + 1pt, fill: white, radius: 0.1)
      content((8, 3.8), text(size: 7pt, weight: "bold", "Data plane"))
      content((8, 3.3), text(size: 6pt, "Traffic rules control"))

      // Box MEC host level management (a destra)
      rect((12, 2.5), (14.5, 12.3), stroke: black + 1.5pt, fill: color-mgmt, radius: 0.1)
      content((13.25, 11.4), text(size: 7pt, weight: "bold", "MEC host"), anchor: "center")
      content((13.25, 11.0), text(size: 7pt, weight: "bold", "level"), anchor: "center")
      content((13.25, 10.6), text(size: 7pt, weight: "bold", "management"), anchor: "center")

      // Punti nel box management
      for i in range(5) {
        content((13.25, 9.5 - i * 1.2), text(size: 6pt, "..."))
      }

      // Freccia verticale "MEC host level"
      content((0.9, 7.4), text(size: 10pt, "MEC host level"), anchor: "center")

      // Linea tratteggiata sotto MEC host
      line((0, 2.2), (15, 2.2), stroke: (paint: gray, thickness: 0.8pt, dash: "dashed"))

      // Box Networks (in basso)
      content((1.5, 1.5), text(size: 10pt, "Networks"), anchor: "center")

      // Tre box di rete
      let networks = ("3GPP\nnetwork", "Local\nnetwork", "External\nnetwork")
      for (i, net) in networks.enumerate() {
        let x-pos = 5 + i * 2.3
        rect((x-pos, 0.5), (x-pos + 1.8, 1.8), stroke: black + 0.8pt, fill: color-network, radius: 0.1)
        content((x-pos + 0.9, 1.15), text(size: 6.5pt, net), anchor: "center")
      }
      // Box "..." finale
      rect((11.9, 0.5), (13.2, 1.8), stroke: black + 0.8pt, fill: color-network, radius: 0.1)
      content((12.55, 1.15), text(size: 8pt, "..."), anchor: "center")

      // Connessioni tra i livelli
      // Da MEC platform a NFVI
      line((8, 6.8), (8, 6.5), stroke: (paint: gray, dash: "dotted", thickness: 0.6pt))

      // Da NFVI a Data plane
      line((8, 4.5), (8, 4.2), stroke: (paint: gray, dash: "dotted", thickness: 0.6pt))

      // Da Data plane a Networks
      line((8, 2.8), (8, 1.8), stroke: (paint: gray, dash: "dotted", thickness: 0.6pt))
    })
  ],
  caption: [Architettura ESTI MEC (European Telecommunications Standards Institute - Multi-access Edge Computing)],
)

- *MEC*: Ha una visione su tutti i dataset distribuiti geograficamente.

- *MEC HOST*: Un'istanza per ogni mini-datacenter. Esso si trova vicino alla stazione radio (eNodeB) e ospita le applicazioni MEC. Il layer è composto da tre livelli principali:
  - *MEC applications*: applicazioni che vengono eseguite all'interno del MEC host. Possono essere applicazioni di terze parti o applicazioni gestite dall'operatore di rete.
  - *MEC platform*: fornisce servizi e funzionalità di supporto per le applicazioni MEC, come ad esempio gestione delle risorse, orchestrazione, sicurezza, ecc.
  - *Virtualisation infrastructure* (es. NFVI): virtualizza le risorse del mini-datacenter, permettendo di eseguire più istanze di applicazioni MEC in modo efficiente e flessibile.


- *Network*: A questo livello troviamo le reti che si collegano al MEC host, tra cui:
  - *3GPP network*: è la rete mobile (LTE, 5G) che collega gli utenti finali al MEC host.
  - *Local network*: è una rete locale che può essere utilizzata per connettere il MEC host ad altri dispositivi o servizi nelle vicinanze (ad esempio, una rete aziendale).
  - *External network*: è la rete esterna (ad esempio, internet) a cui il MEC host può accedere per comunicare con servizi cloud o altre risorse esterne.

== 3GPP

Se in LTE la differenzazzione del traffico in base ai QoS avveniva tramite i bearer, in 5G vengono introdotti i *network slicing*.

*Network slicing*: Si tratta di un concetto che trasforma la rete da un paradigma statico ad un *paradigma dinamico* dove le reti logiche vengono create on demand con risorse e topologie ottimizzate per servire uno scopo specifico/una categoria di servizi o singoli utenti.

Nel 4G, per garantire una certa qualità del servizio (QoS), si utilizzavano i bearer senza modificare l'architettura della rete. L'infrastruttura, i nodi attraversati dai dati e la topologia della rete rimangono identici per tutti gli utenti.

#nota()[
  I bearer sono solo dei tunnel logici.
]

In 5G l'introduzione dei network slicing permette di creare *reti logiche separate* (slice) che possono avere caratteristiche diverse per utenti o applicazioni diverse:
- *Topologia*: Che percorso devono fare i dati.

- *Nodi coinvolti*: Quali server, router virtuali o nodi MEC devono far parte di quella specifica porzione di rete.

- *Funzioni di rete*: Quali protocolli di sicurezza o di instradamento attivare.

Un'*istanza* di una network slice è un insieme di network function e risorse di rete (fisiche) che sono organizzate e configurate per fornire una rete logica che soddisfa certe caratteristiche.

#informalmente()[
  In 5g creiamo delle _fette_ che attraversano la rete, ciascuna con delle caratteristiche diverse. Per farlo, usiamo le seguenti tecnologie:
  - SDN
  - NFV
  - MEC
]

== Struttura Data Plane e Control Plane

In 5G, la rete è divisa in due piani principali: *data plane* e *control plane*.

=== LTE CUPS

Si tratta di una delle ultime evoluzioni di LTE, che ha introdotto la separazione tra data plane e control plane. In particolare, i nodi service gateway (SGW) e packet gateway (PGW) vengono divisi in due parti: una parte di data plane e una parte di control plane.

Si crea quindi una *netta separazione* tra le operazioni di data plane (instradamento, gestione dei template) e le operazioni di controllo (gestione della mobilità, ecc..). Il vantaggio principale è che possiamo scalare in modo indipendente le due parti. Ad esempio, se abbiamo un aumento del traffico dati, possiamo scalare solo la parte di data plane, senza dover scalare anche la parte di controllo.

#figure(
  align(center)[
    #cetz.canvas(length: 1cm, {
      import cetz.draw: *

      let color-control = rgb("#4A90E2")
      let color-external = rgb("#FF6B6B")
      let color-user = rgb("#90EE90")
      let color-signaling = gray
      let color-data = red
      let color-bus = rgb("#FFA500")

      // Titoli dei piani
      content((1.2, 5.2), text(size: 10pt, weight: "bold", "Control Plane"), anchor: "west")
      content((1, 2.5), text(size: 10pt, weight: "bold", "User Plane"), anchor: "west")

      // === CONTROL PLANE ===

      // Bus di comunicazione (Service-based Architecture Bus)
      rect((2.5, 5.8), (14.8, 6.2), stroke: color-bus + 1.5pt, fill: color-bus.lighten(70%), radius: 0.1)
      content((8.65, 6), text(size: 7pt, weight: "bold", "Service-based Architecture (SBA) Bus"), anchor: "center")

      // Prima riga Control Plane
      rect((3, 6.5), (4.5, 7.5), stroke: black + 1pt, fill: color-control, radius: 0.1)
      content((3.75, 7), text(size: 8pt, weight: "bold", "NSSF"))

      rect((5, 6.5), (6.5, 7.5), stroke: black + 1pt, fill: color-external, radius: 0.1)
      content((5.75, 7), text(size: 8pt, weight: "bold", "NEF"))

      rect((7, 6.5), (8.5, 7.5), stroke: black + 1pt, fill: color-external, radius: 0.1)
      content((7.75, 7), text(size: 8pt, weight: "bold", "NRF"))

      rect((9, 6.5), (10.5, 7.5), stroke: black + 1pt, fill: color-control, radius: 0.1)
      content((9.75, 7), text(size: 8pt, weight: "bold", "PCF"))

      rect((11, 6.5), (12.5, 7.5), stroke: black + 1pt, fill: color-control, radius: 0.1)
      content((11.75, 7), text(size: 8pt, weight: "bold", "UDM"))

      rect((13, 6.5), (14.5, 7.5), stroke: black + 1pt, fill: color-control, radius: 0.1)
      content((13.75, 7), text(size: 8pt, weight: "bold", "AF"))

      // Connessioni al bus dalla prima riga
      for x in (3.75, 5.75, 7.75, 9.75, 11.75, 13.75) {
        line((x, 6.5), (x, 6.2), stroke: (paint: color-bus, thickness: 1pt))
      }

      // Seconda riga Control Plane (Nausf, Namf, Nsmf labels sotto)
      content((5.75, 5.7), text(size: 7pt, "Nausf"), anchor: "center")
      content((7.75, 5.7), text(size: 7pt, "Namf"), anchor: "center")
      content((9.75, 5.7), text(size: 7pt, "Nsmf"), anchor: "center")
      content((11.75, 5.7), text(size: 7pt, "Nudm"), anchor: "center")
      content((13.75, 5.7), text(size: 7pt, "Nnef"), anchor: "center")

      // AUSF, AMF, SMF
      rect((5, 4.5), (6.5, 5.5), stroke: black + 1pt, fill: color-control, radius: 0.1)
      content((5.75, 5), text(size: 8pt, weight: "bold", "AUSF"))

      rect((7, 4.5), (8.5, 5.5), stroke: black + 1pt, fill: color-control, radius: 0.1)
      content((7.75, 5), text(size: 8pt, weight: "bold", "AMF"))

      rect((9, 4.5), (10.5, 5.5), stroke: black + 1pt, fill: color-control, radius: 0.1)
      content((9.75, 5), text(size: 8pt, weight: "bold", "SMF"))

      // Connessioni al bus dalla seconda riga
      for x in (5.75, 7.75, 9.75) {
        line((x, 5.5), (x, 5.8), stroke: (paint: color-bus, thickness: 1pt))
      }

      // Linea di separazione tra Control Plane e User Plane
      line((2, 4), (15, 4), stroke: (paint: black, thickness: 1.5pt, dash: "dashed"))

      // === USER PLANE ===

      // UE
      rect((3, 1.5), (4.5, 2.5), stroke: black + 1pt, fill: color-user, radius: 0.1)
      content((3.75, 2), text(size: 8pt, weight: "bold", "UE"))

      // (R)AN
      rect((6, 1.5), (7.5, 2.5), stroke: black + 1pt, fill: color-user, radius: 0.1)
      content((6.75, 2), text(size: 8pt, weight: "bold", "(R)AN"))

      // UPF
      rect((9, 1.5), (10.5, 2.5), stroke: black + 1pt, fill: color-control, radius: 0.1)
      content((9.75, 2), text(size: 8pt, weight: "bold", "UPF"))

      // DN (Data Network)
      rect((12, 1.5), (13.5, 2.5), stroke: black + 1pt, fill: color-user, radius: 0.1)
      content((12.75, 2), text(size: 8pt, weight: "bold", "DN"))

      // === CONNESSIONI ===

      // Collegamento dati: UE -> (R)AN (data - continua rossa)
      line((4.5, 2), (6, 2), stroke: (paint: color-data, thickness: 1.5pt))

      // N1: UE -> AMF (segnalazione - tratteggiata)
      line((3.75, 2.5), (3.75, 3.2), (7.75, 3.2), (7.75, 4.5), stroke: (
        paint: color-signaling,
        thickness: 1pt,
        dash: "dashed",
      ))
      content((5, 3.5), text(size: 7pt, "N1"), anchor: "center")

      // N2: (R)AN -> AMF (segnalazione - tratteggiata)
      line((6.75, 2.5), (6.75, 3.5), (7.75, 3.5), (7.75, 4.5), stroke: (
        paint: color-signaling,
        thickness: 1pt,
        dash: "dashed",
      ))
      content((7, 3.8), text(size: 7pt, "N2"), anchor: "center")

      // N3: (R)AN -> UPF (data - continua rossa)
      line((7.5, 2), (9, 2), stroke: (paint: color-data, thickness: 1.5pt))
      content((8.25, 2.3), text(size: 7pt, fill: color-data, "N3"), anchor: "center")

      // N4: SMF -> UPF (controllo - tratteggiata)
      line((9.75, 4.5), (9.75, 2.5), stroke: (paint: color-signaling, thickness: 1pt, dash: "dashed"))
      content((10.2, 3.5), text(size: 7pt, "N4"), anchor: "center")

      // N6: UPF -> DN (data - continua rossa)
      line((10.5, 2), (12, 2), stroke: (paint: color-data, thickness: 1.5pt))
      content((11.25, 2.3), text(size: 7pt, fill: color-data, "N6"), anchor: "center")

      // N9: Self-loop su UPF (interconnessione tra UPF)
      line((9.0, 1.0), (10.5, 1.0), stroke: (paint: color-signaling, thickness: 1.5pt, dash: "dashed"))
      line((8.9, 1.0), (8.9, 2.0), stroke: (paint: color-signaling, thickness: 1.5pt, dash: "dashed"))
      line((10.6, 1.0), (10.6, 2.0), stroke: (paint: color-signaling, thickness: 1.5pt, dash: "dashed"))
      content((9.6, 1.2), text(size: 9pt, fill: black, "N9"), anchor: "west")

      // Legenda
      content((14, 3), text(size: 7pt, "Signaling"), anchor: "west")
      line((15.5, 3), (16.5, 3), stroke: (paint: color-signaling, thickness: 1pt, dash: "dashed"))

      content((14, 2.5), text(size: 7pt, "Data"), anchor: "west")
      line((15.5, 2.5), (16.5, 2.5), stroke: (paint: color-data, thickness: 1.5pt))
    })
  ],
  caption: [Architettura 5G: Control Plane e User Plane con interfacce di rete],
)

=== Dataplane

In 5G vengono introdotti dei moduli che prendono il nome di *User Plane Function* (UPF). Essi possono essere configurati in modi diversi, aderendo a compiti specifici.

Un modulo molto importante è L' *UPF ULCL* (Uplink Classifier). Esso decide dove *instradare il traffico in uplink*, distinzione tra traffico cloud e traffico verso un edge. Questa distinzione è fondamentale per sfruttare al meglio i vantaggi del MEC, evitando di mandare tutto il traffico verso il cloud e sfruttando invece le risorse più vicine all'utente finale.

#nota[
  Il traffico in downlink non ha bisogno di un classifier, in quanto sappiamo già da dove arriva (il cloud o l'edge).
]

*Protocol Data Unit (PDU)*: I pacchetti utente viaggiano all’interno di una connessione end-to-end sullo user plane chiamata PDU session. La sessione va da un UE a un data network (DN) e può essere composta da più flussi di traffico (es. video, gaming, ecc.). Il traffico di ogni flusso viene identificato da un *PDU session anchor* (UPF) che si occupa di instradare i pacchetti verso la destinazione corretta (cloud o edge).

#nota[
  Un certo UE può quindi avere *più sessioni PDU attive contemporaneamente*, ognuna con un anchor UPF diverso, a seconda del tipo di traffico e della destinazione (cloud o edge).
]

L'*interfaccia N9*: Permette di connettere tra loro più UPF e fare routing verso altre data network. Tutti gli UPF devono essere connessi all'UPF ULCL, che si occupa di instradare il traffico verso l'UPF corretto (cloud o edge). Se un UPF non è connesso all'ULCL, non può essere utilizzato per instradare il traffico.

=== Control Plane

Nella rete 5G, ognuna delle componenti della parte di controllo è una *VNF* (Virtual Network Function).

Ogni VNF implementa un *micro-servizio* che espone delle API rest. La comunicazione tra i vari moduli avviene tramite un *bus di comunicazione*, secondo un modello *Publish-Subscribe*. Quando avviene un evento viene notificato, il modulo che lo deve gestire risponde.

In realtà la comunicazione avviene in modo misto, in quanto alcuni moduli comunicano attraverso delle interfaccie punto a punto.\
$"N9"$: Interfaccia che permette di realizzare interconnessioni tra UPF.

*NRF (Network Repository Function)*: Questa network function permette di registrare servizi e renderli individuabili dalle altre network function.

*AMF (Access & Mobility Management Function)*: Gestisce la maggior parte del traffico di segnalazione per autenticazioe, registrazione e mobilità. Svolge alcune funzioni del vecchio MME, comunica con il data plane.

#nota[
  I moduli AMF e SMF sono il vecchio MME. Prmettono di gestire la mobilità e la sessione.
]

*SMF (Session management function)*: Gestisce il traffico di controllo relativo alla creazione di sessione dati. Dialoga con AMF per le ricezione e trasmissione dei messagi di controllo. Comunica direttamente con l' USER plane function (UPF).

*PCF (Policy Control Function)*: Vecchio PRF, gestise le policy: chi può fare che cosa.

*AUSF (Authentication Server Function)*: Vecchio HSS, gestisce tutto ciò che riguarda l'autenticazione e la generazione delle chiavi di cifratura.

*NSSF (Network Slice Selection Function)*: Permette di selezionare le network slice, ovvero selezionare la rete logica più adatta per un certo servizio o utente.

*NEF (Network Exposure Function) & AF (Application Function)*: Sono due funzionalità nuove. Permettono ai servizi esterni di _entrare_ nella rete operatore e all'operatore di esporre le funzionalità della rete ai servizi esterni. Possono essere messi in dialogo i due mondi. NEF (cosa la rete mostra) AF (come l'esterno comunica con la rete).

#esempio()[
  Supponiamo di ricevere una chiamata da un truffatore. Mentre siamo al telefono, il truffatore ci convince ad aprire l'app della banca e a disporre un bonifico verso un conto estero.

  - Lato AF: Il server della banca (AF) riceve la richiesta di bonifico. I suoi algoritmi notano qualcosa di strano, ma non sono sicuri al 100% per bloccarlo.

  - L'interrogazione (AF $->$ NEF): Il server della banca (AF) usa un'API per contattare la rete 5G dell'operatore telefonico tramite il NEF. La domanda è: _Il dispositivo con questo IP/numero di telefono è attualmente impegnato in una chiamata vocale_. _E se sì, il numero del chiamante è nella vostra blacklist_?

  - Verifica interna (NEF $->$ Rete 5G): Il NEF riceve la richiesta, verifica che la banca sia autorizzata a chiederlo, e interroga i nodi interni del 5G.

  - Risposta (NEF $->$ AF): Il NEF risponde alla banca: _Sì, l'utente è attualmente in chiamata attiva con un numero segnalato come probabile spam_.

  - Ricevuta questa informazione vitale, l'AF della banca incrocia i dati e blocca istantaneamente il bonifico sull'app.
]

Esistono due _tipi_ di 5G: *5G standalone* e *5G non standalone*.
- *Non standalone*: la parte di rete dopo la (R)AN  compresa di user plane e controllo è uguale all'architettura di LTE.

- *Standalone*: L'architettura è invece quella dell'immagine sopra.

Per ottenere i vantaggi offerti da 5G serve 5G standalone. La separazione permette scalabilità orizzontale sui singoli moduli.
