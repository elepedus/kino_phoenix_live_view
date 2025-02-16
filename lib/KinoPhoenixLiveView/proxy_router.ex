defmodule KinoPhoenixLiveview.ProxyRouter do
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
