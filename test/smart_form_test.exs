defmodule SmartFormTest do
  use SmartForm.DataCase
  doctest SmartForm

  alias SmartForm.User

  defmodule UserForm do
    use SmartForm

    fields do
      field :firstname, :string, validate: :required
    end
  end

  describe "new" do
    test "should accept a struct as an argument and make it the source" do
      user = %User{firstname: "Marie"}
      form = UserForm.new(user)
      assert form.source == user
    end
  end

  describe "validate" do
    test "should return true if the form is valid" do
      user = %User{}
      form = UserForm.new(user) |> UserForm.validate(%{"firstname" => "Marie"})
      assert form.valid? == true
    end

    test "should return false if the form is invalid" do
      user = %User{}
      form = UserForm.new(user) |> UserForm.validate(%{"firstname" => ""})
      refute form.valid?
    end
  end
end
