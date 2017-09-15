defmodule LinkTest do
  use ExUnit.Case, async: true
  import Crawler.Link
  alias Crawler.Link

  describe "reset_link/1" do
    test "links that are left as processing are reset to unknown" do
      link = %Link{result: :processing}
      reset_result = link |> reset_link |> Map.get(:result)
      assert reset_result == :unknown
    end

    test "links that are not processing are unchanged" do
      ok_link = %Link{result: :ok}
      error_link = %Link{result: {:error, 404}}

      assert reset_link(ok_link).result == :ok
      assert reset_link(error_link).result == {:error, 404}
    end
  end
end
