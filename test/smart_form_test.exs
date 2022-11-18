defmodule SmartFormTest do
  use SmartForm.DataCase
  doctest SmartForm

  alias SmartForm.User

  defmodule NewUserForm do
    use SmartForm

    fields do
      field :firstname, :string
    end
  end

  describe "new" do
    test "should accept a struct as an argument and make it the source" do
      user = %User{firstname: "Marie"}
      form = NewUserForm.new(user)
      assert form.source == user
    end
  end

  defmodule ValidateUserForm do
    use SmartForm

    fields do
      field :firstname, :string, validate_required: true
    end
  end

  describe "validate" do
    test "should return true if the form is valid" do
      user = %User{}

      form =
        ValidateUserForm.new(user)
        |> ValidateUserForm.validate(%{"firstname" => "Marie"})

      assert form.valid? == true
    end

    test "should return false if the form is invalid" do
      user = %User{}

      form =
        ValidateUserForm.new(user)
        |> ValidateUserForm.validate(%{"firstname" => ""})

      refute form.valid?
    end
  end

  defmodule ValidateRequiredUserForm do
    use SmartForm

    fields do
      field :firstname, :string, validate_required: true
    end
  end

  describe "validate_required" do
    test "should return true if the form is valid" do
      user = %User{}

      form =
        ValidateRequiredUserForm.new(user)
        |> ValidateRequiredUserForm.validate(%{"firstname" => "Marie"})

      assert form.valid? == true
    end

    test "should return false if the form is invalid" do
      user = %User{}

      form =
        ValidateRequiredUserForm.new(user)
        |> ValidateRequiredUserForm.validate(%{"firstname" => ""})

      refute form.valid?
    end
  end

  defmodule ValidateFormatUserForm do
    use SmartForm

    fields do
      field :email, :string, validate_format: ~r/@/
    end
  end

  describe "validate_format" do
    test "should return true if the form is valid" do
      user = %User{}

      form =
        ValidateFormatUserForm.new(user)
        |> ValidateFormatUserForm.validate(%{"email" => "marie@example.com"})

      assert form.valid? == true
    end

    test "should return false if the form is invalid" do
      user = %User{}

      form =
        ValidateFormatUserForm.new(user)
        |> ValidateFormatUserForm.validate(%{"email" => "marie"})

      refute form.valid?
    end
  end
end
