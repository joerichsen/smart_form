# SmartForm

SmartForm is a hex package to make working with forms in Phoenix LiveView easy and simple while at the same time support complex forms.

## Example

```elixir
# Define the form
defmodule Form do
  use SmartForm

  fields do
    field :name, :string, validate: :required
  end
end

# Using the form
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `smart_form` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:smart_form, "~> 0.1.0"}
  ]
end
```

## Documentation

API documentation is available at <https://hexdocs.pm/smart_form>.

## License

Copyright (c) 2022, Jørgen Orehøj Erichsen

SmartForm source code is licensed under the [MIT License](LICENSE.md).
