defmodule Mix.Tasks.Crawl do
  @moduledoc """
  Mix task to parse options and crawl the given site
  """
  use Mix.Task

  def main(argv), do: run(argv)

  def run(argv) do
    Application.ensure_all_started(:httpoison)
    {:ok, _pid} = Crawler.Supervisor.start_link()

    argv
    |> parse_arguments()
    |> Crawler.Dispatcher.process_links()
  end

  defp parse_arguments(argv) do
    with {url, user_opts} <- from_argv(argv),
         {command_opts, _, _} <-
           OptionParser.parse(user_opts, strict: [max_depth: :integer, num_workers: :integer]) do
      if is_nil(url) do
        command_opts
      else
        Keyword.merge(command_opts, base_url: url)
      end
    end
  end

  defp from_argv([]), do: {nil, []}
  defp from_argv([url]), do: {url, []}
  defp from_argv([url | user_opts]), do: {url, user_opts}
end
