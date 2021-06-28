defmodule MessengerBot.Repo do
  use Ecto.Repo,
    otp_app: :messenger_bot,
    adapter: Ecto.Adapters.Postgres
end
