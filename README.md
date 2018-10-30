#  Link Checker
Crawls a website searching for invalid links.

```bash
mix crawl <base_url>
```

#### Options
`--max-depth`: Maximum depth the scraper will travel. Defaults to 3.

`--workers:` Maximum amount of concurrent workers making requests to the provided URL. Defaults to 5.

### Installation
In `mix.exs`
```elixir
def deps do
   [{:crawler, git: "https://github.com/mbta/404_checker"}]
end
```

## Output
Links that respond with a status code outside the range of 200 - 399 are marked as invalid and printed.

If no links are found to be invalid, the task exits with status code 0,
otherwise, exits with status code 1.
