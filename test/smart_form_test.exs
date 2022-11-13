defmodule SmartFormTest do
  use SmartForm.DataCase
  doctest SmartForm

  alias SmartForm.User

  defmodule Form do
    use SmartForm

    fields do
      field :name, :string, validate: :required
    end
  end

  describe "new" do
    test "should accept a struct as an argument" do
      user = %User{firstname: "John"}
      form = Form.new(user)
      assert form.source == user
    end
  end
end
