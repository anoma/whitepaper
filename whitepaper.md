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

# Motivation
- Intent-centric design philosophy: preferences over state transitions
- Declarative architecture designed to settle intents where possible, while minimising informational externalities
- Homogeneous architecture, heterogeneous security

Clues as to this motivation can be found in how applications end up handling intents anyways (0x, Wyvern, etc.).

# Architectural overview
(diagram of all architectural components)

Taxonomy of Anoma concepts
- Node
- Intent
- Intent gossip layer
- Solver
- Transaction
- Mempool
- Fractal instance
- Consensus
- Execution
- Transparent execution
- Shielded execution
- Private execution

# Architectural motivation

For the purpose of elucidation, consider a logically centralised database with a trusted operator possessed of infinite compute. Actors submit intents to this database, which accepts them one at a time in a total order. When an intent is submitted, if any combination of intents can be mutually satisfied by any state change, the operator enacts the state change (if multiple state changes satisfy, the operator arbitrarily chooses one), which subsequent queries to the database immediately reflect. If not, the operator stores the intent. If it were possible, this architecture would be ideal: state is unified, intents are always settled immediately, and settlement fairness operates on a simple first-in-first-out principle. Anoma aimes to asymptotically approximate this architecture given the constraints of heterogeneous trust, no absolute clock, and limited computational speed.

# Intent lifecycle

# Usage examples

- Private bartering (non-fungible & fungible tokens with properties)
- Capital-efficient AMMs (liquidity ranges)
- Private auctions

For each example:
- Actors involved
- Intents involved
- Validity predicates involved
- Intent flow
- Privacy properties

# Component descriptions

## Consensus

## Execution

## Gossip

## Fractal instance components

### Sybil resistance

### Governance

### Resource pricing

# Programming model





