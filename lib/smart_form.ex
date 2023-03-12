defmodule SmartForm do
  defmacro smart_form(do: fields) do
    fields = name_type_and_opts(fields)

    quote do
      @__fields unquote(Macro.escape(fields))
      def __fields, do: @__fields
    end
  end

  # Functions for extracting the field name, type, and options
  defp name_type_and_opts({:field, _, [name, type, opts]}) do
    {opts, _} = Code.eval_quoted(opts)
    [{name, type, opts}]
  end

  defp name_type_and_opts({:field, _, [name, type]}), do: [{name, type, nil}]

  defp name_type_and_opts({:__block__, _, fields}),
    do: fields |> Enum.flat_map(&name_type_and_opts(&1))

  defmacro __using__(_) do
    quote do
      import SmartForm, only: [smart_form: 1]

      defstruct source: nil, valid?: nil, data: nil, context: nil

      def new(source \\ %{}, context \\ nil) do
        # Create a new map with a key for each field and the value from the source
        data =
          __fields()
          |> Enum.map(fn {name, _type, opts} ->
            get_function = opts && Keyword.get(opts, :get)

            if get_function do
              if context && function_exported?(__MODULE__, get_function, 3) do
                {name, apply(__MODULE__, get_function, [name, source, context])}
              else
                {name, apply(__MODULE__, get_function, [name, source])}
              end
            else
              {name, Map.get(source, name)}
            end
          end)
          |> Enum.into(%{})

        %__MODULE__{source: source, data: data, context: context}
      end

      def form_changeset(form, params \\ %{}) do
        {fields_with_set_function, fields_with_no_set_function} =
          __fields()
          |> Enum.split_with(fn {_name, _type, opts} -> opts && Keyword.get(opts, :set) end)

        types =
          __fields()
          |> Enum.map(fn {name, type, _opts} -> {name, type} end)
          |> Enum.into(%{})

        # Remove the keys from the params that are not in the types map.
        # Take special care of the confirmation fields
        no_set_function_params =
          params
          |> Map.filter(fn {key, value} ->
            Map.has_key?(types, String.to_atom(key)) ||
              Map.has_key?(types, key |> String.replace("_confirmation", "") |> String.to_atom())
          end)

        # Create a changeset with the fields with no set function
        changeset =
          {form.source, types} |> Ecto.Changeset.cast(no_set_function_params, Map.keys(types))

        # Iterate over the fields with a set function and apply the function and update the changeset
        changeset =
          Enum.reduce(fields_with_set_function, changeset, fn {name, _type, opts}, changeset ->
            set_function = Keyword.get(opts, :set)
            value = Map.get(params, name) || Map.get(params, Atom.to_string(name))

            set_value =
              if form.context && function_exported?(__MODULE__, set_function, 3) do
                apply(__MODULE__, set_function, [name, value, form.context])
              else
                apply(__MODULE__, set_function, [name, value])
              end

            changeset |> Ecto.Changeset.put_change(name, set_value)
          end)
      end

      def changeset(form) do
        form_changeset(form, form.params)
      end

      def validate(form, params) do
        changeset = form_changeset(form, params)

        # Create a list of tuples with the field name and the opt for each option
        # Ie. the definition
        #   field :email, :string, format: ~r/@/, required: true
        # will be converted to
        #   [email: {:format, ~r/@/}, email: {:required, true}]
        name_and_opt_list =
          __fields()
          |> Enum.flat_map(fn {name, _type, opts} ->
            (opts && Enum.map(opts, fn opt -> {name, opt} end)) || []
          end)

        # Apply validations
        changeset =
          name_and_opt_list
          |> Enum.reduce(changeset, fn {name, opt}, changeset ->
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

              {:validate, validation_function} ->
                value = Ecto.Changeset.get_field(changeset, name)

                Ecto.Changeset.validate_change(changeset, name, fn name, value ->
                  apply(__MODULE__, validation_function, [changeset, name, value])
                end)

              _ ->
                changeset
            end
          end)

        form
        |> Map.put(:form_changeset, changeset)
        |> Map.put(:valid?, changeset.valid?)
        |> Map.put(:errors, changeset.errors)
        |> Map.put(:params, params)
      end

      defimpl Phoenix.HTML.FormData do
        @impl true
        def to_form(form, options) do
          changeset = form |> Map.get(:form_changeset) || @for.form_changeset(form)
          options = Keyword.put(options, :as, "form")
          form_data = Phoenix.HTML.FormData.to_form(changeset, options)
          form_data |> Map.put(:errors, changeset.errors)
        end

        @impl true
        def to_form(data, form, field, options) do
          Phoenix.HTML.FormData.to_form(data, form, field, options)
        end

        @impl true
        def input_type(data, form, field) do
          Phoenix.HTML.FormData.input_type(data, form, field)
        end

        @impl true
        def input_value(data, form, field) do
          Phoenix.HTML.FormData.input_value(data, form, field)
        end

        @impl true
        def input_validations(data, form, field) do
          Phoenix.HTML.FormData.input_validations(data, form, field)
        end
      end
    end
  end
end
