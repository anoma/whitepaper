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

## Architectural overview

(diagram of all architectural components)

The logical model of Anoma operates on the basis of networked Turing machines. Nodes are a single class, although different roles will have different requirements.
Open network with permissionless entry and untrusted intermediaries.

Nodes in anoma are assumed to be deterministic (except for randomness generated for use in cryptography the value of which does not change the results of execution) and stateful

Lexicon of Anoma concepts

- Node
  - Networked Turing machine
- Intent
  - An intent is ephemeral data containing information about preferences
- Intent gossip layer
  - Virtual network overlay for intents
  - Could also be used for other data applications wish to locally broadcast?
  - Broadcasts data with local relevancy policies
- Solver
  - Role attempting to combine intents by searching the space of transactions and states
- Transaction
  - Tentative state changes (function from current state to new state), with a specific set of states for which it will be considered valid
- Mempool
  - Virtual network overlay for transactions
- Fractal instance
  - Security (and necessarily concurrency) domain
- Shard
  - Concurrency domain within a security domain
- Consensus
  - Algorithm for agreement between many parties (some possibly Byzantine) that forms a security domain and quantizes time
- Execution
  - Algorithm for taking the state and a set of transactions and applying the transactions to the state
- Transparent execution
  - Execution environment where all data is public
- Shielded execution
  - Execution environment where data is private to execution observers, but only supporting single-user private state
- Private execution
  - Execution environment where data is private to execution observers, supporting multi-user private state through direct computation over encrypted data
- Application
  - State
  - VPs (~asset VPs)
  - Intent formats
  - Solver algorithms

## Architectural motivation

For the purpose of elucidation, consider a logically centralised database with a trusted operator possessed of infinite compute. Actors submit intents to this database, which accepts them one at a time in a total order. When an intent is submitted, if any combination of intents can be mutually satisfied by any state change, the operator enacts the state change (if multiple state changes satisfy, the operator arbitrarily chooses one), which subsequent queries to the database immediately reflect. If not, the operator stores the intent. If it were possible, this architecture would be ideal: state is unified, intents are always settled immediately, and settlement fairness operates on a simple first-in-first-out principle. Anoma aimes to asymptotically approximate this architecture given the constraints of heterogeneous trust, spatiotemporal locality, and limited computational speed. Let us consider each of these in turn.

Heterogeneous trust: motivated by semantics, particular states of the database may be preferred by certain parties in the real world, clients of the system must place trust in a designated set of actors to maintain the database (who could perhaps be the clients themselves, but still must be designated). Clients will want to minimise the trust required, and different clients with different semantics may have different trust preferences, and the system design needs to allow clients to interact where their trust models are compatible, and prevent interactions from outside their trust models from impacting local guarantees provided to those clients. Ways of minimising the trust required: BFT consensus, cryptography, proofs-of-correct-execution, etc.

Spatiotemporal locality: No absolute clock, per Einstein, clocks are relative. Sharded security and concurrency domains must settle for a partial ordering, and the ordering required should be minimised to as local a domain as possible. In cases where fairness is desired, the system should craft a basis for a logical clock to render moot latency differences in a given physical / informational domain. Locality of safety and liveness should be preserved.

Limited computational speed: NP != P, searching for satisfying computations must be specialised to the particular form and is to be exposed in the programming interface. Quality-of-service guarantees require bounded compute.

Limited computational speed motivates the separation of the role of solver from the role of settlement. Spatiotemporal locality and heterogeneous trust motivate separation of security and concurrency domains.

## Intent lifecycle

### Usage examples

For each example:

- Actors involved
- Intents involved
- Validity predicates involved
- Intent flow
- Privacy properties

#### Private bartering

(non-fungible & fungible tokens with properties)

#### Capital-efficient AMMs

- liquidity ranges

#### Plural money

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
