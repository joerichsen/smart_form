defmodule FilteringTest do
  use SmartForm.DataCase
  doctest SmartForm

  alias SmartForm.Book

  describe "filtering" do
    defmodule FilteringForm do
      use SmartForm

      form do
        field :title, :string, required: true
      end
    end

    test "it should not change the fields not found in the form" do
      book = %Book{title: "The Hobbit", author: "J.R.R. Tolkien"}

      book = book |> TestRepo.insert!()

      changeset =
        FilteringForm.new(book)
        |> FilteringForm.validate(%{
          "title" => "The Lord of the Rings",
          "author" => "Stephen King"
        })
        |> FilteringForm.changeset()

      TestRepo.update!(changeset)

      assert TestRepo.get(Book, book.id).title == "The Lord of the Rings"
      assert TestRepo.get(Book, book.id).author == "J.R.R. Tolkien"
    end
  end
end
