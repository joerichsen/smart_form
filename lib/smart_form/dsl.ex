defmodule SmartForm.Dsl do
  defmodule Field do
    defstruct [:name, :type]
  end

  @field %Spark.Dsl.Entity{
    name: :field,
    args: [:name, :type],
    target: Field,
    describe: "A field that is accepted by the validator",
    # you can include nested entities here, but
    # note that you provide a keyword list like below
    # we need to know which struct key to place the nested entities in
    # entities: [
    #   key: [...]
    # ],
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "The name of the field"
      ],
      type: [
        type:
          {:one_of,
           [
             :integer,
             :float,
             :boolean,
             :string,
             :bitstring,
             :map,
             :binary,
             :decimal,
             :id,
             :binary_id,
             :utc_datetime,
             :naive_datetime,
             :date,
             :time,
             :any,
             :utc_datetime_usec,
             :naive_datetime_usec,
             :time_usec,
             :duration
           ]},
        required: true,
        doc: "The type of the field"
      ]
    ]
  }

  @smart_form %Spark.Dsl.Section{
    name: :smart_form,
    entities: [
      @field
    ],
    describe: "Configure the fields that are supported and required"
  }

  use Spark.Dsl.Extension,
    sections: [@smart_form],
    transformers: [SmartForm.Transformers.GenerateNew]
end
