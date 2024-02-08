# =========================================
# Makes it possible to run "make aaa bbb" instead of make aaa ARGS="bbb"
ARGS = $(filter-out $@,$(MAKECMDGOALS))
%:
@:
# =========================================
#
setup:
	cp -n .env.example .env || true
	mix setup

test:
	mix test $(ARGS)

format:
	mix format

lint:
	mix credo
check-types:
	mix dialyzer

server:
	iex -S mix phx.server

console:
	iex -S mix

start-services:
	docker compose up -d postgres

stop-services:
	docker compose stop postgres

start-compose:
	docker compose up
stop-compose:
	docker compose stop
audit:
	mix deps.audit

security:
	mix sobelow --config

ci: audit security lint

db-migrate:
	mix ecto.migrate
	mix ecto.dump
db-reset:
	mix ecto.reset
	MIX_ENV=test mix ecto.reset

tag:
	git tag $(TAG) && git push --tags
.PHONY: test

