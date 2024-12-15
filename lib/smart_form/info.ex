defmodule SmartForm.Info do
  use Spark.InfoGenerator, extension: SmartForm.Dsl, sections: [:smart_form]
end
