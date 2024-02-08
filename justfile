recipe-name:
  echo 'This is a recipe!'

server
  iex -S mix phx.server

start-services:
  docker compose up -d

stop-services:
  docker compose stop
db-reset:
  mix ecto.reset
# this is a comment
test:
  mix test
