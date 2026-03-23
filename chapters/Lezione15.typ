#import "../template.typ": *

== 5G network slice

Grazie alla network slicing, è possibile creare più reti virtuali indipendenti sulla stessa infrastruttura fisica. Ogni slice può essere configurata per soddisfare i requisiti specifici di un servizio o di un'applicazione, come ad esempio bassa latenza per i servizi di gaming o alta affidabilità per i servizi di emergenza.

#esempio()[
  Ad esempio, per una rete IOT possiamo piazzare l'UPF dietro la base station, in modo da uscire direttamente su internet, meno latenza.
]

L'idea è quella di andare a configurare la rete in modo dinamico, sia a livello di parametri (caratteristiche del servizio) che a livello di NF (Network Function) che compongono il servizio.

Possiamo quindi andare a personalizzare le componenti in termini di moduli del control plane e data plane.

=== Identificativo della slice

Per l'identificazione della slice, viene utilizzato uno slice identifier a $32$ bit, chiamato *Single Network Slice Selection Assistance Information* (S-NSSAI):
- I primi $8$ bit, rappresentato la *macro tipologia* della slice:
  - eMBB, URLLC, ecc
  - Reserveed per permettere allo standard di crescere
  - Operator specific, l'operatore può personalizzare le macro-classi di slice

- I restanti $24$ servono come *slice differentation*.Identificano l'istanza specifica della slice.

I vari codici vengono forniti all'UE al momento della registrazione. I componenti che dialogano a livello core sono: UE , AMF, NSFF, UDM.\
In questo modo il dispositivo è a conoscenza della slice a cui è assegnato e inserirà l’identificativo della slice all’interno dei pacchetti.

#nota()[
  I bearer utilizzati in 4G rimangono. Le slice sono un' ulteriore livello di astrazione da mettere _sopra_ ai bearer.
]

== 5G e MEC

L'integrazione di 5G con i servizi di edge computing (MEC) è una delle caratteristiche distintive.

L'*integrazione di MEC viene realizzata attravero il modulo UPF* (User Plane Function) che si occupa di instradare il traffico verso la destinazione corretta (cloud o edge). L'UPF può essere configurato dinamicamente per instradare il traffico verso un MEC server.

#esempio()[
  Supponniamo di avere un UE che accede a una slice. La slice collega un UPF a un Data Network (DN) che può essere il cloud o un MEC server.

  L'applicazione richiede accesso a un servizio di edge computing. L'orchestratore capisce che deve istanziare un nuovo servizio, in particolare:
  - Deve soddisfare i requisiti della richiesta, trovando l'edge giusto (vicino all'utente, con le risorse necessarie, ecc)

  - La MEC application configura il servizio richiesto.

  A livello di rete, invece, bisogna configurare il data plane, in modo che l'UE possa raggiungere la MEC application richiesta. A tale scopo, viene aggiunto un UPF class link classifier appositamente configurato (nuovo o già esistente o riconfigurato). Ovviamente il tutto avviene in modo trasparente per l'utente, che non si accorge di nulla.

  il traffico dell'UE viene instradato verso l'UPF class link classifier, che lo instrada verso la MEC application. Se invece l'applicazione è sul cloud, il traffico viene instradato verso il cloud.

]

#attenzione()[
  Senza la network function virtualization (NFV), questa flessibilità *non* sarebbe stata possibile.
]

=== Edge Resource Placement

Vogliamo capire dove posizionare i MEC server all'interno della rete. Ci sono diverse opzioni, ognuna con i suoi vantaggi e svantaggi:

+ Mettere il MEC server in un data center vicino all'utente, ad esempio in una base station. In questo modo si riducono le latenze, ma è più costoso e complesso da gestire

+ Invece di mettere un server sotto ogni antenna, se ne mette uno più grande in un nodo che raccoglie il traffico di $20-50$ antenne (ad esempio, a livello di quartiere o di città). In questo modo si riducono i costi e si semplifica la gestione, ma le latenze sono maggiori

+ Posizionare il MEC server nella backhaul (es. a livello regionale o nazionale), ad esempio in un nodo di aggregazione. In questo modo si riducono i costi e si semplifica la gestione, ma le latenze sono maggiori

+ Metterlo nella rete core. In questo caso si può usare una slice dedicata per il traffico verso il MEC server, in modo da garantire le prestazioni necessarie. Latenze simili a quelle del cloud

#nota()[
  Le scelte non sono mutualmente esclusive, ma possono essere combinate in base alle esigenze specifiche del servizio e alla topologia della rete. Ad esempio, si potrebbe avere un MEC server vicino all'utente per i servizi che richiedono bassa latenza, e un altro più centralizzato per i servizi che possono tollerare latenze maggiori.
]

== 5g RAN - 5G NR

In 4G avevamo un frame di simboli OFDMA che durava $10 "ms"$, con $10$ subframe da $1 "ms"$ ciascuno.

L'idea in 5G è quella di *ridurre la latenza* (portarla sotto 1ms), *senza ridurre il numero di simboli trasmessi* (sempre 14 simboli OFDMA).

La soluzione è quella di *ridurre la durata del simbolo*, aumentando di conseguenza la velocità di trasmissione.

#nota()[
  La diminuzione della durata del simbolo comporta un *aumento della distanza tra le sotto-portanti*, altrimenti si violerebbe l'ortogonalità tra di esse.
]

Lo standard 5G NR definisce $5$ diverse durate, indicate come *numerology*. Definisce anche due possibili intervalli di frequenze:
- FR1: $410-7125 "Mhz"$
- FR2: $24250-52600 "Mhz"$

Per una numerology $mu$, si ha una distanza tra le sotto-portanti $delta f$ pari a: 
$
  delta f = 2^mu dot 15 "Khz"
$
Con $mu = 0$ le sotto-portani sono distanziate come in 4G, mentre con $mu = 4$ un singolo resource block occupa molta più banda per mantenere lo stesso numero di sotto-portanti. 






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

#part("Comunicazione satellitare")

= Piano orbitale

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

= Comunicazione satellitare //saltare topologia

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
