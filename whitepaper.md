---
title: Anoma Architecture
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

## Motivation

- Intent-centric design philosophy: preferences over state transitions
- Declarative architecture designed to settle intents where possible, while minimising informational externalities
- Homogeneous architecture, heterogeneous security
- Minimise architectural assumptions, constrain the design space

Clues as to this motivation can be found in how applications end up handling intents anyways (0x, Wyvern, etc.).

## Architectural motivation

For the purpose of elucidation, consider a logically centralised database with a trusted operator possessed of infinite compute. Actors submit intents to this database, which accepts them one at a time in a total order. When an intent is submitted, if any combination of intents can be mutually satisfied by any state change, the operator enacts the state change (if multiple state changes satisfy, the operator arbitrarily chooses one), which subsequent queries to the database immediately reflect. If not, the operator stores the intent. If it were possible, this architecture would be ideal: state is unified, intents are always settled immediately, and settlement fairness operates on a simple first-in-first-out principle. Anoma aimes to asymptotically approximate this architecture given the constraints of heterogeneous trust, spatiotemporal locality, and limited computational speed. Let us consider each of these in turn.

Heterogeneous trust: motivated by semantics, particular states of the database may be preferred by certain parties in the real world, clients of the system must place trust in a designated set of actors to maintain the database (who could perhaps be the clients themselves, but still must be designated). Clients will want to minimise the trust required, and different clients with different semantics may have different trust preferences, and the system design needs to allow clients to interact where their trust models are compatible, and prevent interactions from outside their trust models from impacting local guarantees provided to those clients. Ways of minimising the trust required: BFT consensus, cryptography, proofs-of-correct-execution, etc.

Spatiotemporal locality: No absolute clock, per Einstein, clocks are relative. Sharded security and concurrency domains must settle for a partial ordering, and the ordering required should be minimised to as local a domain as possible. In cases where fairness is desired, the system should craft a basis for a logical clock to render moot latency differences in a given physical / informational domain. Locality of safety and liveness should be preserved.

Limited computational speed: NP != P, searching for satisfying computations must be specialised to the particular form and is to be exposed in the programming interface. Quality-of-service guarantees require bounded compute.

Limited computational speed motivates the separation of the role of solver from the role of settlement. Spatiotemporal locality and heterogeneous trust motivate separation of security and concurrency domains.

## Architectural topology

(diagram of all architectural components)

### Basics: nodes and network layer

Anoma's architectural topology is logical, in the sense that it consists of a set of logical abstractions delineated by their role in dataflow, indepedent of particular forms of representation, choices of cryptography implementation, details of hardware, etc. While this architecture holds based on the assumptions described above, particular choices of representation will carry concrete performance and security implications and should be chosen according to more specific requirements of particular scenarios. We offer a sketch of our choices of representation in section 5.

The architectural topology of Anoma operates on a substrate of networked Turing machines, which we refer to as _nodes_. Nodes may take on different operational _roles_, such as gossiping intents, searching for solutions, and voting in consensus. Although different roles will have different hardware requirements, nodes are a single class. Runtime configuration settings determine which roles a node will perform.

All nodes are assumed to compute deterministically, with the ability to locally generate randomness (which may be used, for example, as secret values in cryptography). Nodes are assumed to have read and write access to local storage. The set of nodes is unbounded and dynamic (nodes may enter and exit at any time). Nodes are assumed to be partially connected on an open network, where which other nodes a node can connect to will determine what roles that node can play. The network layer is assumed to be unreliable (messages may be arbitrarily dropped, duplicated, or reordered) and untrustworthy (unencrypted data is not secret). Specific roles may have slightly more stringent network assumptions (such as partial synchrony). 

### Intents

An _intent_ is a unit of ephemeral data describing a space of possible partial state transitions. Semantically, intents contain information about preferences. For example, an intent may express that Alice wishes to swap X for Y, or any X with property T for any Y with property U, or Z for some asset A, but only if A was previously owned by Judy, and only if Judy provides an additional signature. Counterparties are not required: an intent may express a complete state transition (complete state transitions are a subset of partial state transitions). For example, an intent may express that Alice wishes to send asset A to Judy, a state change which requires no one other than Alice to agree in order to enact. Such intents may still need solvers, if certain information is unknown by Alice. For example, Alice could express that she wishes to set a bounty value in proportion to the current temperature in Berlin, a value which she does not know but knows an oracle key for, and which a solver with oracle data access could provide. Intents which need neither counterparties nor solvers can be immediately turned into transactions. The particular syntax of representation of assets, properties, etc. is fixed at the application level. At the architectural level, intents are opaque bytestrings.

### Intent gossip layer

The _intent gossip layer_ is a virtual sparse overlay network for dissemination of intents, counterparty discovery, and matchmaking (when a solver combines intents to craft a valid transaction). The intent gossip layer consists of sparsely networked _intent gossip nodes_, where _intent gossip_ is a role any node can play. When a node authors an intent which requires matchmaking, that node broadcasts the intent over the intent gossip layer. This broadcast can be directed, where the node picks specific other nodes based on privacy, match expectation, and match cost considerations, or undirected, where the node broadcasts the intent as widely as possible. Nodes may offer a settlement-conditional fee along with an intent, to be paid only if the intent eventually makes its way into a transaction which is confirmed by consensus, they may pay a fee for confirmation and ordering of the (likely encrypted) intent in a data availability domain where solvers compete to find the best match for each group of intents, or they may rely on the counterparty to settle and offer no additional fee. 

### Solver

A _solver_ is a node which runs a _solver algorithm_ for matching intents of a particular form (or set of forms). Any node can play the role of solver. Solvers connect to the intent gossip network, accept intents of forms which they understand and which they expect to be worth the storage and bandwidth costs (perhaps due to a fee or an expected spread from a match), and run the solver algorithm to search the space of possible transactions based on the current state and intent pool, find subsets of intents which can be matched, and generate transactions which match them. 

### Data availability domain

A _data availability domain_ is an 
- must run on fractal instance for ordering guarantees
- in principal can be multiple separate ones per fractal instance
- 

### Transaction

A complete state transaction, referred to as a _transaction_, is a function from the current state to a new state.

### Mempool

The _mempool_ is a virtual dense partitioned overlay network for transactions. The mempool is partitioned on the basis of security and concurrency domains. 

-  Data availability domain

### Fractal instance

A security (and necessarily concurrency) domain, referred to as a _fractal instance_, is an XXX

### Shard

A _shard_ is a concurrency domain within a security domain.

### Consensus
 
_Consensus_ is an algorithm for agreement between many parties (some possibly Byzantine) that forms a security domain and quantizes time.

### Execution

An _execution environment_ is an algorithm for taking the state and a set of transactions and applying the transactions to the state


- Transparent execution
  - Execution environment where all data is public
- Shielded execution
  - Execution environment where data is private to execution observers, but only supporting single-user private state
- Private execution
  - Execution environment where data is private to execution observers, supporting multi-user private state through direct computation over encrypted data

### Application

An application is a semantic domain. 
- Application
  - State
  - VPs (~asset VPs)
  - Intent formats
  - Solver algorithms


## Intent lifecycle

### Usage examples

For each example:

- Actors involved
- Intents involved
- Validity predicates involved
- Intent flow
- Privacy properties

#### Private bartering

- train tickets, festival tickets, hotel tickets
- actors: alice, bob, charlie, daniella
- intents: alice + bob to buy, charlie + daniella to sell
- VPs involved: ticket VPs, personal VPs
- Privacy properties: parties to trade know trade, plus solver, 

#### Capital-efficient AMMs

- liquidity ranges

## Quadratic funding

intents
projects have a minimum to do anything

## Plural money

explain to implement matt prewitt's post on Anoma

#### Private auctions

requires private execution environment

## Component descriptions

### Consensus

### Execution

### Gossip

## Fractal instance components

### Sybil resistance

### Governance

### Resource pricing

### Public goods funding

## Programming model

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

# Conclusion


# References