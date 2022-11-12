defmodule SmartForm do
  defmacro fields(do: fields) do
  end

  defmacro __using__(_) do
    quote do
      import SmartForm, only: [fields: 1]

      defstruct source: nil, source_changes: %{}, form_changes: %{}, errors: %{}, fields: []
    end
  end
end
