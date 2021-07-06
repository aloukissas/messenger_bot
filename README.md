# MessengerBot

## Running locally

To start your Phoenix server (assumes you have a local PostgreSQL running):

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

This will start a `dev` configuration server by default.

To start using Docker:

  * Run `docker-compose up --build`
  * Get a CLI into the `web` image
  * Run `/app/bin/server remote` to get a REPL
  * Execute `MessengerBot.Release.migrate` in the REPL to run migrations

This will start a `prod` configuration server by default.

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
In this example, this will return an error page. The app only exposes the two
webhook endpoints required (`GET/POST http://localhost:4000/webhook`).

## Deploying to a PaaS

Couple of options that work out of the box:

  * [Deploying on Heroku](https://hexdocs.pm/phoenix/heroku.html)
  * [Deploying on Gigalixir](https://hexdocs.pm/phoenix/gigalixir.html)
  * [Deploying on Render (unofficial guide)](https://dev.to/mrmurphy/deploying-elixir-to-render-com-1oja)
