defmodule SmartForm do
  defmacro fields(do: fields) do
  end

  defmacro __using__(_) do
    quote do
      import SmartForm, only: [fields: 1]

      defstruct source: nil

      def new(source) do
        %__MODULE__{source: source}
      end
    end
  end
end
