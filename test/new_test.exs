defmodule NewTest do
  use SmartForm.DataCase
  doctest SmartForm

  alias SmartForm.User

  describe "new" do
    defmodule NewUserForm do
      use SmartForm

      form do
        field :firstname, :string
      end
    end

    test "should accept a struct as an argument and make it the source" do
      user = %User{firstname: "Marie"}
      form = NewUserForm.new(user)
      assert form.source == user
    end

    test "should accept a struct as an argument and make it the source and an additional argument with the context" do
      user = %User{firstname: "Marie"}
      form = NewUserForm.new(user, %{})
      assert form.source == user
    end
  end
end
