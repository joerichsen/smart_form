defmodule SmartForm.Migrations do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:users) do
      add(:firstname, :string)
      add(:birthday, :date)
    end

    create table(:books) do
      add(:title, :string)
      add(:author, :string)
      add(:price_cents, :integer)
      add(:price_currency, :string)
    end
  end
end
