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





