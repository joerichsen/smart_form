defmodule FieldsForTest do
  use SmartForm.DataCase
  doctest SmartForm

  alias SmartForm.Book

  defmodule ValidateBookForm do
    use SmartForm

    smart_form do
      field :title, :string, required: true

      fields_for :chapters do
        field :title, :string, required: true
      end
    end
  end

  describe "validating the nested fields" do
    test "should return true if the form is valid" do
      book = %Book{}

      form =
        ValidateBookForm.new(book)
        |> ValidateBookForm.validate(%{
          "title" => "It",
          "chapters" => [%{"title" => "Chapter 1"}, %{"title" => "Chapter 2"}]
        })

      assert form.valid? == true
    end

    test "should return false if the form is invalid" do
      book = %Book{}

      form =
        ValidateBookForm.new(book)
        |> ValidateBookForm.validate(%{
          "title" => "It",
          "chapters" => [%{content: "Once upon a time..."}]
        })

      refute form.valid?
    end
  end

  describe "changeset" do
    test "should return a changeset applied to the source that can be inserted in the database" do
      book = %Book{}

      form =
        ValidateBookForm.new(book)
        |> ValidateBookForm.validate(%{
          "title" => "It",
          "chapters" => [%{"title" => "Chapter 1"}, %{"title" => "Chapter 2"}]
        })
        |> ValidateBookForm.changeset()

      book = TestRepo.insert!(changeset)

      repo_book = TestRepo.get(Book, book.id)
      assert repo_book.title == "It"
      assert length(repo_book.chapters) == 2
      assert Enum.at(repo_book.chapters, 0).title == "Chapter 1"
      assert Enum.at(repo_book.chapters, 1).title == "Chapter 2"
    end
  end
end
