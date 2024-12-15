defmodule SmartForm do
  use Spark.Dsl,
    default_extensions: [extensions: [SmartForm.Dsl]]

  def new(_module, data, ctx) do
    %{source: data, ctx: ctx}
  end

  def validate(_module, smart_form, _params) do
    smart_form
  end

  def changeset(_module, smart_form) do
    smart_form
  end
end
