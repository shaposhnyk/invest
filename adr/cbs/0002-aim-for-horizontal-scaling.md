# 2. Aim for horizontal scaling

Date: 2024-05-11

## Status

Accepted

## Context

We expect tenfold customer growth in the nearest future, 
so we should design system for scalability.  

## Decision

Design applications in a cloud-native way, 
so that adding an instance/pod will allow better throughput.
Expect that application will be deployed either on a kubernetes cluster 
or as lambda functions behind application gateway.

## Consequences

Scalable application and effective use of resources.