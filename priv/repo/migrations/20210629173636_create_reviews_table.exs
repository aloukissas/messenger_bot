defmodule MessengerBot.Repo.Migrations.CreateReviewsTable do
  use Ecto.Migration

  def change do
    create table(:reviews, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:user_id, references(:users, type: :binary_id))
      add(:product_id, references(:products, type: :binary_id))
      add(:csat, :integer)
      add(:review_text, :string)

      timestamps()
    end
  end
end
