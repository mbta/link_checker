defmodule Crawler.Printer do
  alias Crawler.Link.Registry

  @moduledoc """
  Module used for printing information about the scraping results
  """

  def print_info(time, max_depth, []) do
    IO.puts("\n#{IO.ANSI.green()}PASSED SUCCESSFULLY#{IO.ANSI.default_color()}")
    print_time(time)
    print_unchecked_links(max_depth)
  end
  def print_info(time, max_depth, invalid_links) do
    print_time(time)
    IO.puts("\n#{IO.ANSI.red()}Finished with #{Enum.count(invalid_links)} errors #{IO.ANSI.default_color()}")
    IO.puts("")
    print_invalid_links(invalid_links)
    print_unchecked_links(max_depth)
  end

  defp print_unchecked_links(max_depth) do
    unchecked_count = max_depth
                      |> Kernel.+(1)
                      |> Registry.unchecked_links()
                      |> Enum.count
    IO.puts("#{unchecked_count} links not checked")
  end

  def print_error(link, reason), do: Task.async(fn -> do_print_error(link, reason) end)

  def do_print_error(link, reason) do
    IO.write(IO.ANSI.red())
    IO.puts("\nFAILED #{link}")
    IO.puts("REASON: #{reason}")
    IO.write(IO.ANSI.default_color())
  end

  def print_success do
    Task.async(fn -> IO.write("#{IO.ANSI.green()}.#{IO.ANSI.default_color()}") end)
  end

  defp print_time(time) do
    seconds = time |> Kernel./(1_000_000) |> Float.round(2)
    minutes = seconds |> Kernel./(60) |> Float.round(2)
    IO.puts("Finished in #{seconds} seconds (#{minutes} minutes)")
  end

  defp print_invalid_links(links) do
    IO.puts("Invalid Links:")
    for {_url, link} <- links do
      IO.puts("\nURL: #{link.url}")
      IO.puts("Reason: #{inspect(elem(link.result, 1))}")
      IO.puts("Parent: #{link.parent}")
      IO.puts("Depth: #{link.depth}")
    end
  end
end
