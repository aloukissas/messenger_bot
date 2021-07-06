defmodule MessengerBot.Review do
  alias MessengerBot.{Repo, Client}
  alias MessengerBot.Models.{User, Review, Product, Order}
  require Logger

  @title_max_len 65
  @subtitle_max_len 80
  @button_title_max_len 20
  @placeholder_max_len 65
  @question_id_max_len 80

  def request_for_recent_order(%Order{status: "COMPLETED"} = order) do
    %Order{user: %User{psid: psid}, product: %Product{sku: sku, title: product_title}} =
      Repo.preload(order, [:user, :product])

    %{
      psid: psid,
      title: "How would you rate #{product_title}?",
      subtitle: "Let us know how you like #{product_title}.",
      button_title: "Rate this product",
      question_id: sku,
      placeholder: "Write your review"
    }
    |> mk_request_payload()
    |> send_request()
  end

  def request_with_thank_you_note(%Order{status: "COMPLETED"} = order) do
    %Order{user: %User{psid: psid}, product: %Product{sku: sku, title: product_title}} =
      Repo.preload(order, [:user, :product])

    %{
      psid: psid,
      title: "Thanks for buying #{product_title}!",
      subtitle: "Let us know how you like #{product_title}.",
      button_title: "Give us your review",
      question_id: sku,
      placeholder: "Your review"
    }
    |> mk_request_payload()
    |> send_request()
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

  defp mk_request_payload(%{
         psid: psid,
         title: title,
         subtitle: subtitle,
         button_title: button_title,
         question_id: question_id,
         placeholder: placeholder
       }) do
    if valid_param?(title, @title_max_len) and
         valid_param?(subtitle, @subtitle_max_len) and
         valid_param?(button_title, @button_title_max_len) and
         valid_param?(question_id, @question_id_max_len) and
         valid_param?(placeholder, @placeholder_max_len) do
      %{
        "recipient" => %{"id" => psid},
        "message" => %{
          "attachment" => %{
            "type" => "template",
            "payload" => %{
              "template_type" => "customer_feedback",
              "title" => title,
              "subtitle" => subtitle,
              "button_title" => button_title,
              "feedback_screens" => [
                %{
                  "questions" => [
                    %{
                      "id" => question_id,
                      "type" => "csat",
                      "score_label" => "none",
                      "score_option" => "five_stars",
                      "follow_up" => %{
                        "type" => "free_form",
                        "placeholder" => placeholder
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
    else
      raise ArgumentError, message: "Incorrect parameters"
    end
  end

  defp send_request(payload) do
    payload
    |> Client.do_post()
    |> case do
      {:ok, _} ->
        :ok

      err ->
        # TODO: perhaps put errored calls in a job queue (e.g. Oban) and selectively retry
        Logger.warning("Error sending customer_feedback message: #{inspect(err)}")
        err
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

  defp valid_param?(param, max_len) do
    String.length(param) <= max_len and !url?(param)
  end

  defp url?(term) do
    case URI.parse(term) do
      %URI{scheme: nil} -> false
      _ -> true
    end
  end
end
