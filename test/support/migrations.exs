defmodule SmartForm.Migrations do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:users) do
      add(:firstname, :string)
    end
  end
end
