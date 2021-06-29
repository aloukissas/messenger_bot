defmodule MessengerBot.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string)
      add(:email, :string)
      add(:psid, :string)

      timestamps()
    end

    create(unique_index(:users, [:psid]))
  end
end
