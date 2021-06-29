defmodule MessengerBot.Models.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias MessengerBot.Repo
  require Logger

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "users" do
    field(:name, :string)
    field(:email, :string)
    field(:psid, :string)

    has_many(:review, MessengerBot.Models.Review, on_delete: :delete_all)

    timestamps()
  end

  def create(params) do
    %__MODULE__{}
    |> cast(params, [:name, :email, :psid])
    |> validate_required([:name, :email, :psid])
    |> unique_constraint(:psid, name: :users_psid_index, message: "Users must have unique psid")
    |> Repo.insert()
    |> case do
      {:ok, user} ->
        {:ok, user}

      {:error, changeset} ->
        Logger.warning("While creating user: #{inspect(changeset)}")
        {:error, changeset}
    end
  end

  def get_by_psid(psid) do
    Repo.get_by(__MODULE__, psid: psid)
  end
end
