![sentinel logo](./logo.webp)

# Sentinel

Open-source alternative of hyperping

## Requirements

- docker-compose ~> 3
- elixir ~> 1.16
- erlang ~> 26.2
- PostgreSQL ~> 14
- make/just(modern alternative of make)

## Installation

Clone repo

```sh
git clone git@github.com:NikitaNaumenko/sentinel.git
cd sentinel
```

Start services

```sh
make start-services
# or
just start-services
```

Setup app

```sh
make setup
# or
just setup
```

Start app

```sh
make server
# or
just server
```

Stop services

```sh
make stop-services
# or
just stop-services
```

Reset db

```sh
make db-reset
# or
just db-reset
```

Run console

```sh
make console
# or
just console
```

Run test

```sh
make test
# or
just test
```

Run lint

```sh
make lint
# or
just lint
```

Run format

```sh
make format
# or
just format
```
