defmodule MessengerBotWeb.WebhookController do
  use MessengerBotWeb, :controller
  require Logger

  @verify_token Application.fetch_env!(:messenger_bot, :facebook_api)[:verify_token]

  def get(conn, %{
        "hub.mode" => "subscribe",
        "hub.verify_token" => token,
        "hub.challenge" => challenge
      })
      when token == @verify_token do
    text(conn, challenge)
  end

  def get(conn, params) do
    Logger.warning("Invalid parameters: #{inspect(params)}")

    conn
    |> put_status(403)
    |> text("Forbidden")
  end

  def post(conn, %{"object" => "page", "entry" => entry}) do
    Logger.debug("Received #{inspect(entry)}")

    text(conn, "EVENT_RECEIVED")
  end

  def post(conn, _) do
    conn
    |> put_status(403)
    |> text("Forbidden")
  end
end
