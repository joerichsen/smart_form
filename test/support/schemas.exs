defmodule SmartForm.User do
  @moduledoc false

  use Ecto.Schema

  schema "users" do
    field :firstname, :string
    field :birthday, :date
  end
end
