defmodule MessengerBot.Repo.Migrations.CreateOrdersTable do
  use Ecto.Migration

  def change do
    create table(:orders, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:user_id, references(:users, type: :binary_id))
      add(:product_id, references(:products, type: :binary_id))
      add(:price_cents, :integer)
      add(:status, :string)

      timestamps()
    end
  end
end
