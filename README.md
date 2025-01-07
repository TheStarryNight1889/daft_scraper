# DaftScraper
make sure you have the correct max_items set in the spider

run with mix run


sample query ( requires JQ )

jq -s '[.[] | select(.beds > 2 and .price < 2000 and .price > 400 and .propertyType=="House" and (.title | test("Dublin")))] | {"count": length, "average_price": ([.[].price] | add/length)}' results/1736283209306.jsonl

