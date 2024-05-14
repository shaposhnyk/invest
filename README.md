# Investment System Architecture

## How to use this document

Read this as a static document or explore it dynamically using [Structurizr](https://www.structurizr.com).

```bash
git clone https://github.com/shaposhnyk/invest.git
docker pull structurizr/lite
docker run -it --rm -p 8080:8080 -v ./invest:/usr/local/structurizr structurizr/lite
```

## Context

This document describes details of the design of the Investment application, its principal services, interaction and
high-level implementation details.

### High-level overview of involved software systems

![Global Context](./img/01-overview.svg)

We are focusing on the Investment part of Core Banking System (CBS) dedicated for order management, depicted on the
following diagram:
![Core Banking System](./img/02-cbs.svg)

#### Assumptions

- Only Application Gateway is exposed to Internet
- Only REST API of CBS is supposed to communicate with applications external to CBS
- Only protocols/ports required for the correct functioning of components are allowed Communication between different,
  components follow need to know principle
- REST API of CBS is exposed behind a Load Balancer (omitted on the diagram for simplicity)
- All parts of CBS are deployed in a way that allows horizontal scaling
- Components of Investment System (API, creator, validator, placer) initially may be separate modules of one deployment
  artifact They may be deployed as separate applications for operational reasons

## Principles

Our core implementation principles are:

### Architectural decisions are recorded

All Architectural are recorded in this repository 
using Architecture Decision Records or *ADR*, 
see [ADR folder](adr/).

### Resiliency and high-availability

Our system must be high-available and resilient to errors, 
for this we prefer *asynchronous* communication between the components:
[ADR 1 - Prefer Async Communication](/adr/cbs/0001-prefer-async-communication.md)

### Reliability and scalability

Our applications are deployed into a Kubernetes cluster 
and must be written in a such way that enables horizontal scaling:
[ADR 2 - Aime for horizontal scaling](/adr/cbs/0002-aim-for-horizontal-scaling.md)

### Data consistency

Leverage RDMS to achieve high data consistency.

When consistency between messaging and DB are required,
prefer [ADR 3 - Transactional Outbox with Change Data Capture](/adr/cbs/0003-use-transactional-outbox.md) patterns. NB!
On implementation side it's important to correctly use transactions,
see [ADR](/adr/cbs/0003-use-transactional-outbox.md) note for details.

On the Message Broker side for critical flows **idempotent producers** should be enabled.

On application side consumers must be written in a way that makes them effectively **idempotent**.

## Implementation considerations

Special considerations should be attributed to the following topics:

1) [Handing third-party errors and unavailability](docs/cbs/01-integrations.md)
2) [Handling consistency and avoiding order duplication](docs/cbs/02-consistency.md)
3) [Driving development team](docs/cbs/03-driving-dev.md)
4) [Notes on client notifications](docs/cbs/04-mobile-notifications.md)
