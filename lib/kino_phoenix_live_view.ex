defmodule KinoPhoenixLiveview do
  alias KinoPhoenixLiveview.{Iframe}

  def new(opts) do
    opts =
      Keyword.validate!(opts, [
        :path,
        live_view: KinoPhoenixLiveview.RootLive,
        root_layout: KinoPhoenixLiveview.Layout,
        router: KinoPhoenixLiveview.ProxyRouter,
        endpoint: KinoPhoenixLiveview.ProxyEndpoint
      ])
      |> dbg()

    Application.put_env(:kino_phoenix_live_view, opts[:endpoint],
      server: false,
      adapter: Bandit.PhoenixAdapter,
      live_view: [signing_salt: "aasdffas"],
      secret_key_base: String.duplicate("a", 64),
      pubsub_server: KinoPhoenixLiveview.PubSub,
      check_origin: false,
      url: [path: opts[:path]]
    )

    Application.put_env(:kino_phoenix_live_view, :live_view, opts[:live_view])
    Application.put_env(:kino_phoenix_live_view, :root_layout, opts[:root_layout])
    Application.put_env(:kino_phoenix_live_view, :router, opts[:router])
    Application.put_env(:kino_phoenix_live_view, :endpoint, opts[:endpoint])

    Kino.start_child!(KinoPhoenixLiveview.Application)
    Kino.Proxy.listen(opts[:endpoint])
    Iframe.start(endpoint: opts[:endpoint])
  end
end
