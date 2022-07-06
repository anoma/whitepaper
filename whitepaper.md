---
title: 'Anoma: An intent-centric, privacy-preserving, Byzantine-fault-tolerant distributed database architecture'
author: Heliax AG
fontsize: 9pt
date: \textit{Prerelease, \today}
abstract: |
	Anoma is a suite of protocols and mechanisms for self-contained and self-sovereign coordination in the presence of Byzantine actors. Traditional distributed settlement platforms are imperative, designed around transactions: state transitions which are ordered and executed. By contrast, Anoma is declarative, designed around intents and validity predicates: ephemeral and enduring preference functions over possible states which describe which states of the system an actor would prefer. Anoma’s fractal instance architecture partitions a single logical state across separate operational security zones, allowing users to interact with each other where they share trust assumptions and isolate themselves from faults elsewhere in the network graph. Vertical integration of the two phases of counterparty discovery and settlement allows the protocol to provide end-to-end privacy, safety, and liveness guarantees.
urlcolor: cyan
header-includes:
    - \usepackage{fancyhdr}
    - \usepackage{graphicx}
    - \pagestyle{fancy}
    - \fancyhead[RE,LO]{}
    - \fancyhead[LE,Ro]{}
    - \fancyhead[CO,CE]{}
    - \fancyfoot[CO,CE]{}
    - \fancyfoot[LE,RO]{\thepage}
---

# Background and motivations

## On information systems design

Realization of discrete information systems which can be safely used as tools requires synthesis of bottom-up possibility-directed construction and top-down purpose-directed design. Bottom-up possibility-directed search of the possibility space determines which discrete systems can be constructed with certain properties, while top-down purpose-directed design provides constraints which a system must satisfy in order to provide safe, comprehensible, and accurate black-box abstractions to users which they can use to employ the system as a tool to do what they want. Failure to correctly search, constrain, and specify the discrete system will result in incoherent or inconsistent systems, while failure to correctly understand the models of the system which users will see and interact on the basis of will result in systems which are not useful, or worse, systems which make a false claim of black-box behaviour which they do not in fact adhere to, leading to inadvertent consequences when the systems are used without an accurate understanding of the ramifications of use. 

These twin perspectives must be considered holistically, from the discrete system on one end and from the user's interfaces and understanding on the other. An elegant and safe protocol basis is insufficient if weak application-layer constructions ruin the intended properties of the protocol architecture by routing around them at the application layer, purposefully obfuscating choices intended to be granted to the user, or misleading users with interfaces conveying relations of data, control, and influence to which the underlying system does not adhere. This might lead one to favour minimalist vertically integrated architectures which do very little on purpose. At the same time, if the architecture is too specific, and different use-cases which require only differences at the application layer but could utilise the same lower-level primitives instead use incompatible vertically-integrated protocol stacks, systems will be unnecessarily incompatible, and effort verifying multiple syntactically-varying but structurally-isomorphic lower-level protocol components will be wasted. Taking in mind both the constructive possibilities and the purpose-directed design, there is a specific tree of abstractions proper to the generalisation of a set of use-cases, and it is the task of systems designers to articulate and specify it.

## Situating Anoma

Anoma is an attempt to synthesize between the constructive search of possible Byzantine-fault-tolerant privacy-preserving distributed database architectures and an understanding of how users will use these systems for various kinds of coordination that aims for a suitable level of generality and configuration of abstractions in order to provide end-to-end security, correctness, and privacy guarantees for the real practices of use. A modicum of consideration for the context of use entails the two key design principles of Anoma: intent-centric design and homogeneous architecture / heterogeneous security. These principles are not necessitated by the constructive possibilities of systems but are rather chosen to align the properties which the user-facing black box abstractions of Anoma can provide with the properties required for safe usage in the expected topology of real-world deployment. Both rest on what is in turn the essential distinction between constructive search and purpose-directed design: the subjectivity of semantics. 

Data, whether stored in replicated distributed database entires, Excel spreadsheet cells, or writing on a piece of paper, has meaning which cannot be derived from its form. While the form may have a certain structure, if the data refers to entities in the world outside the database, these relations of referring cannot be found in the data itself, for any particular relations are possible. Yet, if the database is a tool to be used in order to aid in manipulation of entities in the world outside the database, it is not merely the particular form of or syntax of the data but also the knowledge of these relations that one must possess in order to use the database as such an aid. 

### Intent-centricity

The first design principle of Anoma is _intent-centricity_, and it follows from considering the following question: why would anyone use a distributed database at all? To users who take the database as a tool, the semantics of data stored therein constitute their correspondence to entities outside the database, and the utility of the database as a tool is merely any ways in which it can aid in the manipulation of these entities. The key distinction between a _distributed_ database and a non-distributed one is fault tolerance: the database can continue to operate and preserve its syntactical rules in the presence of certain limited faults. This is only useful in a context of use where there are multiple users who want to coordinate (a single user could have used a private local database), and where these users want to preserve their ability to coordinate in the presence of Byzantine actors. Grounds for coordination are preferences over states of the world (otherwise there would be no reason to coordinate) and the inability of any actor acting alone to enact them (otherwise action could be taken directly). Anoma starts from this basis, conceptualising these preferences over states of the world in discrete form as _intents_, and crafting an architecture to facilitate counterparty discovery (finding other actors with whom one could coordinate) and settlement (enacting state changes preferred and reachable by a set of actors acting jointly). 

An *intent* is an expression of what a user wants to achieve whenever they interact with a protocol, for instance "transfer X from A to B" or "trade X for Y". So far all distributed ledger protocols (cryptocurrencies, smart contract platforms or application-specific Layer 1s) were designed with *transactions* as their most fundamental unit. Independent to what the actual user intent entailed, clients (e.g. wallets or other interfaces) are required to transform the intent into a transaction so the protocols are able to process it. In reality, most user intents are more complex than what can be represented in a transaction, for example "transfer X from A to B *privately*", "transfer X from A to B *where B receives Y*" or "trade X for Y *at the best market rate possible*".

(comment: describe a bit more what intents are, counterparty discovery and settlement)

Overtime, many protocols and clients have emerged so that more complex user intents can be interpreted and encoded into transactions to be settled on-chain. In the domain of fungible token trading, examples include the work from Flashbots or the Coincidence of Wants (CoW) Protocol, which via custom components at the peer-to-peer layer (mev-relay, CoWs, Batch Auctions), client (mev-geth), RPC layer (Flashbots protect) - integrated to grant the properties of "best on-chain price" and a "notion of fairness" via MEV mitigation mechanisms. In the domain of non-fungible token commerce, examples include the Wyvern DEX Protocol and more recently the Seaport Protocol, which supports orders that include more traits, often needed when a user intent involves NFTs. While we expect more protocols and components like the above to proliferate and diverisfy with specialisation in interpreting application-specific intents within the architectural boundaries of smart contract plaforms, there hasn't been any vertically-integrated protocol yet able to interpret and process intents natively and generically.

(comment: add 0x, more people will know it than Seaport)

(comment: cut first part of last sentence, note that all of these protocols do counterparty discovery and use the blockchain for settlement)

In Anoma's architecture, intents are the most fundamental unit and it is designed to handle intents generically. An intent encodes the user's preferred state transition, where the preferences can be as simple as a plain transfer or as complex and expressive as one that requires arbitrary computation. This intent-centric philosophy results in a declarative architecture that is designed to settle intents wherever possible – as they were defined by the user *and nothing else*, thereby minimising informational externalities, which extend beyond the loss of anonymity or the ability for certain parties to benefit disproportionally from users' actions without adding comparable value in the process. By adopting a declarative paradigm, Anoma can grant users more control and realise their intents with not only stronger privacy, security, and performance guarantees, but also more expressivity and flexibility in articulating their intents to an extent that they can define arbitrarily both the what and the how the intents are processed.

(comment: contrast transactions (imperative) with intents (declarative))

Compared to architectures centered around smart contracts that could encode arbitrary state transition functions, Anoma's declarative programming paradigm provides application developers a better scoped problem space, as they will only need to reason through the compatibility between user intents and validity predicates, and set the precedence for building safer by construction applications – or applications that do not work as the developer ended up writing logic that violated corresponding validity predicates. Anoma's architecture opens up a new way of designing decentralized applications that benefit from the expressivity and composability of intents, the expressivity and guarantees of validity predicates, as well as a more efficient settlement mechanism derived from the design of the state mechaine and ledger that makes the separation between computation and verification more explicit, where computation can be handled off-chain (and can be thereby parallelised), while only verification is handled on-chain (validity predicates are checked before state transitions are accepted). Users benefit from a better user experience when interacting with applications built following this declarative programming paradigm, as they interact directly with their own intents and define their own validity predicates - making it easier to understand and reason through what they are doing without requiring them to understand the underlying stack.

(comment: describe application interface a bit more, contrast directly instead of using adjectives like "better")

As the volume and diversity of user intents continues to grow, Anoma's architecture is designed to process any intents generically, including the yet-to-be disovered ones. Combined with its ability to handle already-known intents with stronger security performance guarantees, and better developer and end-user experience, we believe that Anoma can open up a world for not only upgrading existing decentralized applications with stronger guarantees and different trade-offs, but also enable new kinds of decentralized applications and novel economics that existing architectures cannot.

(comment: cut this)

### Homogeneous architecture / heterogeneous security

The second design principle is homogeneous architecture / heterogeneous security. Architecture -- the abstractions and relations constituting the structure of a system -- is syntactical, possessed of properties and syntaxes but no particular semantics in relation to the exterior world. Convergence on a singular architecture saves time and verification costs without constraining users to particular choices. Security -- the choice of who and how to trust in the operation of a distributed system -- is a decision inseparable from the particular semantics of a particular context of use. Security can be economically abstracted to a certain degree, by limiting the information available to and consqeuent choicemaking capabilities of system operators, but operators will always have choices of how and from whom to accept messages, when to elect to include them in blocks or other aggregations over which they vote, and when to cease voting or otherwise alter normal operational procedures in response to exceptional circumstances. Who to trust with these responsibilities depends on what the state in the database _represents_ in the real world, and alignment with the interests of users of the database requires mutual interests beyond the purely economic ones. The TCP/IP protocol stack follows this principle, in that the various layers of the internet protocol are standardised, but the choice of who to connect to and what data to entrust them with is left to the user, and different users can make different choices. In practice, however, the internet often fails to provide this interoperability and user-directed security in practice due to control of data and proprietary platforms at the application layer (e.g. Android and iOS app stores).

Consider blockchain platforms, from the perspective of applications running on top of them, along two dimensions: protocol architecture and security model, and whether they are _homogeneous_ or _heterogeneous_ for different applications running on the platform. Protocol architecture refers to the state layout, virtual machine, language support, sharding mechanisms, cross-contract messaging model, etc. - architecture determines what is required to write an application for a platform. Platforms with a _homogeneous_ architecture require that all applications are written in a certain format (e.g. EVM bytecode or WASM), while platforms with a _heterogeneous_ architecture allow applications to be written in different formats, perhaps with some agreement at the edges (cross-chain communication protocols). Security model refers both to security **in theory** - fault tolerance properties of the consensus, fork detection & handling, etc. - and security **in practice** - which miners or validators actually operate deployed instances of these architectures. Platforms with a _homogeneous_ security model have the same security for all applications (more or less), while platforms with a _heterogeneous_ security model have different security characteristics (perhaps both in theory and in practice) for different applications. This is, of course, a broad characterisation and obscures finer detail, but these design dimensions do exist. Let's situate several platforms on these two axes: Ethereum - homogeneous / homogeneous, Polkadot - heterogeneous / homogeneous, Near - homogeneous / homogeneous, Cosmos - heterogeneous / heterogeneous, multichain - heterogeneous / heterogeneous.

As this diagram suggests, these dimensions, so far, are generally quite correlated: homogeneous architectures come with homogeneous security models, and heterogeneous architectures come with heterogeneous security models. It's easier to design a system where they are correlated - if everything is homogeneous, protocols can be fit together neatly, cross-contract communication is easy, etc.; if everything is heterogeneous, protocols just agree on the edges of interaction (IBC) and handling the complexity of security is up to the users.

Anoma's fractal instance architecture is an attempt to decouple these dimensions and build a platform which is architecturally _homogeneous_ (though see below) but with a _heterogeneous_ security model. This is more complicated, but it separates out the question of what is the best _protocol architecture_, where there may be a "benevolent monopoly" (a la Git or TCP/IP), from the question of what is the best _security model_, where there is almost certainly not. Applications written for fractal instances can standardise on the architecture Anoma offers, which is sufficiently well-defined to allow for complex interoperability, automatic scaling, etc., without agreeing on any single security model (and, in some cases, this flexibility of choice can be extended all the way to users of the applications, who can choose independently). Interfaces for Anoma instances can support the same applications deployed with different security models, and communicate that latter difference to users in a way which allows them to choose their trust assumptions while retaining the network effects of using the same protocol.

It's worth noting that Anoma's architecture isn't "homogeneous" like a straitjacket - all of the protocols are layered so that fractal instances can pick and choose which parts they participate in - we should do this, but we should also come up with a unified architecture that handles most concerns reasonably well and allows developers and users of Anoma to realise the benefits of standardisation.

Beyond these two design principles of intent-centricity and homogeneous architecture / heterogeneous security, Anoma tries to make no decisions -- all other choices are a matter of modularisation and runtime configuration parameters.

# Architectural design rationale

Anoma's architecture, from the basis of intent-centricity and heterogeneous security, aims to make as few assumptions as possible, and no decisions. 

For the purpose of elucidation, consider a logically centralised database with a trusted operator possessed of infinite compute. Actors submit intents to this database, which accepts them one at a time in a total order. When an intent is submitted, if any combination of intents can be mutually satisfied by any state change, the operator enacts the state change (if multiple state changes satisfy, the operator arbitrarily chooses one), which subsequent queries to the database immediately reflect. If not, the operator stores the intent. If it were possible, this architecture would be ideal: state is unified, intents are always settled immediately, and settlement fairness operates on a simple first-in-first-out principle. Anoma aimes to asymptotically approximate this architecture given the constraints of heterogeneous trust, spatiotemporal locality, and limited computational speed. Let us consider each of these in turn.

Heterogeneous trust: motivated by semantics, particular states of the database may be preferred by certain parties in the real world, clients of the system must place trust in a designated set of actors to maintain the database (who could perhaps be the clients themselves, but still must be designated). Clients will want to minimise the trust required, and different clients with different semantics may have different trust preferences, and the system design needs to allow clients to interact where their trust models are compatible, and prevent interactions from outside their trust models from impacting local guarantees provided to those clients. Ways of minimising the trust required: BFT consensus, cryptography, proofs-of-correct-execution, etc.

Spatiotemporal locality: No absolute clock, per Einstein, clocks are relative. Sharded security and concurrency domains must settle for a partial ordering, and the ordering required should be minimised to as local a domain as possible. In cases where fairness is desired, the system should craft a basis for a logical clock to render moot latency differences in a given physical / informational domain. Locality of safety and liveness should be preserved.

Limited computational speed: NP != P, searching for satisfying computations must be specialised to the particular form and is to be exposed in the programming interface. Quality-of-service guarantees require bounded compute.

Limited computational speed motivates the separation of the role of solver from the role of settlement. Spatiotemporal locality and heterogeneous trust motivate separation of security and concurrency domains.

# Architectural topology

(diagram of all architectural components)

## Nodes and network layer

Anoma's architectural topology is logical, in the sense that it consists of a set of logical abstractions delineated by their role in dataflow, indepedent of particular forms of representation, choices of cryptography implementation, details of hardware, etc. While this architecture holds based on the assumptions described above, particular choices of representation will carry concrete performance and security implications and should be chosen according to more specific requirements of particular scenarios. We offer a sketch of our choices of representation in section 5.

The architectural topology of Anoma operates on a substrate of networked Turing machines, which we refer to as _nodes_. Nodes may take on different operational _roles_, such as gossiping intents, searching for solutions, and voting in consensus. Although different roles will have different hardware requirements, nodes are a single class. Runtime configuration settings determine which roles a node will perform.

All nodes are assumed to compute deterministically, with the ability to locally generate randomness (which may be used, for example, as secret values in cryptography). Nodes are assumed to have read and write access to local storage. The set of nodes is unbounded and dynamic (nodes may enter and exit at any time). Nodes are assumed to be partially connected on an open network, where which other nodes a node can connect to will determine what roles that node can play. The network layer is assumed to be unreliable (messages may be arbitrarily dropped, duplicated, or reordered) and untrustworthy (unencrypted data is not secret). Specific roles may have slightly more stringent network assumptions (such as partial synchrony). 

## Intents

An _intent_ is a unit of ephemeral data describing a space of possible partial state transitions. Semantically, intents contain information about preferences. For example, an intent may express that Alice wishes to swap X for Y, or any X with property T for any Y with property U, or Z for some asset A, but only if A was previously owned by Judy, and only if Judy provides an additional signature. Counterparties are not required: an intent may express a complete state transition (complete state transitions are a subset of partial state transitions). For example, an intent may express that Alice wishes to send asset A to Judy, a state change which requires no one other than Alice to agree in order to enact. Such intents may still need solvers, if certain information is unknown by Alice. For example, Alice could express that she wishes to set a bounty value in proportion to the current temperature in Berlin, a value which she does not know but knows an oracle key for, and which a solver with oracle data access could provide. Intents which need neither counterparties nor solvers can be immediately turned into transactions. The particular syntax of representation of assets, properties, etc. is fixed at the application level. At the architectural level, intents are opaque bytestrings.

## Intent gossip layer

The _intent gossip layer_ is a virtual sparse overlay network for dissemination of intents, counterparty discovery, and matchmaking (when a solver combines intents to craft a valid transaction). The intent gossip layer consists of sparsely networked _intent gossip nodes_, where _intent gossip_ is a role any node can play. When a node authors an intent which requires matchmaking, that node broadcasts the intent over the intent gossip layer. This broadcast can be directed, where the node picks specific other nodes based on privacy, match expectation, and match cost considerations, or undirected, where the node broadcasts the intent as widely as possible. Nodes may offer a settlement-conditional fee along with an intent, to be paid only if the intent eventually makes its way into a transaction which is confirmed by consensus, they may pay a fee for confirmation and ordering of the (likely encrypted) intent in a data availability domain where solvers compete to find the best match for each group of intents, or they may rely on the counterparty to settle and offer no additional fee. 

## Solver

A _solver_ is a node which runs a _solver algorithm_ for matching intents of a particular form (or set of forms). Any node can play the role of solver. Solvers connect to the intent gossip network, accept intents of forms which they understand and which they expect to be worth the storage and bandwidth costs (perhaps due to a fee or an expected spread from a match), and run the solver algorithm to search the space of possible transactions based on the current state and intent pool, find subsets of intents which can be matched, and generate transactions which match them. 

## Transaction

A complete state transaction, referred to as a _transaction_, is a function from the current state to a new state. 

## Mempool

The _mempool_ is a virtual dense partitioned overlay network for transactions. The mempool is partitioned on the basis of security and concurrency domains (fractal instances), where nodes participating in the mempool gossip only transactions for fractal instances which they are interested in. By contrast to the intent gossip network, the mempool is dense in the sense that validators of a particular fractal instance must receive all of the transactions destinated for that instance. 

##  Data availability domain

A _data availability domain_ is a logical clock and data availability layer whereby intents in a particular batch can be made available to solvers who must compete to offer the best solution by a measurable criterion. 

## Security domain

A _security domain_ is a set of cryptographically identified nodes executing a particular state transition function in consensus, for which finality and correctness hold under a particular assumption of a certain fraction of nodes behaving according to protocol (generally n >= 3f + 1, but this can vary). Correctness of state transitions can be verified separately, but finality cannot, as it is impossible to prove the nonexistence of data (another finalised block at the same height, for example).

## Concurrency domain

A _concurrency domain_ is a total ordering over a set of transactions within the domain which may be partially ordered or unordered with respect to other concurrency domains. Concurency domains always operate within particular security domains (since the total order is enforced by the consensus of the security domain). 

## Fractal instance

A _fractal instance_ is an instance of the Anoma consensus and execution protocols operated by a set of networked validators. In general, fractal instances are security domains, in that they are operated by a particular set of validators, of which the user must trust a quorum; concurrency domains, in that they maintain a full order of only the transactions which they execute; and data availability domains, in that external observers can query the fractal instance to retrieve parts of its state. Fractal instances are sovereign, in that they do not depend on any other part of the fractal instance graph for continued correct execution, although their validator sets may overlap, a property which can be exploited in certain cases to provide cross-instance atomic transactions. Fractal instances, in order to be compatible with all features of the network, must implement the Anoma consensus and settlement protocols according to spec, but they can vary in Sybil resistance mechanisms, execution pricing, and local governance of protocol versioning, economic distribution regime, and irregular state transitions.


## Consensus
 
_Consensus_ is an algorithm for agreement between many parties (some possibly Byzantine) that forms a security domain and quantizes time. 

## Execution

An _execution environment_ is an algorithm for taking the state and a set of transactions and applying the transactions to the state. Anoma provides a _unified execution environment_ which can handle transparent, shielded, and private state transitions. _Transparent_ data is public to execution nodes and observers. _Shielded_ data is private to execution nodes and observers, but known to a single user, who can prove properties of it using zero-knowledge proofs. _Private_ data is known by no one independently and is computed and stored in encrypted form using various forms of homomorphic encryption. Anoma provides a general framework for reasoning about the privacy of data independently of the kind of verification performed, but performance characteristics of the underlying cryptographic schemes will determine the practical feasibility and execution costs of various applications. It is important to note that the delineation here is purely on the basis of state privacy. Technologies such as zero-knowledge rollups, for example, can be used with transparent, shielded, and private state transitions (at least in principle).

## Application

An _application_ is a semantic domain governing the form and logic of a particular partition of state which many users may interact with. An application consists of _state_, which may be partitioned across multiple fractal instances and shards within those instances, _application validity predicates_, which govern changes to the application's state, _user validity predicate components_, which may be included by the user in order to authorize certain interactions with the application, _intent formats_, which allow intents to be created by clients, reasoned about by solvers, and processed by validity predicates, _solver algorithms_, which allow solvers to craft transactions satisfying intents from an application (and possibly other applications), and _interfaces_, which provide users visual, spatial, and temporal abstractions for interacting with the application.

# Programming model

One considering the architecture of Anoma from the perspective of users with preferences over states of the system might ask the question of why are there applications at all? Cannot users merely articulate their preferences and the system enact them, without further component intermediation? In principle, they can, but the search space of solvers and difficulty of coordinating the relations between the state of the ledger and state of the world would be computationally intractable without coordination on particular forms of representation and particular logics of preference expression and settlement. Applications describe these particular forms, on which it is necessary to coordinate in order to express, match, and settle intents, and in order to provide simple and accurate interfaces for users. 

## Application components

An application on the Anoma architecture consists of intent formats, an application state validity predicate, user validity predicate components, solver algorithms, and one or many user interfaces. _Intent formats_ describe the form and semantics of particular intents utilised by the application, which must be created by the user interfaces, understood by intent gossip nodes, matched by solvers, and validated by the application's validity predicates. The _application state validity predicate_ encodes the relation governing valid state transitions of the application's state. _User validity predicate components_ encode the relations which users can approve in order to allow for safe interactions with this application. _Solver algorithms_ instruct a solver how to match this application's intents and form valid transactions. Finally, _user interfaces_ present users with a graphical or textual view of and controller for the application in question. 

## Application portability

By default, applications are portable across fractal instances, and application state validity predicates may also reason about security and concurrency domains in order to allow for safe interaction between users of an application across these domains. 

Although nothing ties a particular interface to a particular application, Anoma's intent gossip network is capable of acting as a data availability layer for interface code, in a way which allows secure synchronised interface and application versions. 

## Application security model

In Anoma, users distrust applications. Applications are never granted un-restricted access to modify a user's state. All state entries carry an explicit owner, and the validity predicate associated with that owner must authorise all changes to that state. Instead of authorising a la `transferFrom`, users add components to their validity predicates which allow for specific interactions with a specific application (which can then be perfomed non-interactively from the perspective of the user, if they have granted the application license to do so). These components can be altered or revoked at any time, and allow for "defense-in-depth" (e.g. prevent transfers of more than X within time bound t). 

## Application state model

Anoma assumes clients are _stateful_ - they are treated as components of the distributed system. Messages will only be sent once, and can be marked as delivered, in which case they will not be kept around. Message history can be reconstructed by reprocessing historical transaction archives.

# Intent lifecycle

## Usage examples

The architecture of Anoma is suitable for any application desiring to provide counterparty discovery and settlement for particular forms of preferences over a particular semantic domain. Here we sketch four applications: private bartering, capital-efficient automated market makers, quadratic public goods funding, and plural money. For each example, we include the actors, intents, validity predicates, intent flow, and privacy properties.

### Private bartering

- train tickets, festival tickets, hotel tickets
- actors: alice, bob, charlie, daniella
- intents: alice + bob to buy, charlie + daniella to sell
- VPs involved: ticket VPs, personal VPs
- Privacy properties: parties to trade know trade, plus solver, 

### Capital-efficient AMMs

- liquidity ranges
- actors: alice, bob, charlie
- intents: alice + bob to provide liquidity in different ranges, charlie to trade
- VPs involved: personal VPs incl. components, asset VPs
- Privacy properties: parties to trade know trade, plus solver, charlie can probably be solver

### Quadratic public-goods funding

- actors: funding provider, project creators, many individual funders
- intents: funding provider to respect quadractic formula, creators to require minimum in order to do anything, individual funders to contribute iff. funding is provided by FP
- VPs involved: funding provider VP, personal VPs, asset VPs
- Privacy properties: solver knows, funding provider can probably be solver

### Plural money

- actors: communities, individuals within communities
- intents: salsa transactions, monetary transfers in & outside of community
- VPs involved: community currency VPs, personal VPs, SALSA asset VPs
- Privacy properties: solvers within communities, probably

#### Private auctions

- actors: item seller, parties bidding
- intents: sale, bids
- VPs involved: auction VP, personal VPs
- privacy properties: item public, identities private, bids private

# Component descriptions

The Anoma architecture is complex and requires many individually intricate subcomponents which can be instantiated in a variety of ways with different performance, complexity, and ergonomic tradeoffs. Here we sketch the abstract interfaces required of necessary subcomponents and summarise our current development directions in instantiating them.

## Consensus

The consensus component is an algorithm by which many nodes can be abstracted as one virtual node, which will be correct subject to certain assumptions about the correctness of the constituent nodes (generally > 2/3). Just as individual nodes operate a deterministic state machine and send and receive messages in a local total order, virtual nodes created by use of the consensus algorithm operate a deterministic (replicated) state machine and send/receive messages in a total order. The consensus algorithm is responsible for abstracting many nodes into this virtual node by gossiping, ordering, and executing transactions (incoming messages), then finalising the updated states (outgoing messages) in a verifiable manner.

At present, the consensus component in Anoma is instantiated by [Typhon](https://specs.anoma.net/master/architecture/consensus/typhon.html), which draws substantially from [Heterogeneous Paxos](https://arxiv.org/abs/2011.08253), [Narwhal](https://arxiv.org/abs/2105.11827), and [Tendermint](https://arxiv.org/abs/1807.04938v3).

### Ordering

The ordering component of consensus is responsible for ordering transactions prior to execution, where nodes participating in consensus must agree on the ordering and ensure that all transactions so ordered are available to them for execution.

### Execution

The execution component of consensus is responsible for executing transactions on which an order has already been agreed, updating the state to reflect the results of transaction execution, and finalising the updated state so that external parties can inexpensively verify properties of it.

## Execution environments

The execution environment of Anoma ....


### Validity predicate system

handles sub-permissioning of state

split the keyspace into prefixes
first part of prefix indicates a specific vp
sentinel key within that prefix to store the VP code
vp enforces that vps associated with state which has changed are called
they can also check that other vps have been called
master vp enforces which vps see which data

### Taiga Unified EE

handles transparent, shielded, private data
relies on ZKP system, TFHE system
organisation of state:
- transparent: mutable k/v tree
- shielded: commitment tree, immutable notes, append-only, spend once/many
- private: mutable key -> ciphertext, read/write/operate on ciphertext
transit between data domains
- transparent -> shielded: trivial
- transparent -> private: encrypt
- shielded -> private: encrypt + prove in ZK
- shielded -> transparent: proof
- private -> transparent: decrypt (async)
- private -> shielded: encrypt-decrypt (async) (reencrypt?)

### Typhon EE

handles transparent data only

- typhon transparent ee
- state organised in key-value tree
- transactions declare parents of all subtrees of keyspace within which they will read/write
- typhon orders transactions concurrently on this basis
- master validity predicate key, called on all transactions, enforces further logic

- handles async message passing across fractal instances
- handles atomic read/write in chimera chains

## Gossip

intent gossip, transaction gossip, 

~ what is this system, for now built on libp2p

- local nodes have a virtual gossip layer
- virtual gossip layer for fractal instances?

## Compilation stack

Juvix -> AnomaVM (runs on EE)

AnomaVM: abstract (info-theoretic) cryptography, low-level instructions

Execution environment: concrete cryptography

VampIR: abstract polynomials -> concrete proof systems

### Juvix

high-level functional programming language -> anomavm

### AnomaVM

- access to transparent, shielded, private state
- abstract cryptography
- VPs check relation between prior/post states
	- compiled to some transparent instructions, some ZKP checks, HE instrs
- WASM/RISC5/special instructions
- compiles to:
	- transparent vm for executing party
	- transparent vm + proofs for parties with shielded state
	- polynomial representations of circuits

### VampIR

abstract polynomial -> concrete polynomial

## Fractal instance components

### Sybil resistance

proof-of-stake, proof-of-authority, liquid democracy based on identity substrate

~ namada PoS

### Governance

not about irreversible state changes
unplanned changes
governance has sybil resistance constraints
ultimate governance is social consensus

~ namada governance

### Resource pricing

need a sybil resistance mechanism for expensive compute operations on open network
eip 1559
ordering & execution priced separately
can also be identity-based quotas

~ namada eip1559


# Future directions

## Private counterparty discovery

The tradeoff axis between counterparty discovery, fairness, and privacy is quite fundamental: in order to find a counterparty in any way more efficient than random testing, you must provide some information about your preferences, which entails a corresponding loss of privacy, and in order to provide fairness across a larger set of parties in cases of uncertain information (e.g. variable prices), you must make your preferences public to a larger set of solvers who can see more intents at once and compete to find the fairest solutions.

Encrypted solving (solving intents which are completely private to the solver), while possible in principle, pairs the already NP problem of solving with the overhead of heavy-duty homomorphic encryption, and is likely to remain infeasible in the near future, but research into improved algorithms, application-specific solutions, and dedicated hardware could bring these overhead costs down over time.

## End-to-end behavioural verification

Anoma's architecture covers the domain from (abstract) Turing machines operating node software to (abstract) users authoring intents, and provides guarantees for the behaviours of the system with respect to the latter given certain assumptions about the behaviours of the former. In practice, safe usage of a deployment of Anoma depends not only on the correctness of this system but also on the correctness of the hardware utilised by nodes and the correctness of interfaces utilised by users. 
- extension of verification into the interface domain
- extension of verification into the hardware domain

# References
