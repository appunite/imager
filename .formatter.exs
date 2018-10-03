[
  inputs: [
    "mix.exs",
    "{config,lib,test}/*.{ex,exs}",
    "{config,lib,test}/**/*.{ex,exs}"
  ],
  locals_without_parens: [check: 1, gen: 1],
  line_length: 79,
  import_deps: [:phoenix]
]
