defmodule FieldsForTest do
  use SmartForm.DataCase
  doctest SmartForm

  alias SmartForm.{Book, Chapter}

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
      book = %Book{chapters: []}

      form =
        ValidateBookForm.new(book)
        |> ValidateBookForm.validate(%{
          "title" => "It",
          "chapters" => [%{"title" => "Chapter 1"}, %{"title" => "Chapter 2"}]
        })

      assert form.valid? == true
    end

    test "should return false if the form is invalid" do
      book = %Book{chapters: []}

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
    defmodule ChangesetBookForm do
      use SmartForm

      smart_form do
        field :title, :string, required: true

        fields_for :chapters do
          field :title, :string, required: true
        end
      end
    end

    test "should return a changeset applied to the source that can be inserted in the database" do
      book = %Book{chapters: []}

      changeset =
        ChangesetBookForm.new(book)
        |> ChangesetBookForm.validate(%{
          "title" => "It",
          "chapters" => [%{"title" => "Chapter 1"}, %{"title" => "Chapter 2"}]
        })
        |> ChangesetBookForm.changeset()

      book = TestRepo.insert!(changeset)

      repo_book = TestRepo.get(Book, book.id) |> TestRepo.preload(:chapters)
      assert repo_book.title == "It"
      assert length(repo_book.chapters) == 2
      assert Enum.at(repo_book.chapters, 0).title == "Chapter 1"
      assert Enum.at(repo_book.chapters, 1).title == "Chapter 2"
    end
  end

  describe "get support" do
    defmodule GetBookForm do
      use SmartForm

      smart_form do
        field :title, :string, required: true

        fields_for :chapters do
          field :title, :string, required: true, get: :translated_title
        end
      end

      def translated_title(name, source) do
        title = Map.get(source, name)

        case title do
          "Chapter 1" -> "Kapitel 1"
          "Chapter 2" -> "Kapitel 2"
          _ -> title
        end
      end
    end

    test "should return the value returned by the get function" do
      book = %Book{
        title: "It",
        chapters: [
          %Chapter{title: "Chapter 1"},
          %Chapter{title: "Chapter 2"}
        ]
      }

      form = GetBookForm.new(book)
      assert Enum.at(form.data.chapters, 0).title == "Kapitel 1"
    end
  end
end
