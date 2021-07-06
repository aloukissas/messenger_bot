# MessengerBot

To start your Phoenix server (assumes you have a local PostgreSQL running):

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

To start using Docker:

  * Run `docker-compose up --build`
  * Get a CLI into the `web` image
  * Run `/app/bin/server remote` to get a REPL
  * Execute `MessengerBot.Release.migrate` in the REPL to run migrations

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
In this example, this will return an error page. The app only exposes the two
webhook endpoints required (`GET/POST http://localhost:4000/webhook`).
