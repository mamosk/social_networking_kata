Social Networking Kata
======================
This is an implementation of [the social networking kata](https://github.com/xpeppers/social_networking_kata) proposed by [_Xpeppers_](https://www.xpeppers.com/en/) team.

This kata is implemented using:
- [Docker](https://www.docker.com/)
- [PostgreSQL](https://www.postgresql.org/) 
- [InfluxDB](https://www.influxdata.com/products/influxDB-overview/)
- [Bash](https://www.gnu.org/software/bash/)
  - [curl](https://curl.haxx.se/)
  - [jq](https://stedolan.github.io/jq/)
- [HTML](https://www.w3.org/html/) + [CSS](https://www.w3.org/Style/CSS/)
- [JavaScript](https://www.ecma-international.org/publications/standards/Ecma-262.htm)
  - [React](https://reactjs.org/)
  - [Node-RED](https://nodered.org/)
    - [JSONata](https://jsonata.org/)
- [Java](https://www.java.com/)
  - [Lombok](https://projectlombok.org/)
  - [Spring Boot](https://spring.io/projects/spring-boot)
  - [JPA](https://spring.io/projects/spring-data-jpa)
    - [Hibernate](http://hibernate.org/)

---

## Get started

This kata runs in two modes:
- [**mono**](#mono-mode) is the _quick as a snake, quiet as a shadow_ way:
  - a single script does everything
  - data is managed directly on the file system
- [**full**](#full-mode) is the _calm like a giant tree in a storm_ way:
  - some services work together to get the things done
  - data is managed in distinct locations:
    - _timelines_ in a [time series database](https://en.wikipedia.org/wiki/Time_series_database)
    - _followers_ in an [object database](https://en.wikipedia.org/wiki/Object_database)

When the [CLI](#cli) is ready you can type `help` to display available commands.
**Enjoy!**

### Mono mode

To execute the script in **mono** mode:

1. clone the repo — follow [this guide](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository)
   - on **Windows** you'll have to [changle the end of line sequence](https://webstoked.com/vs-code-fix-end-of-line-character-is-invalid/#:~:text=Click%20on%20the%20CRLF%20button,see%20in%20the%20second%20step.&text=Click%20on%20LF%20at%20the,That's%20it!)
     from `CRLF` to `LF` in following files:
     - [/frontend/bash/katacli.sh](/frontend/bash/katacli.sh)
     - [/frontend/bash/demo/kata.demo](/frontend/bash/demo/kata.demo)
1. run the `kataq` command (adding `demo` to run a _non-interactive_ session):
   - on **Windows**: `%SYSTEMDRIVE%:\path\to\the\repo\kataq.cmd [demo]`
   - on **Linux**: `/path/to/the/repo/kataq.sh [demo]`

### Full mode

To spin up the services in **full** mode:

1. make sure you have [Docker](https://docs.docker.com/get-docker/) 1.12.0 or higher
1. clone the repo — follow [this guide](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository)
   - on **Windows** you'll have to [change the end of line sequence](https://webstoked.com/vs-code-fix-end-of-line-character-is-invalid/#:~:text=Click%20on%20the%20CRLF%20button,see%20in%20the%20second%20step.&text=Click%20on%20LF%20at%20the,That's%20it!)
     from `CRLF` to `LF` in following files:
     - [/frontend/bash/katacli.sh](/frontend/bash/katacli.sh)
     - [/frontend/bash/demo/kata.demo](/frontend/bash/demo/kata.demo)
1. run the `kata` command (adding `demo` to run a _non-interactive_ session):
   - on **Windows**: `%SYSTEMDRIVE%:\path\to\the\repo\kata.cmd [demo]`
   - on **Linux**: `/path/to/the/repo/kata.sh [demo]`

The first run may take a few minutes...
meanwhile you can have a look at:
- [Architecture](#architecture)
- [Frontend](#frontend)
- [Backend](#backend)
- [Tests](#tests)
- [Example](#example)

---

## Architecture
>```
>                         Timelines API ---- Timelines DB ---- Timelines DB admin
>                       /               \                    /
>                      /                 \                  /
>CLI ---- API gateway <                   >---- Web UI ----<
>                      \                 /                  \
>                       \               /                    \
>                         Followers API ---- Followers DB ---- Timelines DB admin
>```

---

## Frontend

Frontend _user interfaces_ include:
- a [CLI](#cli) as required by the kata
- a [Web UI](#web-ui) to inspect [services](#backend)

### CLI

The _command line interface_ is implemented in [Bash](https://www.gnu.org/software/bash/) using [curl](https://curl.haxx.se/) and [jq](https://stedolan.github.io/jq/) to interact with the [API gateway](#api-gateway) when running in [full mode](#full-mode).

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

This is the output of a **demo** run:
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
> Alice - I love the weather today (14 seconds ago)
> Charlie follows Bob
> Charlie wall
> Charlie - I'm in New York today! Anyone wants to have a coffee? (7 seconds ago)
> Bob - Good game though. (14 seconds ago)
> Bob - Damn! We lost! (16 seconds ago)
> Alice - I love the weather today (17 seconds ago)
```

### Web UI

The _web user interface_ is implemented in
[HTML](https://www.w3.org/html/),
[CSS](https://www.w3.org/Style/CSS/) and
[JavaScript](https://www.ecma-international.org/publications/standards/Ecma-262.htm) using
[React](https://reactjs.org/).

When the [CLI](#cli) is ready you can open
the web UI [**here**](http://localhost:13000/)
to inspect services.

---

## Backend
Once the backend services are up and running, you can **[inspect]** them.

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
  > Only last 50 posts within last week are returned for each user.
- _posting_
  **POST** http://localhost:11888/api/v1/posting
  `{"user":"Alice","text":"Hi!"}`
- _testing_
  **GET** http://localhost:11888/api/v1/test
  returns `200` if passed or `418` if failed

#### Timelines DB
Users posts are stored into a _time serie_ using [InfluxDB](https://www.influxdata.com/products/influxDB-overview/), with `infinite` _retention policy_ and `1s` _precision_.

#### Timelines DB admin
The _time series_ database server is managed using [Chronograf](https://www.influxdata.com/time-series-platform/chronograf/).
You can query the timelines [here](http://localhost:18888/sources/0/chronograf/data-explorer?query=SELECT%20%22post%22%20FROM%20%22kata%22.%22autogen%22.%22timeline%22%20WHERE%20time%20%3E%3D%20now%28%29%20-%207d%20GROUP%20BY%20%22user%22).

All different timelines are stored into the same `timeline` _measurement_, indexed by the `user` _tag_.

### Followers

#### Followers API
The information about "who-follows-who" is written (_following_ kata) and read (_wall_ kata) using a [Spring Boot](https://spring.io/projects/spring-boot) application with [Lombok](https://projectlombok.org/) and [JPA](https://spring.io/projects/spring-data-jpa).

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
The information about "who-follows-who" is stored into a [PostgreSQL](https://www.postgresql.org/) database.

The **user** entity "follows" other **user** entities in an _unidirectional many-to-many_ relationship.

#### Followers DB admin
The database is managed using [pgAdmin](https://www.pgadmin.org/).
>To view DB tables open
**Servers > pgkata > Databases > kata > Schemas > public > Tables**

---

## Tests

- Take a look at [these examples](/backend/java/src/test/java/it/mamosk/kata/apisocial)
  of simple _unit tests_.
- Import [this collection](/backend/postman/kata.postman_collection.json)
  in [Postman](https://www.postman.com/)
  to run _functional_ and _integration_ tests.

---
Made with ❤️ by [Fabio Michelini](https://www.linkedin.com/in/fabio-michelini/)
