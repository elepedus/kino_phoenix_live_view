defmodule KinoPhoenixLiveview do
  @moduledoc """
  Provides a simple interface for launching a Phoenix LiveView within a Kino widget.

  This module handles the configuration and startup of a proxy endpoint that
  serves your LiveView inside an iframe. It abstracts away the complexity of setting
  up a full Phoenix endpoint by offering a few preset option combinations.

  ## Usage

  To get started, call `KinoPhoenixLiveview.new/1` with one of the following option sets.
  **Each call must include a `:path` option.**

  **Option Set 1: Only Path (Use All Defaults)**

      KinoPhoenixLiveview.new(path: "/proxy/apps/{slug}")

  **Option Set 2: Custom LiveView**

      KinoPhoenixLiveview.new(path: "/proxy/apps/{slug}", live_view: MyApp.LiveView)

  **Option Set 3: Custom LiveView and Layout**

      KinoPhoenixLiveview.new(path: "/proxy/apps/{slug}", live_view: MyApp.LiveView, root_layout: MyApp.Layout)

  **Option Set 4: Custom Router**

      KinoPhoenixLiveview.new(path: "/proxy/apps/{slug}", router: MyApp.Router)

  **Option Set 5: Custom Endpoint**

      KinoPhoenixLiveview.new(path: "/proxy/apps/{slug}", endpoint: MyApp.Endpoint)

  **Note:** These option sets are mutually exclusive. For example, you should not mix `:live_view`
  with `:router` or `:endpoint` in the same call.

  ### Default Modules

    - **LiveView:** `KinoPhoenixLiveview.RootLive`
    - **Layout:** `KinoPhoenixLiveview.Layout`
    - **Router:** `KinoPhoenixLiveview.ProxyRouter`
    - **Endpoint:** `KinoPhoenixLiveview.ProxyEndpoint`
  """

  alias KinoPhoenixLiveview.{Iframe}

  @doc """
  Launches the Kino Phoenix LiveView integration using only a `:path`.

  This variant uses all the default modules for LiveView, layout, router, and endpoint.

  ## Parameters

    - `opts`: A keyword list with the required key `:path`.

  ## Examples

      KinoPhoenixLiveview.new(path: "/proxy/apps/{slug}")
  """
  def new(path: _ = opts) do
    init(Keyword.validate!(opts, [:path]))
  end

  @doc """
  Launches the integration with a custom LiveView module.

  Use this variant when you need to override the default LiveView module. Along
  with the required `:path`, provide the `:live_view` key.

  ## Parameters

    - `opts`: A keyword list with keys `:path` and `:live_view`.

  ## Examples

      KinoPhoenixLiveview.new(path: "/proxy/apps/{slug}", live_view: MyApp.LiveView)
  """
  def new([path: _, live_view: _] = opts) do
    init(Keyword.validate!(opts, [:path, :live_view]))
  end

  @doc """
  Launches the integration with a custom LiveView module and a custom layout.

  Use this variant when you need to override both the LiveView and the layout module.
  Provide the `:path`, `:live_view`, and `:root_layout` keys.

  ## Parameters

    - `opts`: A keyword list with keys `:path`, `:live_view`, and `:root_layout`.

  ## Examples

      KinoPhoenixLiveview.new(
        path: "/proxy/apps/{slug}",
        live_view: MyApp.LiveView,
        root_layout: MyApp.Layout
      )
  """
  def new([path: _, live_view: _, root_layout: _] = opts) do
    init(Keyword.validate!(opts, [:path, :live_view, :root_layout]))
  end

  @doc """
  Launches the integration with a custom router.

  Use this variant when you want to supply your own router to handle the request
  dispatching. Provide the `:path` and `:router` keys.

  ## Parameters

    - `opts`: A keyword list with keys `:path` and `:router`.

  ## Examples

      KinoPhoenixLiveview.new(path: "/proxy/apps/{slug}", router: MyApp.Router)
  """
  def new([path: _, router: _] = opts) do
    init(Keyword.validate!(opts, [:path, :router]))
  end

  @doc """
  Launches the integration with a custom endpoint.

  Use this variant when you want to provide your own Phoenix endpoint. Provide the
  `:path` and `:endpoint` keys.

  ## Parameters

    - `opts`: A keyword list with keys `:path` and `:endpoint`.

  ## Examples

      KinoPhoenixLiveview.new(path: "/proxy/apps/{slug}", endpoint: MyApp.Endpoint)
  """
  def new([path: _, endpoint: _] = opts) do
    init(Keyword.validate!(opts, [:path, :endpoint]))
  end

  @doc false
  # Internal function that initializes the LiveView integration.
  #
  # This function validates the complete set of options (merging defaults for any keys
  # not provided) and configures the application environment, starts the necessary
  # supervision tree, and launches the proxy endpoint along with an iframe widget.
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