defmodule MessengerBot.ReviewTest do
  use MessengerBot.DataCase
  alias MessengerBot.Models.{User, Product, Order}
  alias MessengerBot.{Review, Repo}

  @api_version Application.fetch_env!(:messenger_bot, :facebook_api)[:version]

  @response %{
    "recipient_id" => "1008372609250235",
    "message_id" =>
      "m_AG5Hz2Uq7tuwNEhXfYYKj8mJEM_QPpz5jdCK48PnKAjSdjfipqxqMvK8ma6AC8fplwlqLP_5cgXIbu7I3rBN0P"
  }

  setup do
    bypass = Bypass.open()

    new =
      Application.get_env(:messenger_bot, :facebook_api)
      |> Keyword.put(:base_url, "http://localhost:#{bypass.port}")

    Application.put_env(:messenger_bot, :facebook_api, new)

    {:ok, user} = User.create(%{name: "Alice Bobby", email: "alice@bobby.com", psid: "qwerty"})
    {:ok, product} = Product.create(%{title: "Magic Wand", sku: "asdf"})
    {:ok, order} = Order.create(user, product, %{price_cents: 100})

    %{bypass: bypass, user: user, product: product, order: order}
  end

  test "request review for recently completed order", %{order: order, bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/#{@api_version}/me/messages", fn conn ->
      Plug.Conn.resp(conn, 200, Jason.encode!(@response))
    end)

    {:ok, order} = Order.mark_completed(%Order{order | status: "IN_PROGRESS"})

    Review.request_for_recent_order(order)
  end

  test "process callback works", %{user: user, product: product} do
    csat = 5
    review_text = "Awesome!"
    payload = mk_feedback_payload(user.psid, product.sku, csat, review_text)

    :ok = Review.process_callback(payload)

    product = product.sku |> Product.get_by_sku() |> Repo.preload(:review)
    assert length(product.review) == 1
    review = List.first(product.review)
    assert review.csat == csat
    assert review.review_text == review_text
  end

  defp mk_feedback_payload(psid, sku, csat, review_text) do
    %{
      "sender" => %{
        "id" => psid
      },
      "recipient" => %{
        "id" => "page_id"
      },
      "messaging_feedback" => %{
        "feedback_screens" => [
          %{
            "screen_id" => 0,
            "questions" =>
              Map.put_new(%{}, sku, %{
                "type" => "csat",
                "payload" => csat,
                "follow_up" => %{
                  "type" => "free_form",
                  "payload" => review_text
                }
              })
          }
        ]
      }
    }
  end
end
