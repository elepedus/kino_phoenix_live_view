defmodule KinoPhoenixLiveview do
  alias KinoPhoenixLiveview.{Iframe}

  def new(path: _ = opts) do
    init(Keyword.validate!(opts, [:path]))
  end

  def new([path: _, live_view: _] = opts) do
    init(Keyword.validate!(opts, [:path, :live_view]))
  end

  def new([path: _, live_view: _, root_layout: _] = opts) do
    init(Keyword.validate!(opts, [:path, :live_view, :root_layout]))
  end

  def new([path: _, router: _] = opts) do
    init(Keyword.validate!(opts, [:path, :router]))
  end

  def new([path: _, endpoint: _] = opts) do
    init(Keyword.validate!(opts, [:path, :endpoint]))
  end

  defp init(opts) do
    opts =
      Keyword.validate!(opts, [
        :path,
        live_view: KinoPhoenixLiveview.RootLive,
        root_layout: KinoPhoenixLiveview.Layout,
        router: KinoPhoenixLiveview.ProxyRouter,
        endpoint: KinoPhoenixLiveview.ProxyEndpoint
      ])

    Application.put_env(:kino_phoenix_live_view, opts[:endpoint],
      server: false,
      adapter: Bandit.PhoenixAdapter,
      live_view: [signing_salt: "aasdffas"],
      secret_key_base: String.duplicate("a", 64),
      pubsub_server: KinoPhoenixLiveview.PubSub,
      check_origin: false,
      url: [path: opts[:path]]
    )

    Application.put_all_env(
      kino_phoenix_live_view: [
        endpoint: opts[:endpoint],
        live_view: opts[:live_view],
        root_layout: opts[:root_layout],
        router: opts[:router],
      ]
    )

    Kino.start_child!(KinoPhoenixLiveview.Application)
    Kino.Proxy.listen(opts[:endpoint])
    Iframe.start(endpoint: opts[:endpoint])
  end
end
