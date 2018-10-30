defmodule Link.CheckerTest do
  use ExUnit.Case
  import Crawler.Link.Checker
  alias Crawler.Link.Registry

  @initial_links [
    {"/", nil, 0},
    {"/success_url", "/", 1},
    {"/pdf", "/", 1},
    {"/error_url", "/", 1},
    {"/anchor_url", "/", 1}
  ]

  setup do
    {:ok, registry} = start_supervised(Crawler.Link.Registry)

    for {link, parent, depth} <- @initial_links do
      Registry.add_link(link, parent, depth)
    end

    %{registry: registry}
  end

  describe "verify_link/3" do
    test "successful link is marked as successful" do
      verify_link("/success_url", "http://mock", 2)
      invalid_urls = Registry.invalid_links() |> Enum.map(&elem(&1, 0))
      refute "/success_url" in invalid_urls
      refute "/success_url" in Registry.unchecked_links(2)
    end

    test "links on successful link are added to processing list" do
      verify_link("/success_url", "http://mock", 2)
      assert "/example" in Registry.unchecked_links(3)
    end

    test "unsuccessful link is marked with an error" do
      verify_link("/error_url", "http://mock", 2)
      invalid_urls = Registry.invalid_links() |> Enum.map(&elem(&1, 0))
      assert "/error_url" in invalid_urls
    end

    test "Non HTML pages are not crawled for links" do
      verify_link("/pdf", "http://mock", 2)
      refute "/example" in Registry.unchecked_links(3)
    end

    test "Links with anchors are not registered as unique links" do
      verify_link("/anchor_url", "http://mock", 2)
      refute "/anchor_url#with-anchor" in Registry.unchecked_links(3)
    end
  end
end
