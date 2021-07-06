defmodule MessengerBot.ClientTest do
  use ExUnit.Case

  alias MessengerBot.Client

  @api_version Application.fetch_env!(:messenger_bot, :facebook_api)[:version]
  @test_message %{
    "messaging_type" => "UPDATE",
    "recipient" => %{"id" => "foobar"},
    "message" => %{"text" => "hello, world!"}
  }
  @response %{
    "recipient_id" => "1008372609250235",
    "message_id" =>
      "m_AG5Hz2Uq7tuwNEhXfYYKj8mJEM_QPpz5jdCK48PnKAjSdjfipqxqMvK8ma6AC8fplwlqLP_5cgXIbu7I3rBN0P"
  }
  @rate_limit_response %{
    "error" => %{
      "message" => "Calls to this API have exceeded the rate limit",
      "code" => 619
    }
  }
  @no_matching_user_response %{
    "error" => %{
      "message" => "No matching user found",
      "code" => 100,
      "subcode" => 2_018_001
    }
  }

  defp expect_response(bypass, response, status \\ 200) do
    Bypass.expect_once(bypass, "POST", "/#{@api_version}/me/messages", fn conn ->
      Plug.Conn.resp(conn, status, Jason.encode!(response))
    end)
  end

  setup do
    bypass = Bypass.open()

    new =
      Application.get_env(:messenger_bot, :facebook_api)
      |> Keyword.put(:base_url, "http://localhost:#{bypass.port}")

    Application.put_env(:messenger_bot, :facebook_api, new)

    {:ok, bypass: bypass}
  end

  test "send message works", %{bypass: bypass} do
    expect_response(bypass, @response)

    assert {:ok, resp} = Client.do_post(@test_message)
    assert resp == @response
  end

  test "rate limiting returns error", %{bypass: bypass} do
    expect_response(bypass, @rate_limit_response, 429)

    assert {:error, :rate_limited} = Client.do_post(@test_message)
  end

  test "generic error returns message", %{bypass: bypass} do
    expect_response(bypass, @no_matching_user_response, 400)

    assert {:error, error} = Client.do_post(@test_message)
    assert error == @no_matching_user_response["error"]["message"]
  end
end
