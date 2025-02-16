defmodule KinoPhoenixLiveview.ProxyEndpoint do
  @moduledoc """
  A Phoenix endpoint that serves as the proxy for the Kino Phoenix LiveView.

  It configures the socket for LiveView, serves static assets required for Phoenix
  and Phoenix LiveView, and uses a dynamic router plug to dispatch requests.
  """

  alias KinoPhoenixLiveview.{DynamicRouterPlug}

  use Phoenix.Endpoint,
      otp_app: :kino_phoenix_live_view

  # Log each request at debug level.
  plug(Plug.Logger, log: :debug)

  # Defines the socket used for LiveView communications.
  socket("/proxylive", Phoenix.LiveView.Socket,
    longpoll: true,
    websocket: false,
    pubsub_server: KinoPhoenixLiveview.PubSub
  )

  # Serve static assets for Phoenix.
  plug(Plug.Static, from: {:phoenix, "priv/static"}, at: "/assets/phoenix")
  # Serve static assets for Phoenix LiveView.
  plug(Plug.Static, from: {:phoenix_live_view, "priv/static"}, at: "/assets/phoenix_live_view")
  # Delegate request handling to the dynamic router.
  plug(DynamicRouterPlug)
end