# SmartForm

SmartForm is a hex package to make working with forms in [Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view) easy and simple while at the same time support complex forms.

## Features

* field definitions and validations in the same spot
* working with nested data is a breeze
* non-trivial mappings between source data and the form data are supported
* partial validation

## Example

```elixir
# Define the form
defmodule Form do
  use SmartForm

  smart_form do
    field :name, :string, validate: :required
  end
end

# Using the form
```

## Installation

The package can be installed by adding `smart_form` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:smart_form, "~> 0.1.0"}
  ]
end
```

## Documentation

API documentation is available at <https://hexdocs.pm/smart_form>.

## Inspiration

SmartForm is inspired by Ecto itself as well as [Ash Framework](https://www.ash-hq.org/) and [Data Division](https://github.com/pragdave/data_division).

## License

Copyright (c) 2022, Jørgen Orehøj Erichsen

SmartForm source code is licensed under the [MIT License](LICENSE).
