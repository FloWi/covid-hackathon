# Services Overview

We organizse ourselves [here](TINYTASKS.md).

## Tech Stack

- CDK with typescript for [infrastructure](infrastructure/README.md)
- Purescript for frontend
- HTTP APIs with JSON payloads between frontend/backend

## Message Receiver backend

Further documentation can be found [here](message-receiver/README.md).

- receives textmessages
- decodes the geolocation and voucher offer from the textmessage
- posts the voucher offer to elasticsearch

## Voucher Finder backend

- provides an api to query existing vouchers
- accepts a location and a radius

## Voucher Finder frontend

Further documentation can be found [here](ui/README.md).

# message objects

## voucherOffer

## voucherSearchResult

### resources

Twilio sms api - https://www.twilio.com/docs/sms

Elastic search rest api - https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-geo-distance-query.html

Mapbox geocoding - https://docs.mapbox.com/api/search/
