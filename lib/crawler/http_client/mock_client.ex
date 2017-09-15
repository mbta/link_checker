defmodule Crawler.HTTPClient.MockClient do
  @behaviour Crawler.HTTPClient

  def get("http://mock/success_url", _opts) do
    response = %HTTPoison.Response{
      body: "<div><a href=\"/example\"></a></div>",
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

  def get(_, _opts) do
    {:error, %HTTPoison.Error{reason: 500}}
  end
end
