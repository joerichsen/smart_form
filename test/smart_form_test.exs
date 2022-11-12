defmodule SmartFormTest do
  use ExUnit.Case
  doctest SmartForm

  defmodule Form do
    use SmartForm

    fields do
      field(:name, :string, validate: :required)
    end
  end
end
