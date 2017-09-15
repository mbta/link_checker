defmodule Crawler.Link do

  @moduledoc """
  Data structure represent a link:
  * url - The URL of this link
  * parent - The URL which first contained a link to this url
  * depth - The depth at which this url is located
  * result - The validity of this link
  """

  @type result :: :unknown | :ok | {:error, integer | atom} | :processing

  defstruct [
    url: "",
    parent: nil,
    depth: 0,
    result: :unknown
  ]

  @type t :: %__MODULE__{
    url: String.t,
    parent: String.t,
    depth: integer,
    result: result
  }

  def reset_link(%__MODULE__{result: :processing} = link), do: %{link | result: :unknown}
  def reset_link(%__MODULE__{} = link), do: link
end
