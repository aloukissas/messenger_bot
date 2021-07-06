defmodule MessengerBot.Models.OrderTest do
  use MessengerBot.DataCase
  alias MessengerBot.Models.{User, Product, Order}

  setup do
    {:ok, user} = User.create(%{name: "Alice Bobby", email: "alice@bobby.com", psid: "qwerty"})
    {:ok, product} = Product.create(%{title: "Magic Wand", sku: "asdf"})

    %{user: user, product: product}
  end

  test "creating an order works", %{user: user, product: product} do
    {:ok, order} = Order.create(user, product, %{price_cents: 100})
    assert order.price_cents == 100
    assert order.status == "CREATED"
    assert order.user_id == user.id
    assert order.product_id == product.id
  end

  test "creating an order without price_cents fails", %{user: user, product: product} do
    {:error, changeset} = Order.create(user, product, %{})
    refute changeset.valid?
    assert changeset.errors[:price_cents]
  end

  test "marking order in progress works", %{user: user, product: product} do
    {:ok, order} = Order.create(user, product, %{price_cents: 100})
    assert order.price_cents == 100
    assert order.status == "CREATED"

    {:ok, order} = Order.mark_in_progress(order)
    assert order.status == "IN_PROGRESS"
  end

  test "marking order completed works", %{user: user, product: product} do
    {:ok, order} = Order.create(user, product, %{price_cents: 100})
    assert order.price_cents == 100
    assert order.status == "CREATED"

    {:ok, order} = Order.mark_completed(%Order{order | status: "IN_PROGRESS"})
    assert order.status == "COMPLETED"
  end
end
