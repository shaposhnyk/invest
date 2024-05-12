# 3. Use transactional outbox pattern to produce consistent events

Date: 2024-05-11

## Status

Accepted

## Context

As a bank, consistency of data is key. 
We need to design to avoid manual reconciliation operations. 

## Decision

When consistency between data in DB and produced events is required,
we should use 
[Transactional Outbox](https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/transactional-outbox.html) 
and [Change Data Capture](https://en.wikipedia.org/wiki/Change_data_capture) 
patterns leveraged by DB plugins like Debezium. 

## Consequences

Special attention should be made to transaction management in java application,
to avoid confusion between **save()** and **saveAndFlush()** operations,
which will behave similarly when everything is fine, 
but will produce different behaviour in the case of failure.