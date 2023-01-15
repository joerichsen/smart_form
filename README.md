# SmartForm

SmartForm is a small DSL built on top of Ecto which aims to make working with forms in [Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view) easy and simple while at the same time support complex forms.

## Features

* field definitions and validations in the same spot
* non-trivial mappings between source data and the form data are supported

## TODO

* partial validation
* working with nested data is a breeze

## Example

```elixir
# Define the form
defmodule Form do
  use SmartForm

  smart_form do
    field :name, :string, validate: :required
    field :email, :string, validate: :required, format: ~r/@/
  end
end
```

Check out the full "Hello World" example [here](https://github.com/joerichsen/smart_form_examples/blob/main/lib/smart_form_examples_web/live/hello_world.ex).

More examples can be found in the [SmartForm Examples repo](https://github.com/joerichsen/smart_form_examples/)

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
