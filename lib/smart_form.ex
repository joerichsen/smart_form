defmodule SmartForm do
  defmacro fields(do: fields) do
  end

  defmacro __using__(_) do
    quote do
      import SmartForm, only: [fields: 1]
    end
  end
end
