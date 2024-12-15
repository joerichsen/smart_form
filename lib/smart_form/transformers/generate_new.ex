defmodule SmartForm.Transformers.GenerateNew do
  use Spark.Dsl.Transformer

  def transform(dsl_state) do
    new =
      quote do
        def new(data, ctx \\ %{}) do
          # Our generated code can be very simple
          # because we can get all the info we need from the module
          # in our regular ELixir code.
          SmartForm.new(__MODULE__, data, ctx)
        end
      end

    {:ok, Spark.Dsl.Transformer.eval(dsl_state, [], new)}
  end
end
