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

                {:min, min} ->
                  Ecto.Changeset.validate_length(changeset, name, min: min).valid?

                {:max, max} ->
                  Ecto.Changeset.validate_length(changeset, name, max: max).valid?

                {:is, is} ->
                  Ecto.Changeset.validate_length(changeset, name, is: is).valid?

                {:in, data} ->
                  Ecto.Changeset.validate_inclusion(changeset, name, data).valid?

                {:not_in, data} ->
                  Ecto.Changeset.validate_exclusion(changeset, name, data).valid?

                {:less_than, number} ->
                  Ecto.Changeset.validate_number(changeset, name, less_than: number).valid?

                {:greater_than, number} ->
                  Ecto.Changeset.validate_number(changeset, name, greater_than: number).valid?

                {:less_than_or_equal_to, number} ->
                  Ecto.Changeset.validate_number(changeset, name, less_than_or_equal_to: number).valid?

                {:greater_than_or_equal_to, number} ->
                  Ecto.Changeset.validate_number(changeset, name, greater_than_or_equal_to: number).valid?

                {:equal_to, number} ->
                  Ecto.Changeset.validate_number(changeset, name, equal_to: number).valid?

                {:not_equal_to, number} ->
                  Ecto.Changeset.validate_number(changeset, name, not_equal_to: number).valid?

                {:acceptance, true} ->
                  Ecto.Changeset.validate_acceptance(changeset, name).valid?

                {:confirmation, true} ->
                  Ecto.Changeset.validate_confirmation(changeset, name).valid?

                {:subset, subset} ->
                  Ecto.Changeset.validate_subset(changeset, name, subset).valid?

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
