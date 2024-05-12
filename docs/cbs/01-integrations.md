## Handling third-party integration?

### Context
We have a fragile third-party system. 
The API can be very slow and may sometime timeout 
or even be completely overwhelmed by our requests and go down.

### Approach

We need to introduce some kind of **back-loop** between
third-party system and our systems.

We will **decorrelate**
the speed of our producers (CBS)
from ingestion speed of the third-party system (EIS)
by persisting the requests to EIS in a kafka topic.

In this way, we can send them to EIS asynchronously
with a rate EIS is able to manage. For this, we need to **control the outflow** of requests to the third-party system.
We can correlate number of requests sent to the number of errors we observe.

- If we observe 0 errors during an interval of *T*, we will send up to *N_max* events to the third-party system;
- If we observe more than *E_max* errors during an interval of *T*, we will **stop** outflow;
- Otherwise, we will send a number of events inversely proportional to the number of errors, i.e. *E/E_max*.

Actual values for *N_max*, *E_max*, and *T* should be found through experimentation.

### Implementation notes
Notes