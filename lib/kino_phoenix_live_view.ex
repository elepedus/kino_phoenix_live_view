defmodule KinoPhoenixLiveView do
  @moduledoc """
  Provides a simple interface for launching a Phoenix LiveView within a Kino widget.

  This module handles the configuration and startup of a proxy endpoint that
  serves your LiveView inside an iframe. It abstracts away the complexity of setting
  up a full Phoenix endpoint by offering a few preset option combinations.

  ## Usage

  Call `KinoPhoenixLiveView.new/1` with one of the following option sets:

    1. **Only Path (Use All Defaults)**
       ```elixir
       KinoPhoenixLiveView.new(path: "/proxy/apps/{slug}")
       ```

    2. **Custom LiveView**
       ```elixir
       KinoPhoenixLiveView.new(path: "/proxy/apps/{slug}", live_view: MyApp.LiveView)
       ```

    3. **Custom LiveView and Layout**
       ```elixir
       KinoPhoenixLiveView.new(path: "/proxy/apps/{slug}", live_view: MyApp.LiveView, root_layout: MyApp.Layout)
       ```

    4. **Custom Router**
       ```elixir
       KinoPhoenixLiveView.new(path: "/proxy/apps/{slug}", router: MyApp.Router)
       ```

    5. **Custom Endpoint**
       ```elixir
       KinoPhoenixLiveView.new(path: "/proxy/apps/{slug}", endpoint: MyApp.Endpoint)
       ```
  """

  alias KinoPhoenixLiveView.Iframe

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
  @spec new(path: String.t()) :: any
  @spec new(path: String.t(), live_view: module()) :: any
  @spec new(path: String.t(), live_view: module(), root_layout: module()) :: any
  @spec new(path: String.t(), router: module()) :: any
  @spec new(path: String.t(), endpoint: module()) :: any
  def new(opts) when is_list(opts) do
    path = Keyword.get(opts, :path)
    endpoint = Keyword.get(opts, :endpoint)
    router = Keyword.get(opts, :router)
    live_view = Keyword.get(opts, :live_view)
    root_layout = Keyword.get(opts, :root_layout)

    unless path do
      raise ArgumentError, "Missing required option :path"
    end

    if endpoint do
      with {:error, extra} <- Keyword.validate(opts, [:path, :endpoint]) do
        raise ArgumentError,
              "Invalid config. Custom endpoint overrides #{inspect(extra)} option(s)."
      end
    end

    if router do
      with {:error, extra} <- Keyword.validate(opts, [:path, :router]) do
        raise ArgumentError,
              "Invalid config. Custom router overrides #{inspect(extra)} option(s)."
      end
    end

    init(opts)
  end

  @doc false
  defp init(opts) do
    opts =
      Keyword.validate!(opts, [
        :path,
        live_view: KinoPhoenixLiveView.RootLive,
        root_layout: KinoPhoenixLiveView.Layout,
        router: KinoPhoenixLiveView.ProxyRouter,
        endpoint: KinoPhoenixLiveView.ProxyEndpoint
      ])

    Application.put_env(:kino_phoenix_live_view, opts[:endpoint],
      server: false,
      adapter: Bandit.PhoenixAdapter,
      live_view: [signing_salt: "aasdffas"],
      secret_key_base: String.duplicate("a", 64),
      pubsub_server: KinoPhoenixLiveView.PubSub,
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

    Kino.start_child!(KinoPhoenixLiveView.Application)
    Kino.Proxy.listen(opts[:endpoint])
    Iframe.start(endpoint: opts[:endpoint])
  end
end
