defmodule SmartFormTest do
  use ExUnit.Case
  doctest SmartForm

  test "greets the world" do
    assert SmartForm.hello() == :world
  end

  defmodule Form do
    use SmartForm

    fields do
      field(:name, :string, validate: :required)
    end
  end
end
