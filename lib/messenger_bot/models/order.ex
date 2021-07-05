defmodule MessengerBot.Models.Order do
  use Ecto.Schema
  import Ecto.Changeset
  alias MessengerBot.Repo
  alias MessengerBot.Models.{User, Product}
  require Logger

  @primary_key {:id, :binary_id, autogenerate: true}
  @valid_status_values [created: "CREATED", in_progress: "IN_PROGRESS", completed: "COMPLETED"]

  schema "orders" do
    field(:price_cents, :integer)
    field(:status, :string, default: @valid_status_values[:created])
    belongs_to(:user, User, type: :binary_id)
    belongs_to(:product, Product, type: :binary_id)

    timestamps()
  end

  def create(%User{} = user, %Product{} = product, params) do
    %__MODULE__{}
    |> cast(params, [:price_cents])
    |> validate_required([:price_cents])
    |> put_assoc(:user, user)
    |> put_assoc(:product, product)
    |> Repo.insert()
    |> case do
      {:ok, order} ->
        {:ok, order}

      {:error, changeset} ->
        Logger.warning("While inserting order: #{inspect(changeset)}")
        {:error, changeset}
    end
  end

  def mark_in_progress(%__MODULE__{id: id, status: "CREATED"} = order) do
    order
    |> change(status: @valid_status_values[:in_progress])
    |> Repo.update()
    |> case do
      {:ok, order} ->
        {:ok, order}

      {:error, changeset} ->
        Logger.warning("While marking order id=#{id} in_progress: #{inspect(changeset)}")
        {:error, changeset}
    end
  end

  def mark_completed(%__MODULE__{id: id, status: "IN_PROGRESS"} = order) do
    order
    |> change(status: @valid_status_values[:completed])
    |> Repo.update()
    |> case do
      {:ok, order} ->
        {:ok, order}

      {:error, changeset} ->
        Logger.warning("While marking order id=#{id} completed: #{inspect(changeset)}")
        {:error, changeset}
    end
  end
end
