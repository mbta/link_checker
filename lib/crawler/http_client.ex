defmodule Crawler.HTTPClient do
  @callback get(String.t, Keyword.t) ::
  {:ok, HTTPoison.Response.t | HTTPoison.AsyncResponse.t}
  | {:error, HTTPoison.Error.t}
end
