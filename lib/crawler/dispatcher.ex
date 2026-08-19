defmodule Crawler.Dispatcher do
  @moduledoc """
  Loops through remaining links and creates tasks to check those links for validity
  """
  alias Crawler.{Link, Link.Registry, Link.Checker, Printer}

  @default_opts [max_depth: 3, sleep: 0, workers: 5, base_url: "http://localhost:4001"]

  def process_links(user_opts) do
    opts = Keyword.merge(@default_opts, user_opts)
    {time, invalid_links} = :timer.tc(fn -> do_process_links(opts) end)
    Printer.print_info(time, opts[:max_depth], invalid_links)
    uncertain_links = Enum.filter(invalid_links, &potentially_working?/1)

    if length(uncertain_links) > 0 && opts[:workers] > 1 do
      # Iterating over fewer links, and using fewer workers, results in fewer
      # concurrent requests and less chance of being rate-limited.
      IO.puts("""
      \n#{length(uncertain_links)} links to retry: trying again, now with #{opts[:workers] - 1} workers.
      """)

      _ =
        Enum.each(uncertain_links, fn {url, _link} ->
          # Reset the result of affected links
          Registry.update_link(url, :unknown)
        end)

      opts
      |> Keyword.update!(:workers, &(&1 - 1))
      |> process_links()
    else
      invalid_links
      |> pass_fail()
      |> System.halt()
    end
  end

  defp do_process_links(opts) do
    Registry.reset_dropped()
    task_opts = [timeout: 20_000, max_concurrency: opts[:workers]]

    for depth <- 0..opts[:max_depth] do
      verify = fn link ->
        # Sleep to avoid overwhelming the server with traffic
        if opts[:sleep] > 0, do: Process.sleep(opts[:sleep])
        Checker.verify_link(link, opts[:base_url], depth)
      end

      depth
      |> Registry.unchecked_links()
      |> Task.async_stream(verify, task_opts)
      |> Enum.map(& &1)
    end

    Registry.invalid_links()
  end

  # Some responses might be flaky or transient.
  defp potentially_working?({_path, %Link{result: {:error, 429}}}), do: true
  defp potentially_working?({_path, %Link{result: {:error, :timeout}}}), do: true
  defp potentially_working?(_), do: false

  defp pass_fail([]), do: 0
  defp pass_fail(_), do: 1
end
