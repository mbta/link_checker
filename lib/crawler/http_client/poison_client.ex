defmodule Crawler.HTTPClient.PoisonClient do
  @behaviour Crawler.HTTPClient

  def get(url, opts) do
    HTTPoison.get(url, opts)
  end
end
