defmodule Crawler.HTTPClient.MockClient do
  @behaviour Crawler.HTTPClient

  def get(%URI{} = url, opts), do: get(URI.to_string(url), opts)

  def get("http://mock/success_url", _opts) do
    response = %HTTPoison.Response{
      body: "<div><a href=\"/example\"></a></div>",
      status_code: 200,
      headers: [{"content-type", "text/html"}]
    }

    {:ok, response}
  end

  def get("http://mock/spacy_success_url", _opts) do
    response = %HTTPoison.Response{
      body: "<div><a href=\"/example-with-space \"></a></div>",
      status_code: 200,
      headers: [{"content-type", "text/html"}]
    }

    {:ok, response}
  end

  def get("http://mock/pdf", _opts) do
    response = %HTTPoison.Response{
      body: "<div><a href=\"/example\"></a></div>",
      status_code: 200,
      headers: [{"content-type", "file/pdf"}]
    }

    {:ok, response}
  end

  def get("http://mock/anchor_url", _opts) do
    response = %HTTPoison.Response{
      body: "<div><a href=\"/anchor_url#with-anchor\"></a></div>",
      status_code: 200,
      headers: [{"content-type", "text/html"}]
    }

    {:ok, response}
  end

  def get(_, _opts) do
    {:error, %HTTPoison.Error{reason: 500}}
  end
end
