## Handling consistency and avoid duplication.

### Context
As a bank, consistency is a key. 
We need to avoid the need of manual reconciliation operations.

### Approach
We will use
1) RDBMS to store data which require high-consistency.
2) Change Data Capture pattern, as explained [here](../adr/cbs/0003-use-transactional-outbox.md), 
when events must be sent in a way, which is consistent with the data in DB
3) Idempotent requests/consumers, when possible

### Examples
#### Initial order submission by Mobile Client 
1) Client configures the order
2) Mobile Client (MC) generates an **UID** for the order
3) and submits it to Application Gateway API, which acknowledges the reception 
4) If Order with such **UUID** did not exist - *happy path*, 
   1) it is persisted into the DB 
   2) a notification is sent to the MC that order is created  
5) If Order with such **UUID** exists - *potential retry of the request due to network conditions*, 
   1) Nothing to be done

In this way:
- we can handle creation in an *idempotent way*, ignoring duplicate submissions, if they arrive
- we minimize the time the connection will *remain open* from a MC to Application Gateway, 
thus reducing the risk of interruption

#### Order updating
Order, as requested by Client, will be **immutable** in our model. 
For state changes we will use *Event Sourcing* approach.

In the DB, there will be
- a table Orders - for immutable Orders in CBS identified by UID 
- a table OrderStatuses - for status changes, containing Order's UID, Status, Timestamp and additional information, like rejection reason

Operations team, as well as application itself,
will be able to reconstruct the Order state by replaying entries in OrderStatuses.  

Changes in OrderStatuses will be streamed to kafka by a [DB plugin](/adr/cbs/0003-use-transactional-outbox.md), 
so they can be consumed by other services of our applications.

More specifically:  
- changes to PENDING will be consumed by Validator-App
- changes to REQUESTED will be consumed by Placer-App
- all other changes will be sent to [notification sub-system](04-mobile-notifications.md)

Note that to maintain high-consistency new entries of OrderStatuses
must be inserted using **saveAndFlush()**