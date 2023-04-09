defmodule FieldsForTest do
  use SmartForm.DataCase
  doctest SmartForm

  alias SmartForm.Book

  describe "validating the nested fields" do
    defmodule ValidateBookForm do
      use SmartForm

      smart_form do
        field :title, :string, required: true

        fields_for :chapters do
          field :title, :string, required: true
        end
      end
    end

    test "should return true if the form is valid" do
      book = %Book{}

      form =
        ValidateBookForm.new(book)
        |> ValidateBookForm.validate(%{
          "title" => "Book title",
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
end
