defmodule ChangesetTest do
  use SmartForm.DataCase
  doctest SmartForm

  alias SmartForm.User

  describe "changeset" do
    defmodule ChangesetForm do
      use SmartForm

      form do
        field :firstname, :string, required: true
      end
    end

    test "should return a changeset applied to the source that can be inserted in the database" do
      marie = %User{firstname: "Marie"}

      changeset =
        marie
        |> ChangesetForm.new()
        |> ChangesetForm.validate(%{"firstname" => "Lisa"})
        |> ChangesetForm.changeset()

      lisa = TestRepo.insert!(changeset)

      assert TestRepo.get(User, lisa.id).firstname == "Lisa"
    end

    test "should return a changeset applied to the source that can be updated in the database" do
      marie = %User{firstname: "Marie"}
      marie = TestRepo.insert!(marie)

      changeset =
        marie
        |> ChangesetForm.new()
        |> ChangesetForm.validate(%{"firstname" => "Lisa"})
        |> ChangesetForm.changeset()

      lisa = TestRepo.update!(changeset)

      assert TestRepo.get(User, lisa.id).firstname == "Lisa"
    end
  end
end
