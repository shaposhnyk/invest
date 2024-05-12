# 2. Prefer async communication

Date: 2024-05-11

## Status

Accepted

## Context

We also need to decouple event producing and event consumption in our systems,
so load can be handled effectively and 
different system's parts could be scaled independently.

## Decision

Prefer asynchronous communications between components of our system. 
Using kafka, as message broker.

## Consequences

### Pros
It will be easier to test the components in isolation. 

When testing sending data, 
developer can install a local instance of kafka, like Confluent-local. 

When testing data consumption, either
- developer can install a local instance of kafka
- we may create a REST interface accepting the same payloads, as corresponding events

### Cons
- Learning Curve may be steep for developers who are not used to event-driven systems
