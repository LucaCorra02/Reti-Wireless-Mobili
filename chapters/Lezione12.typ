#import "../template.typ": *

= Lezione 12

== E-UTRAN collegamento core network

Le varie base station possono non usare la rete core per comunicare, ma possono comunicare in modo peer to peer.

Si tratta di *comunicazione logiche* dipende dal deployment della rete. Nell'immagine può essere realizzata tramite punti radio (canale diretto fisico) oppure usa la tranform network ip. Che è la stessa che porta da rete random a ip.

== Tracking area

Ogni base station deve sapere i pull che gestiscono la base station.

== Interfaccia X2

L'interfaccia idue permette la comunicazione diretta tra E-Nodeb, si tratta di un modolo che aggiunge computazionalità aggiuntiva.

Le funzionalità aggiunte sono:
+ Gestione degli handover (convolgere moduli rete core o meno). Tutto il traffico di controllo di un utente da una BS all'altro se la smazzano le due BS direttamente senza rete core.
+ Self-Organized-Network
  - Load balancing
  - Gestione delle interferenze. Se il dipsositivo sul bordo sente male chiede alla base station di finaco di cambiare le frequenze che usa sulo bordo

+ Evitare effetto ping-pong. Viene tenuto uno storico dei dispositivi già visti. Se accetto di nuovo un dispositivo giù visto in precedenza nona avvio la fase di handover.

== Control Plane

SCTP = Gestita la parte di decisione (controllo) viene gestita a livello L3. Vengono inviate le misurazioni user-requiment.
Gestisce la parte di risorse dati

PDCP = permette la convergenza del modno delle varie applicazioni, mappandole su canali fisici sottostanti. Conversione degli header IP (?)

RLC = gestisce il link (non le risorse radio):
- Corregre gli errori
- Gestione di segmentazione e riassembalggio gei pacchetti
- Gestisce la ritrasmissione

L'idea è che quello che arriva da sopra viene impaccettato in un unità di trasmissione e lo invia a livello MAC. La base station trasmette un insieme di blocchi che possono mischaire traffico dati e controllo

MAC (mediium access control): gestisce l'accesso a canale fisico

Il mezzo è condiviso tra più utenti in modo ortogonale e deve gestire canali eterogenei. Per questo motivo c'è una collaborazione tra stack di protocolli. La parte a destra è quella radio.

=== E-Nodeb
Si tratta di una dual stack, deve paralare sia clabata che via radio


Sel $"S1"-"AP"$
Ip sono interni alla rete dell'operature (ip MME e ip eNodeB). Non c'è visibilità all'esterno.


=== SCTP Motivazioni

Perchè non c'è TCP ma SCTP. Alcune parti vanno bene:
- TCP è traffico di controllo. Sappiamo cosa viene trasmesso e deve essere meno impattante possibile e affidabile.

TCP è stram oriented le applicazioni aggiungono marker specifici per delimitare i messaggi, si tradda di overhead superfluo che possiamo evitare per trasmettere più dati

Inoltre TCP non supporta multi-homing. Avremo una connessione univoca tra eNodeB e MME. La connessione se una delle parti viene a mancare si rompe. Siccome un area è sertivta da MME vogliamo avere una connessione TCP con più MME per full-tollerance


#nota()[
  Non si può usare UDP in quanto non è affidabile
]

==== TCP - HOL BLock Problem

#esempio()[
  I segmenti $2 e 3$ arrivano a destinazine mentre $1$ no. I segmenti $2$ e $3$ non possono essere scaricati dal buffer di tcp, un quanto non è arrivato ancora il segmento $1$.

  Tutto quello che c'è prima di me deve essere arrivato.
]

Supponiamo di avere 3 dispositivi, con i relativi messaggi di controllo con uno stream tcp. Se viene perso uno dei pacchetti di controllo anche gli altri messagi degli altri dispositivi all'interno dello stream tcp sono bloccati. anche se i dispositivi sono indipendenti.

Una prima idea potrebbe essere di fare 3 connessioni TCP diverse. Tuttavia la base station dovrebbe gestire molte connessioni TCP (pari al numero di dispositivi collegati) inoltre anche l'MME soffre. In quanto è condiviso tra più base station, non risce a scalare.

La soluzione è usare SCTP

L'idea è avere un ordine parzile (2 stream), guardando tutti gli stream. All'interno di ciascuno stream è totale (FIFO), l'ordine con cui vengono trasmessi i byte dei messaggi deve essere mantenuto.

Il protocollo quick mette dei marcatori di stream.

==== SCTP Multihoming

Fatto pagando un po di overhead nell'header. Una connessione non è più identificata dalla prima quadrupla ma abbiamo un insieme di indirizzi IP destinazine e indirizzi IP sorgenti. GLi IP destinazioni sono i vari MME che mi servono.

Se in TCP avenamo uno stram (blocchi verdi) può contenere diversi segmenti che contencono messaggi diversi, è computi dell'applicazioni inserire dei marcatori. I tempi possono essere molto elevati.\
Supponiamo che questi messaggi siano di handover. Siccome le operazioni costose e abbiamo tanti dispositivi (lato BS) e tanti messaggi (lato MME) abbiamo molto overhead.

Tutti i segmenti del messaggio sono solamente di quel messagio. Non contengono altri messaggi. Abbassiamo le risorse computazionali richieste lato trasmissione e ricezione.

//aggiugnere tabella riassuntiva
SCTP è message oriented come UDP e connectin roiented come TCP. La consegna può avvenire anche non in ordine a differenza di TCP:
- è multi-streaming
- è multi-homming

== User Plane

Ci sono $3$ livelli ip diversi.
- Primo livello: indirizzi interni assegnati con NAT e DHCP. Se tratta dell IP interno del P-GW con UE (non c'èentrano con quelli di servizio della rete).

- Secondo livello: l'ip grande rappresentano i due IP pubblici.

- Il terzo livello di IP sono gli indirizzi IP interni alla rete operatore utilizzati per fare routing tra gi elementi della rete.

== GTP

Lo user equipement ha una sessione con un PGW.
NB e SGW possono cambaire durante la durata delle sessione. Man mano che l'UE si sposta ho sempre più router che possono essere cambiati da questo cambiamento.


=== Uplink

GPT iniza sulla parte che è rivolta verso la rete core dell'UE (sull UE non c'è routing). Il pacchetto che arriva (UE -> eNB) è dato da:
- RLC
- IP
- UDP/TCP
- DATA

A questo punto so l'identità dello UE e so quale S-GW sto gestendo. In realtà posso avere pià S-GW ma al momento è gestito da uno solo.

- RLC può essere totlo. Viene tenuto IP e la parte applicazione.
- Il pacchetto viene incapsulato in un tunnerl GGP. Contiene:
  - IP SGW. IP del serving gateway, serve ad arrivare un certo nodo della rete.
  - UDP, porta UDP dell'SGW
  - Tunnel-ID. Mappautura tra eNode <-> SGW.

Possiamo avere in questo modo le tabelle di routing interne, in quanto basta sapere ... (?) riguardare.

Il pacchetto dell'untente viene tenuto incapsulato vino a quando non raggiungiamo il livello P-GW:
- Estre il pacchetto IP dentro il tunnel GPT
- Viene mandato al server

Una volta impostare le tabelle della rete operatore non cambio alcuna delle tabelle di routing, se il dipsositivo cambaisse BS basta che cambio il tunnel id. Se non ci fosse PT dovrei cambaire tali tabelle.


== LTE-EPS bearers

Permette di offrire qualità di servizio all'utente. Dal punto di vista dell'architettura abbiamo un
- PGW Parte interna della rete operatore. A livello di GPT
- External Bearer fino al servizio

A sua volta all'interno della rete operatore è spezzato in diversi pezzi avendo 4 elementi:
- Rafio bearre: Qualità di servizio a livello radio (3G)
- bearrear tra S_GW e BS
- bearer tra S-GW e P-GW

Tutti i moduli devono garantire la qualità di servizo. Se nella prima parte sono lento devo essere veloce nelle altre parti. Dipende da come è configurata la rete.

Ci possono essere attivi al massimo 8 bearer. Tale modalità di gestire la qualità di servizio viene amplificata in 5G tramite l'introduzione dei netkwork slice.

tipi di bearrear:
- bearrear creato con i P-GW, prende il nome di default bearrear. Ad ogni default bearrear può essere assegnato un IP (differente). Si tratta di un canale dati

- Dalla parte di controllo viene negoziato un dedicat barrer. Si tratta dei fork sul default barrare con il PDN, in base alla qualità di servizo richiesta. Si usa lo stesso IP del default barrer ma la qualità di servizio è differente. Possiamoa avere la stessa PDN session ma qualità di servizo differenti

- è possibile collegarsi con un altro P-GW e creare un altro default barrer. Questo viene creato dopo la connessione iniziale. Anche qui abbiamo un altro indirizzo IP.

Possiamo avere diversi P-GW session apaerte con più default barrer e con altre fork per avere altre qualità di servizo. Il limite è $8$ (sommando sia defualt che dedicated) canali lato UE.

== Qos e EPS

La priorità viene scelta dalla User equipement.

//recuperare parte di collegamento alla rete operatore.

- La base station non può dire no, deve chiedere alla rete core
- procedura di attach, viene contatta la rete core

Se tutto va a buon fine, allora diventiamo mobiity register e connected register. EPC deve:
- Fare pagind
- Quando triggerare la procedura di handover

Nel caso UE rimanga inattivo allora 