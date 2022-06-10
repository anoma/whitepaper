---
title: 'Anoma: An intent-centric Byzantine-fault-tolerant distributed database architecture'
author: Heliax AG
fontsize: 9pt
date: \textit{Prerelease, \today}
abstract: |
	blahblah
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

# Background and Motivations

An *intent* is an expression of what a user wants to achieve whenever they interact with a protocol, for instance "transfer X from A to B" or "trade X for Y". So far all distributed ledger protocols (cryptocurrencies, smart contract platforms or application-specific Layer 1s) were designed with *transactions* as their most fundamental unit. Independent to what the actual user intent entailed, clients (e.g. wallets or other interfaces) are required to transform the intent into a transaction so the protocols are able to process it. In reality, most user intents are more complex than what can be represented in a transaction, for example "transfer X from A to B *privately*", "transfer X from A to B *where B receives Y*" or "trade X for Y *at the best market rate possible*".

Overtime, many protocols and clients have emerged so that more complex user intents can be interpreted and encoded into transactions to be settled on-chain. In the domain of fungible token trading, examples include the work from Flashbots or the Coincidence of Wants (CoW) Protocol, which via custom components at the peer-to-peer layer (mev-relay, CoWs, Batch Auctions), client (mev-geth), RPC layer (Flashbots protect) - integrated to grant the properties of "best on-chain price" and a "notion of fairness" via MEV mitigation mechanisms. In the domain of non-fungible token commerce, examples include the Wyvern DEX Protocol and more recently the Seaport Protocol, which supports orders that include more traits, often needed when a user intent involves NFTs. While we expect more protocols and components like the above to proliferate and diverisfy with specialisation in interpreting application-specific intents within the architectural boundaries of smart contract plaforms, there hasn't been any vertically-integrated protocol yet able to interpret and process intents natively and generically.

In Anoma's architecture, intents are the most fundamental unit and it is designed to handle intents generically. An intent encodes the user's preferred state transition, where the preferences can be as simple as a plain transfer or as complex and expressive as one that requires arbitrary computation. This intent-centric philosophy results in a declarative architecture that is designed to settle intents wherever possible – as they were defined by the user *and nothing else*, thereby minimising informational externalities, which extend beyond the loss of anonymity or the ability for certain parties to benefit disproportionally from users' actions without adding comparable value in the process. By adopting a declarative paradigm, Anoma can grant users more control and realise their intents with not only stronger privacy, security, and performance guarantees, but also more expressivity and flexibility in articulating their intents to an extent that they can define arbitrarily both the what and the how the intents are processed.

Compared to architectures centered around smart contracts that could encode arbitrary state transition functions, Anoma's declarative programming paradigm provides application developers a better scoped problem space, as they will only need to reason through the compatibility between user intents and validity predicates, and set the precedence for building safer by construction applications – or applications that do not work as the developer ended up writing logic that violated corresponding validity predicates. Anoma's architecture opens up a new way of designing decentralized applications that benefit from the expressivity and composability of intents, the expressivity and guarantees of validity predicates, as well as a more efficient settlement mechanism derived from the design of the state mechaine and ledger that makes the separation between computation and verification more explicit, where computation can be handled off-chain (and can be thereby parallelised), while only verification is handled on-chain (validity predicates are checked before state transitions are accepted). Users benefit from a better user experience when interacting with applications built following this declarative programming paradigm, as they interact directly with their own intents and define their own validity predicates - making it easier to understand and reason through what they are doing without requiring them to understand the underlying stack.

As the volume and diversity of user intents continues to grow, Anoma's architecture is designed to process any intents generically, including the yet-to-be disovered ones. Combined with its ability to handle already-known intents with stronger security performance guarantees, and better developer and end-user experience, we believe that Anoma can open up a world for not only upgrading existing decentralized applications with stronger guarantees and different trade-offs, but also enable new kinds of decentralized applications and novel economics that existing architectures cannot.

---
Notes from before: 
- Intent-centric design philosophy: preferences over state transitions
- Declarative architecture designed to settle intents where possible, while minimising informational externalities
- Homogeneous architecture, heterogeneous security
- Minimise architectural assumptions, constrain the design space

Additions from Christopher:
- systems design is an attempt at synthesis between constructive possibility enumeration of which systems are possible and purpose-directed inquiry of what a system is for, and what guarantees it can provide as a black-box abstraction to users based on an understanding of what they want. failure to correctly specify the former will result in incohererent or inconsistent systems, while failure to correctly understand the latter will result in systems which are not useful, or worse, systems which make a false claim of black-box behaviour which they do not in fact adhere to, or systems on top of which "weak" application layer constructions ruin the intended properties of the protocol architecture
- at the same time, if the architecture is too specific, and different architectures are designed for seemingly different use-cases which do not in fact require separate architectures, systems will be unnecessarily incompatible
	- there is a specific level of abstraction proper to the generalisation of a set of use-cases
- anoma is an attempt to synthesise between the constructive possibility of Byzantine-fault-tolerant distributed database systems and an understanding of what they are for that is at the proper level to allow for the correct amount of generality while capturing use practices in order to provide end-to-end guarantees.
- intent-centric design philosophy
	- theoretical basis: why would one use a distrubuted database ~ must have some import
		- settle intents where possible, while minimising externalities
	- practical basis: existing examples (wyvern, 0x, cowswap) all end up with intents
- homogeneous architecture, heterogeneous security
	- architecture is a benevolent monopoly, modularly split, tradeoffs can be parameterised as runtime configuration choices
	- security (who) is a political decision and doesn't have a single right answer, depends on the semantics and context of use
	- compare: internet routers, IP protocols, HTTP vs. _who_ to connect to
	- yet the internet fails to provide interoperability in practice due to control of data and properietary protocols at the application layer

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

## Data availability domain

A _data availability domain_ is an 
- must run on fractal instance for ordering guarantees
- in principal can be multiple separate ones per fractal instance
- 

## Transaction

A complete state transaction, referred to as a _transaction_, is a function from the current state to a new state.

## Mempool

The _mempool_ is a virtual dense partitioned overlay network for transactions. The mempool is partitioned on the basis of security and concurrency domains (fractal instances), where nodes participating in the mempool gossip only transactions for fractal instances which they are interested in. By contrast to the intent gossip network, the mempool is dense in the sense that validators of a particular fractal instance must receive all of the transactions destinated for that instance. 

##  Data availability domain

A _data availability domain_ is a logical clock and data availability layer whereby intents in a particular batch can be made available to solvers who must compete to offer the best solution by a measurable criterion. 

## Fractal instance

A security (and necessarily concurrency) domain, referred to as a _fractal instance_, is an XXX

## Shard

A _shard_ is a concurrency domain within a security domain.

## Consensus
 
_Consensus_ is an algorithm for agreement between many parties (some possibly Byzantine) that forms a security domain and quantizes time.

## Execution

An _execution environment_ is an algorithm for taking the state and a set of transactions and applying the transactions to the state

The _transparent execution environment_ is an execution environment where all data is public to execution nodes and observers. 

The _shielded execution environment_ is an execution environment where all data is private to execution nodes and observers, where only single-user private state is supported and privacy is provided through zero-knowledge proofs.

The _private execution environment_ is an execution environment where all data is private to execution nodes and observers, where multi-user private state is supported through direct computation over encrypted data.

It is important to note that the delineation between kinds of execution environments made here is purely on the basis of privacy and state model. Technologies such as zero-knowledge rollups, for example, can in principle be used with any of these environments.

## Application

An _application_ is a semantic domain governing the form and logic of a particular partition of state which many users may interact with.

- Application
  - State
  - VPs (~asset VPs)
  - User VP components
  - Intent formats
  - Solver algorithms
  - Interface(s)

# Intent lifecycle

## Usage examples

For each example:

- Actors involved
- Intents involved
- Validity predicates involved
- Intent flow
- Privacy properties

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

## Consensus

hpaxos
ibc 

## Execution

transparent, shielded, private
VP architecture
cross-execution-environment communication

information theoretic models
VM, ZKP system, HE/MPC (?) system

how to instantiate
WASM, Plonkup, some HE

## Gossip

intent gossip, transaction gossip

## Fractal instance components

### Sybil resistance

proof-of-stake, proof-of-authority, liquid democracy based on identity substrate

### Governance

not about irreversible state changes
unplanned changes
governance has sybil resistance constraints
ultimate governance is social consensus

### Resource pricing

need a sybil resistance mechanism for expensive compute operations on open network
eip 1559
ordering & execution priced separately
can also be identity-based quotas

# Programming model

Why are there applications at all?
Applications describe particular forms, on which it is necessary to coordinate in order to execute discrete logic.
Applications reflect a particular semantics.

What is an application on Anoma?

- Intent formats
- Application state validity predicate
  - Including proofs of correctness
- User validity predicate components
- Solver algorithms
- Renderable interface
  - For now, this is just data
  - Maybe semantic connections in the future
  - Anoma as a DA layer can host

Security model

- In Anoma, users distrust applications

State model
Anoma assumes clients are _stateful_, they are treated as components of the distributed system

- e.g. messages will only be sent once
- message history can be reconstructed with historical archives

# Future directions

- exploring more detailed tradeoffs along the privacy / counterparty discovery axis
- encrypted matchmaking
- extension of verification into the interface domain
- extension of verification into the hardware domain

# References