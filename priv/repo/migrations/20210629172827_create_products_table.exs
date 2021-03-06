defmodule MessengerBot.Repo.Migrations.CreateProductsTable do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:title, :string)
      add(:description, :string)
      add(:sku, :string)

      timestamps()
    end

    create(unique_index(:products, [:sku]))
  end
end
