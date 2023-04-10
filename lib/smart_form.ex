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

  defp name_type_and_opts({:do, {:field, _, [name, type, opts]}}) do
    {opts, _} = Code.eval_quoted(opts)
    [{name, type, opts}]
  end

  defp name_type_and_opts({:field, _, [name, type]}), do: [{name, type, nil}]

  defp name_type_and_opts({:__block__, _, fields}),
    do: fields |> Enum.flat_map(&name_type_and_opts(&1))

  defp name_type_and_opts({:fields_for, _, [name, fields]}) do
    nested_fields = fields |> Enum.flat_map(&name_type_and_opts(&1))
    [{name, :fields_for, nested_fields}]
  end

  defmacro __using__(_) do
    quote do
      import SmartForm, only: [smart_form: 1]

      defstruct source: nil, valid?: nil, data: nil, context: nil

      def new(source \\ %{}, context \\ nil) do
        {nested_fields, fields} =
          __fields() |> Enum.split_with(fn {_, type, _} -> type == :fields_for end)

        # Create a new map with a key for each field and the value from the source
        data =
          fields
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

        # Create a new map with a key for each nested field and the value from the source
        nested_data =
          nested_fields
          |> Enum.map(fn {name, _type, nested_fields} ->
            source = Map.get(source, name)

            nested_data =
              nested_fields
              |> Enum.flat_map(fn {name, _type, opts} ->
                get_function = opts && Keyword.get(opts, :get)

                source
                |> Enum.map(fn source ->
                  if get_function do
                    if context && function_exported?(__MODULE__, get_function, 3) do
                      %{name => apply(__MODULE__, get_function, [name, source, context])}
                    else
                      %{name => apply(__MODULE__, get_function, [name, source])}
                    end
                  else
                    %{name => Map.get(source, name)}
                  end
                end)
              end)

            {name, nested_data}
          end)
          |> Enum.into(%{})

        data = Map.merge(data, nested_data)

        %__MODULE__{source: source, data: data, context: context}
      end

      def form_changeset(form, params \\ %{}) do
        {nested_fields, fields} =
          __fields() |> Enum.split_with(fn {_, type, _} -> type == :fields_for end)

        {fields_with_set_function, fields_with_no_set_function} =
          fields
          |> Enum.split_with(fn {_name, _type, opts} -> opts && Keyword.get(opts, :set) end)

        types =
          fields
          |> Enum.map(fn {name, type, _opts} -> {name, type} end)
          |> Enum.into(%{})

        embedded_types =
          nested_fields
          |> Enum.map(fn {name, _type, nested_fields} ->
            related = form.source.__meta__.schema.__schema__(:association, :chapters).related

            {name,
             {:embed,
              %Ecto.Embedded{
                cardinality: :many,
                field: name,
                related: related,
                owner: form.source.__struct__
              }}}
          end)
          |> Enum.into(%{})

        # Remove the keys from the params that are not in the types map.
        # Take special care of the confirmation fields
        no_set_function_params =
          params
          |> Map.filter(fn {key, value} ->
            Map.has_key?(types, String.to_atom(key)) ||
              Map.has_key?(embedded_types, String.to_atom(key)) ||
              Map.has_key?(types, key |> String.replace("_confirmation", "") |> String.to_atom()) ||
              Map.has_key?(
                embedded_types,
                key |> String.replace("_confirmation", "") |> String.to_atom()
              )
          end)

        # Create a changeset with the fields with no set function
        changeset =
          {form.source, Map.merge(types, embedded_types)}
          |> Ecto.Changeset.cast(no_set_function_params, Map.keys(types))

        # Create a changeset for each of the nested fields
        Enum.reduce(nested_fields, changeset, fn {name, _type, nested_fields}, changeset ->
          cast_embed(changeset, name,
            with: fn model, params ->
              fields = nested_fields |> Enum.map(fn {name, _type, _opts} -> name end)
              cast(model, params, fields)
            end
          )
        end)
      end

      def changeset(form) do
        params = form.params
        changeset = form_changeset(form, params)

        {nested_fields, fields} =
          __fields() |> Enum.split_with(fn {_, type, _} -> type == :fields_for end)

        {fields_with_set_function, fields_with_no_set_function} =
          fields
          |> Enum.split_with(fn {_name, _type, opts} -> opts && Keyword.get(opts, :set) end)

        # Allowed fields are the fields from the form and the keys of maps returned by custom set functions
        form_fields = __fields() |> Enum.map(fn {name, _type, _opts} -> name end)

        set_function_fields =
          fields_with_set_function
          |> Enum.map(fn {name, _type, opts} ->
            set_function = Keyword.get(opts, :set)
            value = Map.get(params, name) || Map.get(params, Atom.to_string(name))

            set_value =
              if form.context && function_exported?(__MODULE__, set_function, 3) do
                apply(__MODULE__, set_function, [name, value, form.context])
              else
                apply(__MODULE__, set_function, [name, value])
              end

            # If set_value is a map we iterate over the keys and update the changeset
            if is_map(set_value) && !is_struct(set_value) do
              Map.keys(set_value)
            else
              []
            end
          end)
          |> List.flatten()

        fields = form_fields ++ set_function_fields

        # Restrict the fields to the ones that are in the source
        source_fields = form.source.__meta__.schema.__schema__(:fields)
        fields = Enum.filter(fields, fn field -> Enum.member?(source_fields, field) end)

        changeset = form.source |> Ecto.Changeset.cast(params, fields)

        # Cast the nested fields
        changeset =
          Enum.reduce(nested_fields, changeset, fn {name, _type, nested_fields}, changeset ->
            cast_assoc(changeset, name,
              with: fn model, params ->
                fields = nested_fields |> Enum.map(fn {name, _type, _opts} -> name end)
                cast(model, params, fields)
              end
            )
          end)

        # Iterate over the fields with a set function and apply the function and update the changeset
        Enum.reduce(fields_with_set_function, changeset, fn {name, _type, opts}, changeset ->
          set_function = Keyword.get(opts, :set)
          value = Map.get(params, name) || Map.get(params, Atom.to_string(name))

          set_value =
            if form.context && function_exported?(__MODULE__, set_function, 3) do
              apply(__MODULE__, set_function, [name, value, form.context])
            else
              apply(__MODULE__, set_function, [name, value])
            end

          # If set_value is a map we iterate over the keys and update the changeset
          if is_map(set_value) && !is_struct(set_value) do
            Enum.reduce(set_value, changeset, fn {key, value}, changeset ->
              Ecto.Changeset.put_change(changeset, key, value)
            end)
          else
            Ecto.Changeset.put_change(changeset, name, set_value)
          end
        end)
      end

      def validate(form, params) do
        changeset = form_changeset(form, params)

        {nested_fields, fields} =
          __fields() |> Enum.split_with(fn {_, type, _} -> type == :fields_for end)

        # Create a list of tuples with the field name and the opt for each option
        # Ie. the definition
        #   field :email, :string, format: ~r/@/, required: true
        # will be converted to
        #   [email: {:format, ~r/@/}, email: {:required, true}]
        name_and_opt_list =
          fields
          |> Enum.flat_map(fn {name, _type, opts} ->
            (opts && Enum.map(opts, fn opt -> {name, opt} end)) || []
          end)

        # Apply validations
        changeset = apply_validations(changeset, name_and_opt_list)

        # Validate the nested fields
        changeset =
          Enum.reduce(nested_fields, changeset, fn {nested_field, _type, nested_field_fields},
                                                   changeset ->
            nested_changesets = changeset.changes |> Map.get(nested_field)

            # Apply validations for each of the nested changesets and for each nested changeset and each of the nested fields
            nested_changesets =
              Enum.map(nested_changesets, fn nested_changeset ->
                nested_field_fields
                |> Enum.reduce(nested_changeset, fn {name, _type, opts}, nested_changeset ->
                  name_and_opt_list = (opts && Enum.map(opts, fn opt -> {name, opt} end)) || []
                  apply_validations(nested_changeset, name_and_opt_list)
                end)
              end)

            Ecto.Changeset.put_change(changeset, nested_field, nested_changesets)
          end)

        form
        |> Map.put(:form_changeset, changeset)
        |> Map.put(:valid?, changeset.valid?)
        |> Map.put(:errors, changeset.errors)
        |> Map.put(:params, params)
      end

      defp apply_validations(changeset, name_and_opt_list) do
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
