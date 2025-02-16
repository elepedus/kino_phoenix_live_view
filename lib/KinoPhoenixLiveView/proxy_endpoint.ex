defmodule KinoPhoenixLiveview.ProxyEndpoint do
  alias KinoPhoenixLiveview.{DynamicRouterPlug}

  use Phoenix.Endpoint,
    otp_app: :kino_phoenix_live_view

  plug(Plug.Logger, log: :debug)

  socket("/proxylive", Phoenix.LiveView.Socket,
    longpoll: true,
    websocket: false,
    pubsub_server: KinoPhoenixLiveview.PubSub
  )

  plug(Plug.Static, from: {:phoenix, "priv/static"}, at: "/assets/phoenix")
  plug(Plug.Static, from: {:phoenix_live_view, "priv/static"}, at: "/assets/phoenix_live_view")
  plug(DynamicRouterPlug)
end
