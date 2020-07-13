Social Networking Kata
======================
This is an implementation of [the social networking kata](https://github.com/xpeppers/social_networking_kata) proposed by [_Xpeppers_](https://www.xpeppers.com/en/) team.

---

## Get started

To spin up the services and run the CLI:

1. make sure you have [Docker](https://docs.docker.com/get-docker/) 1.12.0 or higher,
5. clone the repo — follow [this guide](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository) if needed,
3. run the `kata` script (adding `demo` to run a _non-interactive_ session):
   - on **Windows**: `%SYSTEMDRIVE%:\path\to\the\repo\kata.cmd [demo]`
   - on **Linux**: `/path/to/the/repo/kata.sh [demo]`

The first run may take a few minutes...
meanwhile you can have a look at:
- [Architecture](#architecture)
- [CLI](#cli)
- [Services](#services)
- [Tests](#tests)
- [Example](#example)

When the CLI is ready you can type `help` to display available commands.
**Enjoy!**

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

## CLI

The _command line interface_ is implemented in [Bash](https://www.gnu.org/software/bash/) using [curl](https://curl.haxx.se/) and [jq](https://stedolan.github.io/jq/) to interact with the [API gateway](#api-gateway).

### CLI mode
You can edit the _CLI mode_,
it's the last line of the [/frontend/.env](/frontend/.env) file.
Available modes are:
- **`full`** - user data is managed by [services](#services)
- **`mono`** - user data is managed by the CLI itself, using the file system

### CLI help
If you type `help` in the CLI you'll see this:
```
kata commands:
  <user name> -> <message>           -> post message to user timeline
  <user name>                        -> read messages from user timeline
  <user name> follows <another user> -> subscribe user to another user timeline
  <user name> wall                   -> read messages from user timeline and subscriptions

utility commands:
  exit -> exit the cli
  help -> read this help
  kata -> read full readme of kata requirements
  mode -> tell if running in:
          - 'full' mode: attached to an API server which handles user data
          - 'mono' mode: handling user data using the file system

kata readme: https://github.com/xpeppers/social_networking_kata
```

---

## Services
Once the services are up and running, you can **[inspect]** them.

You can find the **credentials** in the [/backend/.env](/backend/.env) file.

- [API gateway](#api-gateway)
  [**[inspect]**](http://localhost:11881/)
- [Timelines](#timelines)
  - [API](#timelines-api)
    [**[inspect]**](http://localhost:11888/)
  - [DB](#timelines-db)
  - [DB admin](#timelines-db-admin)
    [**[inspect]**](http://localhost:18888/)
- [Followers](#followers)
  - [API](#followers-api)
    [**[inspect]**](http://localhost:18080/api/v1/users)
  - [DB](#followers-db)
  - [DB admin](#followers-db-admin)
    [**[inspect]**](http://localhost:15050/)

### API gateway
The API gateway exposes the **4 kata requirements** using [Node-RED](https://nodered.org/) with [JSONata](https://jsonata.org/):
- _posting_
  **POST** http://localhost:11881/posting?user=Alice `Hi!`
  routes to **timelines** _posting_
- _reading_
  **GET** http://localhost:11881/reading?user=Alice
  routes to **timelines** _reading_
- _following_
  **PUT** http://localhost:11881/following?user=Charlie `Alice`
  routes to **followers** _following_
- _wall_
  **GET** http://localhost:11881/wall?user=Charlie composes
  **followers** _following_ **+**
  **timelines** _reading_

### Timelines

#### Timelines API
Users timelines are written (_posting_ kata) and read (_reading_ and _wall_ kata) using [Node-RED](https://nodered.org/) with [JSONata](https://jsonata.org/).

Exposed endpoints are:
- _reading_/_wall_
  **GET** http://localhost:11888/api/v1/reading?users=Alice,Bob,Charlie
  > Only last 50 posts within last week are returned for each user
- _posting_
  **POST** http://localhost:11888/api/v1/posting
  `{"user":"Alice","text":"Hi!"}`
- _testing_
  **GET** http://localhost:11888/api/v1/test
  returns `200` if passed or `418` if failed

#### Timelines DB
Users posts are stored into a _time serie_ using [InfluxDB](https://www.influxdata.com/products/influxDB-overview/), with `infinite` _retention policy_ and `1s` _precision_.

#### Timelines DB admin
The _time serie_ database server is managed using [Chronograf](https://www.influxdata.com/time-series-platform/chronograf/). You can query the timelines [here](http://localhost:18888/sources/0/chronograf/data-explorer?query=SELECT%20%22post%22%20FROM%20%22kata%22.%22autogen%22.%22timeline%22%20WHERE%20time%20%3E%3D%20now%28%29%20-%207d%20GROUP%20BY%20%22user%22).
All different timelines are stored into the same `timeline` _measurement_, indexed by the `user` _tag_.

### Followers

#### Followers API
The information about "who-follows-who" is written (_following_ kata) and read (_wall_ kata) using a [Spring Boot](https://spring.io/projects/spring-boot) application with [Hibernate](https://hibernate.org/) and [JPA](https://spring.io/projects/spring-data-jpa)-based data repository access.

Exposed endpoints are (more than necessary, for test purposes):
- _posting_
  **PUT** http://localhost:18080/api/v1/users `Alice`
  > No validation is performed against data, as we focus on the sunny day scenarios.
- _following_
  **PUT** http://localhost:18080/api/v1/users/Charlie `Alice`
  > Everyone can follow anyone: users are addedd if missing.
- _wall_
  **GET** http://localhost:18080/api/v1/users/Charlie
- _listing_
  **GET** http://localhost:18080/api/v1/users

#### Followers DB
The information about "who-follows-who" is stored into a [PostgreSQL](https://www.postgresql.org/) relational database.
The **user** entity "follows" other **user** entities in an _unidirectional many-to-many_ relationship.

#### Followers DB admin
The database is managed using [pgAdmin](https://www.pgadmin.org/).
>To view DB tables open
**Servers > pgkata > Databases > kata > Schemas > public > Tables**

---

## Tests

- Have a look to [these examples](/backend/java/src/test/java/it/mamosk/kata/apisocial)
  of simple _unit tests_.
- Import [this collection](/postman/kata.postman_collection.json)
  in [Postman](https://www.postman.com/)
  to run _functional_ and _integration_ tests.

---

## Example

This is the output of a `demo` run:
```
> Alice -> I love the weather today
> Bob -> Damn! We lost!
> Bob -> Good game though.
> Alice
> Alice - I love the weather today (5 seconds ago)
> Bob
> Bob - Good game though. (4 seconds ago)
> Bob - Damn! We lost! (6 seconds ago)
> Charlie -> I'm in New York today! Anyone wants to have a coffee?
> Charlie follows Alice
> Charlie wall
> Charlie - I'm in New York today! Anyone wants to have a coffee? (4 seconds ago)
> Bob - Good game though. (11 seconds ago)
> Bob - Damn! We lost! (13 seconds ago)
> Alice - I love the weather today (14 seconds ago)
> Charlie follows Bob
> Charlie wall
> Charlie - I'm in New York today! Anyone wants to have a coffee? (7 seconds ago)
> Bob - Good game though. (14 seconds ago)
> Bob - Damn! We lost! (16 seconds ago)
> Alice - I love the weather today (17 seconds ago)
```

---
Made with ❤️ by [Fabio Michelini](https://www.linkedin.com/in/fabio-michelini/)
