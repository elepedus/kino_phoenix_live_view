defmodule KinoPhoenixLiveview.Iframe do
  use Kino.JS

  def start(endpoint: endpoint) do
    new(src: apply(endpoint, :path, ["/"]))
  end

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
