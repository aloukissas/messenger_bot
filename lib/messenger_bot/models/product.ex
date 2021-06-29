defmodule MessengerBot.Models.Product do
  use Ecto.Schema
  import Ecto.Changeset
  alias MessengerBot.Repo
  require Logger

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "products" do
    field(:title, :string)
    field(:description, :string)
    field(:sku, :string)

    has_many(:review, MessengerBot.Models.Review, on_delete: :delete_all)

    timestamps()
  end

  def create(params) do
    %__MODULE__{}
    |> cast(params, [:title, :description, :sku])
    |> validate_required([:title, :sku])
    |> unique_constraint(:sku, name: :products_sku_index, message: "Products must have unique SKU")
    |> Repo.insert()
    |> case do
      {:ok, product} ->
        {:ok, product}

      {:error, changeset} ->
        Logger.warning("While inserting product: #{inspect(changeset)}")
        {:error, changeset}
    end
  end

  def get_by_sku(sku) do
    Repo.get_by(__MODULE__, sku: sku)
  end
end
