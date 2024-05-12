# Investment System Architecture

## How to use this document

Read this readme as a static document or explore it dynamically using Structurizr.

```bash
git clone https://github.com/shaposhnyk/invest.git
docker pull structurizr/lite
docker run -it --rm -p 8080:8080 -v ./invest:/usr/local/structurizr structurizr/lite
```

## Context

This document describes details of the design of 
the Investment application, its principal services, 
interaction and high-level implementation details. 

### High-level overview of involved software systems
![Overview](./img/01-overview.svg)

Here we will be focusing on the Investment Services part 
of Core Banking System (CBS) part dedicated 
to order management for the Bank.
![Core Banking System](./img/02-cbs.svg)

## Principles
Our core implementation principles are:

### Resiliency and high-availability
Our system must be high-available and resilient to errors, 
for this we will prefer asynchronous communication between the components:
[Prefer Async Communication](/adr/cbs/0001-prefer-async-communication.md)

### Reliability and scalability
Our applications will be deployed into a Kubernetes cluster 
and must be written in a such way that enabled horizontal scaling.
[Aime for horizontal scaling](/adr/cbs/0002-aim-for-horizontal-scaling.md)

### Data consistency
Leverage RDMS to achieve high-data consistency.

When consistency between messaging and DB are required, 
we should [Use Transactional Outbox with Change Data Capture patterns](/adr/cbs/0003-use-transactional-outbox.md). 
NB! On implementation side it's important to correctly use transactions, 
i.e. use *safeAndFlush()*, instead of *safe()*, when persisting messages.

On message broker (kafka) side for critical flows **idempotent producers** should be enabled.

On application sides consumers must be written in a way that they are effectively **idempotent**.

## Implementation considerations

Special considerations should be done to the following topics: 
1) [Handing third-party errors and unavailability](/docs/cbs/01-integrations.md)
2) [Handling consistency and avoiding order duplication](/docs/cbs/02-consistency.md)
3) [Driving development team](/docs/cbs/03-driving-dev.md)