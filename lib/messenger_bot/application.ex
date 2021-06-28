defmodule MessengerBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      MessengerBot.Repo,
      # Start the Telemetry supervisor
      MessengerBotWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MessengerBot.PubSub},
      # Start the Endpoint (http/https)
      MessengerBotWeb.Endpoint
      # Start a worker by calling: MessengerBot.Worker.start_link(arg)
      # {MessengerBot.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MessengerBot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MessengerBotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
