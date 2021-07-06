defmodule MessengerBot.Review do
  alias MessengerBot.{Repo, Client}
  alias MessengerBot.Models.{User, Review, Product, Order}
  require Logger

  def request(%Order{status: "COMPLETED"} = order) do
    %Order{user: %User{psid: psid}, product: %Product{sku: sku, title: product_title}} =
      Repo.preload(order, [:user, :product])

    %{
      "recipient" => %{"id" => psid},
      "message" => %{
        "attachment" => %{
          "type" => "template",
          "payload" => %{
            "template_type" => "customer_feedback",
            "title" => "How would you rate #{product_title}?",
            "subtitle" =>
              "Let us know how you like #{product_title} by answering a couple questions.",
            "button_title" => "Rate this product",
            "feedback_screens" => [
              %{
                "questions" => [
                  %{
                    "id" => sku,
                    "type" => "csat",
                    "score_label" => "none",
                    "score_option" => "five_stars",
                    "follow_up" => %{
                      "type" => "free_form",
                      "placeholder" => "Write your review"
                    }
                  }
                ]
              }
            ],
            "business_privacy" => %{
              "url" => "https://www.example.com"
            },
            "expires_in_days" => 3
          }
        }
      }
    }
    |> Client.do_post()
    |> case do
      {:ok, _} ->
        :ok

      err ->
        Logger.warning("Error sending customer_feedback message: #{inspect(err)}")
        err
    end
  end

  def request(%Order{id: id}) do
    Logger.warning("Tried to request review for non-completed order id=#{id}")
    {:error, :order_not_completed}
  end

  def process_callback(%{
        "sender" => %{"id" => psid},
        "messaging_feedback" => %{"feedback_screens" => [feedback_screen]}
      }) do
    with %User{id: id} = user <- User.get_by_psid(psid) do
      questions = Map.fetch!(feedback_screen, "questions")

      questions
      |> Map.keys()
      |> Enum.each(fn sku ->
        Logger.debug("Processing feedback from user id=#{id} for sku=#{sku}")
        store_review(user, sku, Map.fetch!(questions, sku))
      end)

      :ok
    else
      nil ->
        Logger.warning("Received feedback for unknown user id=#{psid}")
        :error
    end
  end

  defp store_review(%User{} = user, sku, %{
         "type" => "csat",
         "payload" => csat,
         "follow_up" => %{
           "type" => "free_form",
           "payload" => review_text
         }
       }) do
    with %Product{} = product <- Product.get_by_sku(sku) do
      Review.create(user, product, %{csat: csat, review_text: review_text})
    else
      nil ->
        Logger.warning("Received feedback for unknown sku=#{sku}")
    end
  end
end
