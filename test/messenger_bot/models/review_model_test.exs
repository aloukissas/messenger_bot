defmodule MessengerBot.Models.ReviewTest do
  use MessengerBot.DataCase
  alias MessengerBot.Models.{User, Product, Review}

  setup do
    {:ok, user} = User.create(%{name: "Alice Bobby", email: "alice@bobby.com", psid: "qwerty"})
    {:ok, product} = Product.create(%{title: "Magic Wand", sku: "asdf"})

    %{user: user, product: product}
  end

  test "inserting a review works", %{user: user, product: product} do
    {:ok, review} = Review.create(user, product, %{csat: 4, review_text: "Awesome"})
    assert review.review_text == "Awesome"
    assert review.csat == 4
    assert review.user_id == user.id
    assert review.product_id == product.id
  end

  test "inserting a review without rating works", %{user: user, product: product} do
    {:ok, review} = Review.create(user, product, %{review_text: "Awesome"})
    assert review.review_text == "Awesome"
    assert is_nil(review.csat)
    assert review.user_id == user.id
    assert review.product_id == product.id
  end

  test "inserting a review without review_text fails", %{user: user, product: product} do
    {:error, changeset} = Review.create(user, product, %{csat: 4})
    refute changeset.valid?
    assert changeset.errors[:review_text]
  end
end
