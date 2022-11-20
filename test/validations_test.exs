defmodule ValidationsTest do
  use SmartForm.DataCase
  doctest SmartForm

  alias SmartForm.User

  describe "validate" do
    defmodule ValidateUserForm do
      use SmartForm

      fields do
        field :firstname, :string, required: true
      end
    end

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

  describe "multiple validations" do
    defmodule MultipleValidationsUserForm do
      use SmartForm

      fields do
        field :firstname, :string, required: true
        field :email, :string, format: ~r/@/, required: true
      end
    end

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

  describe "validation of required fields" do
    defmodule ValidateRequiredUserForm do
      use SmartForm

      fields do
        field :firstname, :string, required: true
      end
    end

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

  describe "format validations" do
    defmodule ValidateFormatUserForm do
      use SmartForm

      fields do
        field :email, :string, format: ~r/@/
      end
    end

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

  describe "length validation" do
    defmodule LengthValidationForm do
      use SmartForm

      fields do
        field :username, :string, max: 8
        field :password, :string, min: 3
        field :initials, :string, is: 2
        field :name, :string, min: 3, max: 116
      end
    end

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

  describe "exclusion validation" do
    defmodule ExclusionValidationForm do
      use SmartForm

      fields do
        field :role, :string, not_in: ["admin", "user"]
      end
    end

    test "should validate the exclusion of a string" do
      user = %User{}

      form =
        ExclusionValidationForm.new(user)
        |> ExclusionValidationForm.validate(%{"role" => "admin"})

      refute form.valid?

      form =
        ExclusionValidationForm.new(user)
        |> ExclusionValidationForm.validate(%{"role" => "user"})

      refute form.valid?

      form =
        ExclusionValidationForm.new(user)
        |> ExclusionValidationForm.validate(%{"role" => "guest"})

      assert form.valid?
    end
  end

  describe "number validation" do
    defmodule NumberValidationForm do
      use SmartForm

      fields do
        field :age, :integer, greater_than: 18
        field :height, :float, greater_than_or_equal_to: 1.5
        field :weight, :float, less_than: 100
        field :temperature, :float, less_than_or_equal_to: 37.5
        field :score, :integer, equal_to: 100
        field :length, :integer, not_equal_to: 5.0
      end
    end

    test "should validate the greater than of a number" do
      user = %User{}

      form =
        NumberValidationForm.new(user)
        |> NumberValidationForm.validate(%{"age" => 18})

      refute form.valid?

      form =
        NumberValidationForm.new(user)
        |> NumberValidationForm.validate(%{"age" => 19})

      assert form.valid?
    end

    test "should validate the greater than or equal to of a number" do
      user = %User{}

      form =
        NumberValidationForm.new(user)
        |> NumberValidationForm.validate(%{"height" => 1.4})

      refute form.valid?

      form =
        NumberValidationForm.new(user)
        |> NumberValidationForm.validate(%{"height" => 1.5})

      assert form.valid?

      form =
        NumberValidationForm.new(user)
        |> NumberValidationForm.validate(%{"height" => 1.6})

      assert form.valid?
    end

    test "should validate the less than of a number" do
      user = %User{}

      form =
        NumberValidationForm.new(user)
        |> NumberValidationForm.validate(%{"weight" => 100})

      refute form.valid?

      form =
        NumberValidationForm.new(user)
        |> NumberValidationForm.validate(%{"weight" => 99})

      assert form.valid?
    end

    test "should validate the less than or equal to of a number" do
      user = %User{}

      form =
        NumberValidationForm.new(user)
        |> NumberValidationForm.validate(%{"temperature" => 37.6})

      refute form.valid?

      form =
        NumberValidationForm.new(user)
        |> NumberValidationForm.validate(%{"temperature" => 37.5})

      assert form.valid?

      form =
        NumberValidationForm.new(user)
        |> NumberValidationForm.validate(%{"temperature" => 37.4})

      assert form.valid?
    end

    test "should validate equal to a number" do
      user = %User{}

      form =
        NumberValidationForm.new(user)
        |> NumberValidationForm.validate(%{"score" => 99})

      refute form.valid?

      form =
        NumberValidationForm.new(user)
        |> NumberValidationForm.validate(%{"score" => 100.0})

      refute form.valid?

      form =
        NumberValidationForm.new(user)
        |> NumberValidationForm.validate(%{"score" => 100})

      assert form.valid?
    end

    test "should validate not equal to a number" do
      user = %User{}

      form =
        NumberValidationForm.new(user)
        |> NumberValidationForm.validate(%{"length" => 5})

      refute form.valid?

      form =
        NumberValidationForm.new(user)
        |> NumberValidationForm.validate(%{"length" => 5.0})

      refute form.valid?

      form =
        NumberValidationForm.new(user)
        |> NumberValidationForm.validate(%{"length" => 6})

      assert form.valid?
    end
  end

  describe "acceptance validation" do
    defmodule AcceptanceValidationForm do
      use SmartForm

      fields do
        field :terms, :boolean, acceptance: true
      end
    end

    test "should validate the acceptance of a boolean" do
      user = %User{}

      form =
        AcceptanceValidationForm.new(user)
        |> AcceptanceValidationForm.validate(%{"terms" => false})

      refute form.valid?

      form =
        AcceptanceValidationForm.new(user)
        |> AcceptanceValidationForm.validate(%{"terms" => true})

      assert form.valid?
    end
  end

  describe "confirmation validation" do
    defmodule ConfirmationValidationForm do
      use SmartForm

      fields do
        field :password, :string, confirmation: true
      end
    end

    test "should validate the confirmation of a string" do
      user = %User{}

      form =
        ConfirmationValidationForm.new(user)
        |> ConfirmationValidationForm.validate(%{
          "password" => "123",
          "password_confirmation" => "XXX"
        })

      refute form.valid?

      form =
        ConfirmationValidationForm.new(user)
        |> ConfirmationValidationForm.validate(%{
          "password" => "123",
          "password_confirmation" => "123"
        })

      assert form.valid?
    end
  end

  describe "subset validation" do
    defmodule SubsetValidationForm do
      use SmartForm

      fields do
        field :roles, {:array, :string}, subset: ["admin", "user"]
      end
    end

    test "should validate the subset of an list" do
      user = %User{}

      form =
        SubsetValidationForm.new(user)
        |> SubsetValidationForm.validate(%{"roles" => ["admin", "user"]})

      assert form.valid?

      form =
        SubsetValidationForm.new(user)
        |> SubsetValidationForm.validate(%{"roles" => ["admin", "user", "guest"]})

      refute form.valid?
    end
  end
end
