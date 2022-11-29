locals_without_parens = [
  field: 2,
  field: 3,
  create: :*,
  add: :*,
  belongs_to: :*,
  has_many: :*,
  table: :*
]

[
  locals_without_parens: locals_without_parens,
  export: [
    locals_without_parens: locals_without_parens
  ],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]
