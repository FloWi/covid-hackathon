# Cheeraty

<img src="logo.png" alt="Cheeraty - Eine platform um lokale Gutscheine in deiner Nachbarschaft anzubieten und zu finden" width="200"/>

The Challenge was defined [here](CHALLENGE.md).
The project entry in Devpost for the hackaton registration can be seen [here](https://devpost.com/software/1_544_lokale_gutscheine_nachbarschaft).
A short demo video can be found [here](https://www.youtube.com/watch?v=Q__lILNWXIA).
To try it yourself you can click [here](http://de.hivemind-vs-covid.s3-website-eu-west-1.amazonaws.com).
The UX design can be found [here](https://celwu7.axshare.com/#id=pnr8ux&p=landing_page&c=1).

To enter your own data you have to contact the Telegram bot called `@heinz_dembowski_bot`.
The bot will be deactivated soon though.

We organizse ourselves [here](TINYTASKS.md).
Contributors of the project can be found [here](CONTRIBUTORS.md).

Copyright notes can be found [here](COPYRIGHTS.md).

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
