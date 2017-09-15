defmodule LinkRegistryTest do
  use ExUnit.Case
  import Crawler.Link.Registry

  @initial_links [
    {"/second", "/first", 0},
    {"/third", "/first", 0},
    {"/fourth", "/second", 1},
    {"/fifth", "/fourth", 2}
  ]

  setup do
    {:ok, registry} = start_supervised(Crawler.Link.Registry)
    for {link, parent, depth} <- @initial_links do
      add_link(link, parent, depth)
    end
    %{registry: registry}
  end

  describe "unchecked_links/1" do
    test "returns all unchecked_links at given depth" do
      assert 0 |> unchecked_links() |> Enum.count() == 1
      assert 1 |> unchecked_links() |> Enum.count() == 2
      assert 2 |> unchecked_links() |> Enum.count() == 1
    end
  end

  describe "add_link/3" do
    test "links are added one depth deeper than current depth" do
      add_link("/my-link", "/parent", 0)
      assert "/my-link" in unchecked_links(1)
    end

    test "Links are added as unchecked" do
      add_link("/test-link", "/test-parent", 0)
      assert "/test-link" in unchecked_links(1)
    end
  end

  describe "update_link/2" do
    test "links are no longer unchecked once result is set" do
      add_link("/test-link", "/parent", 0)
      add_link("/broken-link", "/parent", 0)
      update_link("/test-link", :ok)
      update_link("/broken-link", {:error, 404})

      refute "/test-link" in unchecked_links(1)
      refute "/broken-link" in unchecked_links(1)
    end
  end

  describe "invalid_links/0" do
    test "only links with errors are returned" do
      add_link("/ok-link", "/parent", 0)
      add_link("/broken-link", "/parent", 0)
      update_link("/ok-link", :ok)
      update_link("/broken-link", {:error, 404})

      invalid_urls = invalid_links() |> Enum.map(fn {url, _link} -> url end)
      refute "/ok-link" in invalid_urls
      assert "/broken-link" in invalid_urls
    end
  end
end
