# DaftScraper
make sure you have the correct max_items set in the spider

run with mix run


sample query ( requires JQ )

jq -s '[.[] | select(.beds > 2 and .price < 2000 and .price > 400 and .propertyType=="House" and (.title | test("Dublin")))] | {"count": length, "average_price": ([.[].price] | add/length)}' results/1736283209306.jsonl

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `daft_scraper` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:daft_scraper, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/daft_scraper>.

