defmodule MessengerBotWeb.WebhookControllerText do
  use MessengerBotWeb.ConnCase

  @verify_token Application.fetch_env!(:messenger_bot, :facebook_api)[:verify_token]

  test "verify webhook endpoint works", %{conn: conn} do
    challenge = "foobar"

    conn =
      get(conn, "/webhook", %{
        "hub.mode" => "subscribe",
        "hub.verify_token" => @verify_token,
        "hub.challenge" => challenge
      })

    assert text_response(conn, 200) == challenge
  end

  test "verify webhook endpoint with bad params fails correctly", %{conn: conn} do
    challenge = "foobar"

    conn =
      get(conn, "/webhook", %{
        "hub.mode" => "random_mode",
        "hub.verify_token" => @verify_token,
        "hub.challenge" => challenge
      })

    assert text_response(conn, 403) == "Forbidden"

    conn =
      get(conn, "/webhook", %{
        "hub.mode" => "subscribe",
        "hub.verify_token" => "random_token",
        "hub.challenge" => challenge
      })

    assert text_response(conn, 403) == "Forbidden"
  end

  test "webhook endpoint works", %{conn: conn} do
    conn = post(conn, "/webhook", %{"object" => "page", "entry" => "foo"})
    assert text_response(conn, 200) == "EVENT_RECEIVED"
  end

  test "webhook endpoint with bad params fails correctly", %{conn: conn} do
    conn = post(conn, "/webhook", %{"object" => "foo", "entry" => "foo"})
    assert text_response(conn, 403) == "Forbidden"
  end
end
