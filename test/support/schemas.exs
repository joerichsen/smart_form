defmodule SmartForm.User do
  @moduledoc false

  use Ecto.Schema

  schema "users" do
    field :firstname, :string
    field :birthday, :date
  end
end

defmodule SmartForm.Book do
  @moduledoc false

  use Ecto.Schema

  schema "books" do
    field :title, :string
    field :author, :string
    field :price_cents, :integer
    field :price_currency, :string
    has_many :chapters, SmartForm.Chapter
  end
end

defmodule SmartForm.Chapter do
  @moduledoc false

  use Ecto.Schema

  schema "chapters" do
    field :title, :string
    field :content, :string
    belongs_to :book, SmartForm.Book
  end
end
