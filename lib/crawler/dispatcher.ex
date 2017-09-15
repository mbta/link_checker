defmodule Crawler.Dispatcher do
  @moduledoc """
  Loops through remaining links and creates tasks to check those links for validity
  """
  alias Crawler.{Link.Registry, Link.Checker, Printer}

  @default_opts [max_depth: 3, workers: 5, base_url: "http://localhost:4001"]

  def process_links(user_opts) do
    opts = Keyword.merge(@default_opts, user_opts)
    {time, invalid_links} = :timer.tc(fn -> do_process_links(opts) end)
    Printer.print_info(time, opts[:max_depth], invalid_links)
    invalid_links |> pass_fail() |> System.halt()
  end

  defp do_process_links(opts) do
    Registry.reset_dropped()
    task_opts = [timeout: 20_000, max_concurrency: opts[:workers]]
    for depth <- 0..opts[:max_depth] do
      verify = fn link -> Checker.verify_link(link, opts[:base_url], depth) end
      depth
      |> Registry.unchecked_links()
      |> Task.async_stream(verify, task_opts)
      |> Enum.map(& &1)
    end
    Registry.invalid_links()
  end

  defp pass_fail([]), do: 0
  defp pass_fail(_), do: 1
end
