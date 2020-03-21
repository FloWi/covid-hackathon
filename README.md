# Services Overview

## Tiny tasking

- Follow up on hackathon organisation & slack stuff (F)
- Mapbox   registration & find out how api works (Adress to Geocoordinate)
- Finding out which sms service to use and how (aws?) (I, V & A :D)
- Research which serverless database we could use (ideally with geo queries)
- Set up aws http api for the two lambdas (J)
- Purescript lambda as sms webhook (V? IDK)
- Frontend  (J, M)
- Set up public s3 bucket for hosting web ui (F, )
- Purescript lambda as ui endpoint (J, F)
- Evaluate cost & effort for elasticsearch ()
- Evaluate using Telegram API (M)
- Encode/Decode JSON (https://github.com/justinwoo/purescript-simple-json) (I)
- HTTP client (https://github.com/justinwoo/purescript-milkis) (I)
- AWS Hivemind Sub account ()
- Build & Deployment pipeline (F, )

Deferred
- Twilio registration & check out how to set up web hook
  - No German phone numbers possible for SMS


## Tech Stack

- CDK with typescript for infrastructure
- Purescript for frontend
- HTTP APIs with JSON payloads between frontend/backend

## Message Receiver backend

- receives textmessages
- decodes the geolocation and voucher offer from the textmessage
- posts the voucher offer to elasticsearch

## Voucher Finder backend

- provides an api to query existing vouchers
- accepts a location and a radius

## Voucher Finder frontend


# message objects

## voucherOffer

## voucherSearchResult

### resources

Twilio sms api - https://www.twilio.com/docs/sms

Elastic search rest api - https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-geo-distance-query.html

Mapbox geocoding - https://docs.mapbox.com/api/search/

#
