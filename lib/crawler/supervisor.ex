defmodule Crawler.Supervisor do
  alias Crawler.Link.Registry
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  @impl true
  def init(_opts) do
    children = [worker(Registry, [[]])]

    supervise(children, strategy: :one_for_one)
  end
end
