defmodule Crawler.Supervisor do
  alias Crawler.Link.Registry

  def start_link do
    Supervisor.start_link([
      Registry
    ], strategy: :one_for_one)
  end
end
