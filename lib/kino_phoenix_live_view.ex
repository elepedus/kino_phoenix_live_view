defmodule KinoPhoenixLiveview do
  @moduledoc """
  Provides a simple interface for launching a Phoenix LiveView within a Kino widget.

  This module handles the configuration and startup of a proxy endpoint that
  serves your LiveView inside an iframe. It abstracts away the complexity of setting
  up a full Phoenix endpoint by offering a few preset option combinations.

  ## Usage

  Call `KinoPhoenixLiveview.new/1` with one of the following option sets:

    1. **Only Path (Use All Defaults)**
       ```elixir
       KinoPhoenixLiveview.new(path: "/proxy/apps/{slug}")
       ```

    2. **Custom LiveView**
       ```elixir
       KinoPhoenixLiveview.new(path: "/proxy/apps/{slug}", live_view: MyApp.LiveView)
       ```

    3. **Custom LiveView and Layout**
       ```elixir
       KinoPhoenixLiveview.new(path: "/proxy/apps/{slug}", live_view: MyApp.LiveView, root_layout: MyApp.Layout)
       ```

    4. **Custom Router**
       ```elixir
       KinoPhoenixLiveview.new(path: "/proxy/apps/{slug}", router: MyApp.Router)
       ```

    5. **Custom Endpoint**
       ```elixir
       KinoPhoenixLiveview.new(path: "/proxy/apps/{slug}", endpoint: MyApp.Endpoint)
       ```
  """

  alias KinoPhoenixLiveview.Iframe

  @doc """
  Launches the Kino Phoenix LiveView integration with various configurations.

  The options you pass determine which integration variant is used.

  **Variants:**

    - *Only Path:* Uses defaults for LiveView, layout, router, and endpoint.
    - *Custom LiveView:* Override the default LiveView module.
    - *Custom LiveView and Layout:* Override both LiveView and layout.
    - *Custom Router:* Provide your own router.
    - *Custom Endpoint:* Provide your own endpoint.

  **Note:** Each call must include a `:path` key. Do not mix incompatible options.
  """
  def new(opts)

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

  @doc false
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
        router: opts[:router]
      ]
    )

    Kino.start_child!(KinoPhoenixLiveview.Application)
    Kino.Proxy.listen(opts[:endpoint])
    Iframe.start(endpoint: opts[:endpoint])
  end
end