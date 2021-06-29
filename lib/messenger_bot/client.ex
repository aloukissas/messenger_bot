defmodule MessengerBot.Client do
  use Tesla, only: [:get, :post]

  plug Tesla.Middleware.BaseUrl, Application.fetch_env!(:messenger_bot, :facebook_api)[:base_url]

  plug Tesla.Middleware.Query,
    access_token: Application.fetch_env!(:messenger_bot, :facebook_api)[:access_token]

  @api_version Application.fetch_env!(:messenger_bot, :facebook_api)[:version]

  def do_post(body) do
    full_path()
    |> post(Jason.encode!(body))
    |> process_result()
  end

  defp full_path() do
    "/#{@api_version}/me/messages"
  end

  defp process_result({:ok, %{body: body}}) do
    body
    |> Jason.decode!()
    |> case do
      %{"error" => %{"code" => 619}} -> {:error, :rate_limited}
      %{"error" => %{"message" => message}} -> {:error, message}
      body -> {:ok, body}
    end
  end

  defp process_result({:error, _} = err) do
    err
  end
end
