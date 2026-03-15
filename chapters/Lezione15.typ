#import "../template.typ": *

== 5g network slide

Con le slice possiamo configurare la toplogia di networl function come vogliamo, possiamo mettere o meno delle funzionalità.

Ad esempio se per la parte IOT possiamo avere l'upf dietro la base station in modo da uscire direttamente su internet, meno latenza.

La NSFF permette di selezionare e configurare le varie slice, avremo una sorta di template per ogni slice.

Possiamo quindi andare a personalizzare le componenti in termini di moduli del control plane e data plane.

Slice template viene mappato su 32 bit:
- Primi 8 bit, rappresentato la macro tipologia della slice:
  - eMBB, URLLC, ecc
  - Reserveed per permettere allo standard di crescere
  - Operator specific, l'operatore può personalizzare le macro-classi di slice

- Slice differentation, identifica l'istanza specifica della slice.

I vari codici vengono forniti all'ue al momento della registrazioni. I componenti che dialogano a livello core sono: UE , AMF, NSFF, UDM.

I bearer con gli ip rimangono. Le slice sono un ulteriore livello di astrazione da mettere _sopra_ ai bearer.

Le slice tra di loro sono indipendenti, possono condividere componenti a discrezione dell'orchestratore, ma non è obbligatorio.

== 5G e MEC

L'integrazione di 5G con i servizi di edge computing (MEC) è una delle caratteristiche distintive.

A livello di architettura è importante il data plane che può essere VNF/PNF. Nell'architettura 5G corrisponde a UPF.

Suppnoamo di avere un UE che accede a una slice che collega con un UPF PSA (ancora che gestisce la sessione) che poi si collega con un data neetwork.

L'applicazione richiede accesso a un servizio di edge computing. L'orchestrare capisce che deve istanziare un nuovo servizio, in particolare:
- Deve soddisfare i reqquisiti della richiesta, trovando l'edge giusto (vicino all'utente, con le risorse necessarie, ecc)

- La MEC applicazion configura il servizio richiesto.

Lato rete bisogna configurare il data plane, in modo che l'UE possa raggiungere la MEC configuration  configurata:
- Viene aggiungo un UPF class link classifier appositamente configurato. Può essere nuovo o già esistente o riconfigurato. Ovviamente il tutto avviene in modo trasparente per l'utente, che non si accorge di nulla.

- Uno andrà al vecchio UPF e l'altro andrà verso la MEC application.

#attenzione()[
  Senza la network function virtualization, questa flessibilità non sarebbe stata possibile.
]

=== Edge Resource provisioning

Opazione 1 mettere il MEC server in un data center vicino all'utente, ad esempio in una base station. In questo modo si riducono le latenze, ma è più costoso e complesso da gestire.

L'altra opzione è ad anello con un data center più grande, con più risorse, ma con latenze maggiori. In questo caso si può usare una slice dedicata per il traffico verso il MEC server, in modo da garantire le prestazioni necessarie.

L'opzione 3 è metterlo nella backhaul e non nella rete core.

L'opzione 4 è metterlo nella rete core, in questo caso si può usare una slice dedicata per il traffico verso il MEC server, in modo da garantire le prestazioni necessarie. Tipicamente si tratta di una soluzione da CDN. Tante risorse ma pago in latenza. Soluzione quasi come il cloud

Possono essere presenti tutte le scelte, non c'è uan limitazione nella rete operatore. L'operatore può noleggiare risorse dagli edge provider. L'edge porvider possono essere eterogeni a livello di servizi e geolocalizzazione.

Non c'è un singolo operatore. L'operatore di rete può essere sia fruitore che offrire servizi rete di edge.

== 5g RAN - 5g NR

In 4G avevamo un frame che durava 10 ms, con 10 subframe da 1 ms ciascuno In 4g impiegava come unità base 1ms per la trasmissione, per questo motivo non è possibile stare sotto la latenza d 1ms già in partenza.

L'idea in 5g è che non vogliamo trasmettere meno (sempre 14 simboli OFDMA) ma vogliamo trasmettere più velocemente.

La durata del simbolo è durata alla sub carrier spacing, più dura il simbolo più dobbiamo separare i subcarrier.

In 5G la soluzione è ridurre la durata del simbolo. Stesso numero di simboli trasmetti ma in mento tempo. Dobbiamo andare ad aumentare la distanza tra le sotto-portanti, altrimenti violeremmo l'ortogonalità.

Abbiamo due intervalli di frequenze:
- FR1: $410-7125 "Mhz"$
- FR2: $24250-52600 "Mhz"$

Avere bande larghe è più difficle nel primo caso. A standard queste due bande vengono utilizzate nel seguente modo:
- Viene introdotto un $mu$
- $Delta f = 2^u dot 15 "Khz"$
- Con $mu = 0$ le sotto-portani sono distanziate come in 4G.

Con $mu = 4$ un singolo resource block occupa molta più banda per mantenere lo stesso numero di sotto-portanti. Ovviamente viene ridotta anche la durata del simbolo. Ma riusciamo a garnitre la latenza di 1ms.

//aggiugnre immagine

La durata di uno slot (14) simboli su una sotto portante può essere vista nel seguente modo: Se riduciamo la durata del simbolo dobbiamo aumentare lo spazio fra le sotto-portanti.

Lo scheduling può avere diverse combinazioni in base alla banda disponibile e al $mu$ scelto.

== Standalone vs non-standalone

Lo standalone 5G consiste nella base station (gnB) + 5Gc oppure eNB + 5Gc. In questo caso abbiamo una rete core 5Gc con una base station 4G.

#nota()[
  Sfruttare tutte le potenzialità è possibile solo con lo standalone tra 5G.
]

Ad oggi vengono istallate secondo la seguente configurazione:
- eNb Master = gestisce managment e controllo
- gNb Slave= gestisce la parse dati
- EPC = rete core 4G

Lo standard, tuttavia, prevede diverse configurazioni. Possiamo gestire in modo ibrido la rete 4G e 5G.

== Open-RAN (O-RAN) // non in esame

La prima immagine è la rete legacy

La C-RAN abbiamo un front all che porta tutto sulal rete core e poi sull abase band unit

Infine abbiamo open rand dove abbiamo un'architettura più spezzata. Ciasunco degli elementi è virtual network function.

Open RAN ha un architettura che prevede dei controlli programmabili aggiuntivi:
- RIC (RAN Intelligent Controller): è un componente che consente di programmare e ottimizzare le operazioni della rete RAN in tempo reale. Può essere utilizzato per migliorare le prestazioni, la gestione delle risorse e l'efficienza energetica della rete. Possiamo trovare dei componenti di inteligente artificiale che analizzano i dati in tempo reale e prendono decisioni per ottimizzare la rete. L'inferenza deve durare massimo $10"ms"$

#nota()[
  Permette di aggiungere inferenza sulla parte RAN
]

Il modulo Non-real time l'inferenza può durare anche qualche secondo. Ciasucna delle parti del nodeB è stata virtualizzata.

= Comunicazioni Satellitare

== Piano orbitale

Sui piani orbitali girano i satelliti. Le cotellazioni sono un insieme di satelliti che orbitano intorno alla terra per coprire una certa orbita.

Abbiamo 3 punti di riferimento:
- Angolo di Azimuth: angolo verso nord.
- Angolo di elevazione: angolo verso l'alto. Angolo rispetto all'orizzonte. L'angolo zero è rispetto al piano parallelo alla terra, mentre 90 è direttamente sopra la testa. Quanto dobbiamo alzare l'antenna rispetto all'orizzonte

- Angolo di copertura: quanto copriamo rispetto alla terra. Angolo conico rispetto alal superficie. Quanto più siamo distanti maggiore porzione copriamo.

La lunghezza fisica del link può varriare, soprattuto per orbite non geostazionarie (ruotano con diversa velocità rispetto alla terra).

La minima distanza è quando il satellite è direttamente sopra la testa ($h$)

$d_max$ è quando il satellite è all'orizzonte, in questo caso la distanza è $d_max = sqrt((R+h)^2 - R^2)$. La latenza diventa non più trascurabile dopo il punto d_max, dobbiamo fare handover tra satelliti.

Per calcolare quanto ci mettiamo a trasmettere dei dati dobbiamo calcolare la latenza di propagazione, che è data da $t = d/c$ dove $d$ è la distanza e $c$ è la velocità della luce.

Quando il satellite è sopra di noi attraversiamo meno atmosfera, quindi molta meno aria. Attraversando più atmosfera, l'assorbimento cresce (soprattuto in presenza di nuovole e pioggia).

//aggiungere grafico su 3 assi

SU asse y abbiamo il periodo di delay (RT)
asse x l'altezza dell'orbita

Più noi abbiamo un orbita basse più abbiamo un delay molto piccolo ma la copertura è bassa e il periodo è piccolo.

Più ci spostiamo sull'orbita geostazionaria (ruota alla stessa velocità della terra) più abbiamo un delay molto alto, ma la copertura è molto alta e il periodo è infinito (non dobbiamo fare handover).

//Recuperare slide

== Comunicazione satellitare //saltare topologia

La copertura da dei vantaggi e svantaggi. A secnda delle tipologia di servizio scgliamo robita e costellazione

== Satellite + Terrestrial

Base station su satellite. L'idea è offrire connettività in aree remote dove non è possibile stendere cavi o installare infrastrutture terrestri. In questo caso il satellite funge da base station, riceve i segnali dagli utenti e li trasmette a terra.

NTN = tutto quello che non è terrestre, quindi anche aereo, drone, ecc

A ivello di standard dobbiamo capire come integrare i satelliti nella rete 5G.

- Fare releay a livello fisico. il GNB sta in basso.

- gNB è il stalellite (base station).Prende il nome di regenerative payload

- gnB central unit è a terra mentre quello distributed è sul satellite. In questo caso abbiamo un satellite che fa da base station, ma la parte di controllo è a terra. Prende il nome di transparent payload.

Oguno dei moduli che volano possono essere dei mac host, possiamo istallare dei moduli di edge computing direttamente sui satelliti, in questo modo possiamo offrire servizi di edge computing anche in aree remote.

= Tema d'esame

Es 4)
In questo caso L'originator che è il nodo $A$ con SEQ = 200 chiede la destinazione per C. X non la conosce e invia una RTT in broadcast. L'unica cosa che fa $X$ è aggiornare la entry per A.

Esercizio questo o tracciare l'esecuzione

es 2) 

es 3) CSMA/CA