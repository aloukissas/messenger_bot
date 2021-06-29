defmodule MessengerBot.Models.Review do
  use Ecto.Schema
  import Ecto.Changeset
  alias MessengerBot.Repo
  alias MessengerBot.Models.{User, Product}
  require Logger

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "reviews" do
    field(:csat, :integer)
    field(:review_text, :string)
    belongs_to(:user, User, type: :binary_id)
    belongs_to(:product, Product, type: :binary_id)

    timestamps()
  end

  def create(%User{} = user, %Product{} = product, params) do
    %__MODULE__{}
    |> cast(params, [:csat, :review_text])
    |> validate_required([:review_text])
    |> put_assoc(:user, user)
    |> put_assoc(:product, product)
    |> Repo.insert()
    |> case do
      {:ok, review} ->
        {:ok, review}

      {:error, changeset} ->
        Logger.warning("While inserting review: #{inspect(changeset)}")
        {:error, changeset}
    end
  end
end
