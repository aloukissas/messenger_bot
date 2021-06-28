defmodule MessengerBotWeb.PageController do
  use MessengerBotWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
