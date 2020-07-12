Social Networking Kata
======================
This is an implementation of [the social networking kata](https://github.com/xpeppers/social_networking_kata) proposed by [_Xpeppers_](https://www.xpeppers.com/en/) team.

---

## Get started

To spin up the services and run the CLI:

1. get [Docker](https://docs.docker.com/get-docker/) `1.12.0+` if you do not have it yet,
5. clone the repo — follow [this guide](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository) if needed,
3. run the `kata` script using one of following commands:
   - on **Windows**:
     ```
     %SYSTEMDRIVE%:\path\to\the\repo\kata.cmd
     ```
   - on **Linux**:
     ```
     /path/to/the/repo/kata.sh
     ```
> It may take a while the first time, since it has to download several dependencies...

When everythins is up and running you can type `help` in the CLI to display available commands. Enjoy!

---

## Architecture
>```
>                         Timelines API ---- Timelines DB ---- Timelines DB admin
>                       /
>                      /
>CLI ---- API gateway <
>                      \
>                       \
>                         Followers API ---- Followers DB ---- Timelines DB admin
>```
### CLI
The _command line interface_ is implemented in [Bash](https://www.gnu.org/software/bash/) using [curl](https://curl.haxx.se/) and [jq](https://stedolan.github.io/jq/) to interact with the API gateway.

### Services
Once the services are up and running, you can **[inspect]** them.
> The credentials are in the `.env` file.

- [API gateway](#api-gateway)
  [**[inspect]**](http://localhost:11881/)
- [Timelines](#timelines)
  - [API](#timelines-api)
    [**[inspect]**](http://localhost:11888/)
  - [DB](#timelines-DB)
  - [DB admin](#timelines-DB-admin)
    [**[inspect]**](http://localhost:18888/)
- [Followers](#followers)
  - [API](#followers-api)
    [**[inspect]**](http://localhost:18080/api/v1/users)
  - [DB](#followers-DB)
  - [DB admin](#followers-DB-admin)
    [**[inspect]**](http://localhost:15050/)

#### API gateway
The API gateway exposes the **4 fundamental** API's using [Node-RED](https://nodered.org/) with [JSONata](https://jsonata.org/):
- _posting_ is routed to **timelines** _posting_,
- _reading_ is routed to **timelines** _reading_,
- _following_ is routed to **followers** _following_,
- _wall_ performs an API composition of
  **followers** _following_ **+**
  **timelines** _reading_.

#### Timelines

##### Timelines API
Users timelines are written (_posting_ kata) and read (_reading_ and _wall_ kata) using [Node-RED](https://nodered.org/) with [JSONata](https://jsonata.org/).
> Only last 50 posts within last week are read for each user.

Exposed endpoints are:
- _reading_/_wall_:
  `GET` http://localhost:11888/api/v1/reading?users=Alice,Bob,Charlie
- _posting_:
  `POST` http://localhost:11888/api/v1/posting JSON, example:
  ```
  {
      "user": "Alice",
      "text": "I love the weather today."
  }
  ```
- _testing_:
  `GET` http://localhost:11888/api/v1/test returns:
  - HTTP status code `200` if test is **passed**,
  - HTTP status code `418` if test is **failed**.

##### Timelines DB
Users posts are stored into a _time serie_ using [InfluxDB](https://www.influxdata.com/products/influxDB-overview/).
> Posts are stored with `infinite` retention policy and precision of `1s`.

##### Timelines DB admin
The _time serie_ database server is managed using [Chronograf](https://www.influxdata.com/time-series-platform/chronograf/). You can query the timelines [here](http://localhost:18888/sources/0/chronograf/data-explorer?query=SELECT%20%22post%22%20FROM%20%22kata%22.%22autogen%22.%22timeline%22%20WHERE%20time%20%3E%3D%20now%28%29%20-%207d%20GROUP%20BY%20%22user%22).
> All different timelines are stored into the same `timeline` measurement, indexed by the `user` tag.

#### Followers

##### Followers API
The information about "who-follows-who" is written (_following_ kata) and read (_wall_ kata) using a [Spring Boot](https://spring.io/projects/spring-boot) application with [Hibernate](https://hibernate.org/) and [JPA](https://spring.io/projects/spring-data-jpa)-based data repository access.
> No validation is performed against data, as we focus on the sunny day scenarios.

Exposed endpoints are (more than necessary, for test purposes):
- _posting_:
  `PUT` http://localhost:18080/api/v1/users text, example:
  ```
  Alice
  ```
- _following_:
  `PUT` http://localhost:18080/api/v1/users/Charlie text, example:
  ```
  Alice
  ```
- _wall_:
  `GET` http://localhost:18080/api/v1/users/Charlie
- _listing_:
  `GET` http://localhost:18080/api/v1/users

##### Followers DB
The information about "who-follows-who" is stored into a [PostgreSQL](https://www.postgresql.org/) relational database.
> The `user` entity "follows" other `user` entities in a _unidirectional many-to-many_ relationship.

##### Followers DB admin
The database is managed using [pgAdmin](https://www.pgadmin.org/).
> To view DB tables open
> **Servers > pgkata > Databases > kata > Schemas > public > Tables**

---
Made with ❤️ by [Fabio Michelini](https://www.linkedin.com/in/fabio-michelini/)
