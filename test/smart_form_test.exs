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
      field :firstname, :string, required: true
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

  defmodule MultipleValidationsUserForm do
    use SmartForm

    fields do
      field :firstname, :string, required: true
      field :email, :string, format: ~r/@/, required: true
    end
  end

  describe "multiple validations" do
    test "should validate multiple fields" do
      user = %User{}

      form =
        MultipleValidationsUserForm.new(user)
        |> MultipleValidationsUserForm.validate(%{"firstname" => "Marie"})

      refute form.valid?

      form =
        MultipleValidationsUserForm.new(user)
        |> MultipleValidationsUserForm.validate(%{"firstname" => "Marie", "email" => "marie"})

      refute form.valid?

      form =
        MultipleValidationsUserForm.new(user)
        |> MultipleValidationsUserForm.validate(%{"email" => "marie@example.com"})

      refute form.valid?

      form =
        MultipleValidationsUserForm.new(user)
        |> MultipleValidationsUserForm.validate(%{
          "firstname" => "Marie",
          "email" => "marie@example.com"
        })

      assert form.valid?
    end
  end

  defmodule ValidateRequiredUserForm do
    use SmartForm

    fields do
      field :firstname, :string, required: true
    end
  end

  describe "validation of required fields" do
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
      field :email, :string, format: ~r/@/
    end
  end

  describe "format validations" do
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

  defmodule LengthValidationForm do
    use SmartForm

    fields do
      field :username, :string, max: 8
      field :password, :string, min: 3
      field :initials, :string, is: 2
      field :name, :string, min: 3, max: 116
    end
  end

  describe "length validation" do
    test "should validate the max length of a string" do
      user = %User{}

      form =
        LengthValidationForm.new(user)
        |> LengthValidationForm.validate(%{"username" => "marie"})

      assert form.valid?

      form =
        LengthValidationForm.new(user)
        |> LengthValidationForm.validate(%{"username" => "mariecurie"})

      refute form.valid?
    end

    test "should validate the min length of a string" do
      user = %User{}

      form =
        LengthValidationForm.new(user)
        |> LengthValidationForm.validate(%{"password" => "12"})

      refute form.valid?

      form =
        LengthValidationForm.new(user)
        |> LengthValidationForm.validate(%{"password" => "123"})

      assert form.valid?
    end

    test "should validate the exact length of a string" do
      user = %User{}

      form =
        LengthValidationForm.new(user)
        |> LengthValidationForm.validate(%{"initials" => "M"})

      refute form.valid?

      form =
        LengthValidationForm.new(user)
        |> LengthValidationForm.validate(%{"initials" => "MCA"})

      refute form.valid?

      form =
        LengthValidationForm.new(user)
        |> LengthValidationForm.validate(%{"initials" => "MC"})

      assert form.valid?
    end
  end

  describe "inclusion validation" do
    defmodule InclusionValidationForm do
      use SmartForm

      fields do
        field :role, :string, in: ["admin", "user"]
      end
    end

    test "should validate the inclusion of a string" do
      user = %User{}

      form =
        InclusionValidationForm.new(user)
        |> InclusionValidationForm.validate(%{"role" => "admin"})

      assert form.valid?

      form =
        InclusionValidationForm.new(user)
        |> InclusionValidationForm.validate(%{"role" => "user"})

      assert form.valid?

      form =
        InclusionValidationForm.new(user)
        |> InclusionValidationForm.validate(%{"role" => "guest"})

      refute form.valid?
    end
  end
end
