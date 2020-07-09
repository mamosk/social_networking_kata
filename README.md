Social Networking Kata
======================
Implementation of [the social networking kata](https://github.com/xpeppers/social_networking_kata) with a _microservices_ architecture.

---

## Get started
To spin up the services:
- get [Docker](https://docs.docker.com/get-docker/) `1.12.0+` if you do not have it yet,
- clone the repo,
- run the `kata` script.

---

## Services

### Timeline API
Users timelines are written (_posting_ kata) and read (_reading_ kata) using [Node-RED](https://nodered.org/).
> Only last 5 posts within last 24h are read for each user.

Exposed endpoints are:
- `GET` http://localhost:11881/api/v1/reading?users=Alice,Bob,Charlie
- `POST` http://localhost:11881/api/v1/posting
  ```
  {
      "user": "Alice",
      "text": "I love the weather today."
  }
  ```
- `GET` http://localhost:11881/api/v1/test

### Timeline db
Users timelines are stored using [InfluxDB](https://www.influxdata.com/products/influxdb-overview/).
> Posts are stored with `1s` precision.

---

## Tests

All API services have a testing endpoint which returns:
- HTTP status code `200` if test is **passed**,
- HTTP status code `418` if test is **failed**.

No further element (payload, headers...) is relevant for tests.

---
Made with ❤️ by [Fabio Michelini](https://www.linkedin.com/in/fabio-michelini/)