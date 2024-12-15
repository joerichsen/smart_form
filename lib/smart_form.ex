defmodule SmartForm do
  use Spark.Dsl,
    default_extensions: [extensions: [SmartForm.Dsl]]

  def new(_module, data, ctx) do
    %{source: data, ctx: ctx}
  end
end
