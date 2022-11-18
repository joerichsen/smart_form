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

      def changeset(form, params) do
        types = __fields() |> Enum.map(fn {name, type, _} -> {name, type} end) |> Enum.into(%{})
        changeset = {form.source, types} |> Ecto.Changeset.cast(params, Map.keys(types))
      end

      def validate(form, params) do
        changeset = changeset(form, params)

        valid =
          __fields()
          |> Enum.all?(fn {name, _, opts} ->
            opts = opts || []

            opts
            |> Enum.all?(fn opt ->
              case opt do
                {:required, true} ->
                  Ecto.Changeset.validate_required(changeset, name).valid?

                {:format, format} ->
                  Ecto.Changeset.validate_format(changeset, name, format).valid?

                _ ->
                  true
              end
            end)
          end)

        form |> Map.put(:valid?, valid)
      end
    end
  end

  def name_type_and_opts({:field, _, [name, type, opts]}) do
    {opts, _} = Code.eval_quoted(opts)
    [{name, type, opts}]
  end

  def name_type_and_opts({:field, _, [name, type]}), do: [{name, type, nil}]

  def name_type_and_opts({:__block__, _, fields}),
    do: fields |> Enum.flat_map(&name_type_and_opts(&1))
end
