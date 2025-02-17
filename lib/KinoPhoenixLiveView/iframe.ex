defmodule KinoPhoenixLiveView.Iframe do
  @moduledoc """
  Provides a Kino JavaScript widget that embeds a Phoenix LiveView
  endpoint inside an iframe. This module leverages `Kino.JS` to render
  an iframe in the notebook.

  The associated JavaScript asset (`main.js`) creates an `<iframe>`
  element with the provided source URL and appends it to the widget's root.
  """

  use Kino.JS

  @doc """
  Starts the iframe widget using the given endpoint.

  It extracts the iframe source URL by calling the endpoint's `:path`
  function with `"/"` and delegates to `new/1`.

  ## Parameters

    - `endpoint`: The Phoenix endpoint module used to generate the URL.

  ## Examples

      iex> KinoPhoenixLiveView.Iframe.start(endpoint: MyApp.Endpoint)
  """
  def start(endpoint: endpoint) do
    new(src: apply(endpoint, :path, ["/"]))
  end

  @doc """
  Creates a new Kino JavaScript widget with the given iframe source.

  This function initializes the widget by calling `Kino.JS.new/2`
  with the current module and the specified `src`.

  ## Parameters

    - `src`: A keyword with the key `:src` containing the URL to load
      in the iframe.

  ## Examples

      iex> KinoPhoenixLiveView.Iframe.new(src: "http://localhost:4000/")
  """
  def new(src: src) do
    Kino.JS.new(__MODULE__, src)
  end

  asset "main.js" do
    """
    export function init(ctx, src) {
      const iframe = document.createElement('iframe')
      iframe.setAttribute("src", src)
      iframe.style.width = "100%"
      iframe.style.height = "660px"
      iframe.style.border = "none"
      ctx.root.appendChild(iframe)
    }
    """
  end
end