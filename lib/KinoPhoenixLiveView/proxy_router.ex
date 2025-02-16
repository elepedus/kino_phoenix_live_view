defmodule KinoPhoenixLiveview.ProxyRouter do
  @moduledoc """
  Defines the router for the Kino Phoenix LiveView proxy.

  This router sets up a browser pipeline that includes the dynamic root layout
  plug and forwards the root path (`"/"`) to the `DynamicLive` LiveView.
  """

  use Phoenix.Router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug(KinoPhoenixLiveview.DynamicRootLayout)
  end

  scope "/", KinoPhoenixLiveview do
    pipe_through(:browser)
    live("/", DynamicLive)
  end
end