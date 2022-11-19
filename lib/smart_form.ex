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

      def changeset(form, params \\ %{}) do
        types = __fields() |> Enum.map(fn {name, type, _} -> {name, type} end) |> Enum.into(%{})
        {form.source, types} |> Ecto.Changeset.cast(params, Map.keys(types))
      end

      def validate(form, params) do
        changeset = changeset(form, params)

        # Create a list of tuples with the field name and the opt for each option
        # Ie. the definition
        #   field :email, :string, format: ~r/@/, required: true
        # will be converted to
        #   [email: {:format, ~r/@/}, email: {:required, true}]
        name_and_opt_list =
          __fields()
          |> Enum.map(fn {name, _, opts} -> Enum.map(opts, fn opt -> {name, opt} end) end)

        # Apply validations
        changeset =
          name_and_opt_list
          |> Enum.reduce(changeset, fn opts, changeset ->
            Enum.reduce(opts, changeset, fn {name, opt}, changeset ->
              case opt do
                {:required, true} ->
                  Ecto.Changeset.validate_required(changeset, name)

                {:format, format} ->
                  Ecto.Changeset.validate_format(changeset, name, format)

                {:min, min} ->
                  Ecto.Changeset.validate_length(changeset, name, min: min)

                {:max, max} ->
                  Ecto.Changeset.validate_length(changeset, name, max: max)

                {:is, is} ->
                  Ecto.Changeset.validate_length(changeset, name, is: is)

                {:in, data} ->
                  Ecto.Changeset.validate_inclusion(changeset, name, data)

                {:not_in, data} ->
                  Ecto.Changeset.validate_exclusion(changeset, name, data)

                {:less_than, number} ->
                  Ecto.Changeset.validate_number(changeset, name, less_than: number)

                {:greater_than, number} ->
                  Ecto.Changeset.validate_number(changeset, name, greater_than: number)

                {:less_than_or_equal_to, number} ->
                  Ecto.Changeset.validate_number(changeset, name, less_than_or_equal_to: number)

                {:greater_than_or_equal_to, number} ->
                  Ecto.Changeset.validate_number(changeset, name, greater_than_or_equal_to: number)

                {:equal_to, number} ->
                  Ecto.Changeset.validate_number(changeset, name, equal_to: number)

                {:not_equal_to, number} ->
                  Ecto.Changeset.validate_number(changeset, name, not_equal_to: number)

                {:acceptance, true} ->
                  Ecto.Changeset.validate_acceptance(changeset, name)

                {:confirmation, true} ->
                  Ecto.Changeset.validate_confirmation(changeset, name)

                {:subset, subset} ->
                  Ecto.Changeset.validate_subset(changeset, name, subset)

                _ ->
                  changeset
              end
            end)
          end)

        form |> Map.put(:valid?, changeset.valid?)
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
