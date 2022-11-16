defmodule SmartForm do
  defmacro fields(do: fields) do
    fields = name_type_and_opts(fields)

    quote do
      @__fields unquote(Macro.escape(fields))
      def __fields, do: @__fields
    end
  end

  defmacro __using__(_) do
    quote do
      import SmartForm, only: [fields: 1]

      defstruct source: nil, valid?: nil

      def new(source) do
        %__MODULE__{source: source}
      end

      def validate(form, params) do
        valid =
          __fields()
          |> Enum.all?(fn {name, type, opts} ->
            value = Map.get(params, name) || Map.get(params, to_string(name))

            if opts && Keyword.get(opts, :validate_required) do
              !is_nil(value) && value != ""
            else
              true
            end
          end)

        form |> Map.put(:valid?, valid)
      end
    end
  end

  def name_type_and_opts({:field, _, [name, type, opts]}), do: [{name, type, opts}]
  def name_type_and_opts({:field, _, [name, type]}), do: [{name, type, nil}]

  def name_type_and_opts({:__block__, _, fields}),
    do: fields |> Enum.flat_map(&name_type_and_opts(&1))
end
