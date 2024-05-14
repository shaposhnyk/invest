## How to handle third-party integration?

### Context
We have a fragile third-party system. 
The API can be very slow and may sometime timeout 
or even be completely overwhelmed by our requests and go down.

### Assumptions
- EIS has a REST endpoint which takes and order with its UID and creates it. The response is either: OK, Not OK or Already exist.
- EIS has a REST liveness endpoint
- for webhook EIS calls directly CBS REST API

### Approach

We need to introduce some kind of **back-loop** between
third-party system and our systems.

We do
- **decorrelate** the speed of our producers (CBS)
from ingestion speed of the third-party system (EIS)
by persisting the requests to EIS in a kafka topic 
- correlate number of requests sent to EIS with the number of errors we observe

In this way, we send them to EIS asynchronously with a rate EIS is able to manage.

In particular:
- If we observe 0 errors during an interval of *T*, we send up to *N_max* events to the third-party system;
- If we observe more than *E_max* errors during an interval of *T*, we **stop** outflow;
- Otherwise, we send a number of events inversely proportional to the number of errors, i.e. *E/E_max*.

Actual values for *N_max*, *E_max*, and *T* should be found through experimentation.

### Implementation notes
- When timeout or error happens, we emit an error message to a specific topic, p.ex. *eisErrors*
- We do count number of messages in this topic over a running window of *T* using Kafka streams, writing in *eisErrorsCount*
- We consume *eisErrorsCount* topic 
  - if it go over *E_max*, we pause consumption from *orders-in-REQUESTED-state*
  - otherwise, we continue consumption from *orders-in-REQUESTED-state*
- We ping liveness endpoint of EIS in a cronjob, sending error messages, 
which should have higher weight then regular error, also in *eisErrors*
