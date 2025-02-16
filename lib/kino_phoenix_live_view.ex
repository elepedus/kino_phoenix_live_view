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

defmodule KinoPhoenixLiveview.Layout do
  use Phoenix.Component
  alias KinoPhoenixLiveview.ProxyEndpoint

  def render("root.html", assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en" class="h-full">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <.live_title>
          <%= assigns[:page_title] || "Phoenix Playground" %>
        </.live_title>
        <link rel="icon" href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/wcAAgAB/ajN8ioAAAAASUVORK5CYII=">
      </head>
      <body>
        <script src={ProxyEndpoint.static_path("/assets/phoenix/phoenix.js")}></script>
        <script src={ProxyEndpoint.static_path("/assets/phoenix_live_view/phoenix_live_view.js")}></script>
        <script src="https://cdn.tailwindcss.com"></script>
        <script>
          // Set global hooks and uploaders objects to be used by the LiveSocket,
          // so they can be overwritten in user provided templates.
          window.hooks = {}
          window.uploaders = {}

           let liveSocket =
            new window.LiveView.LiveSocket(
              "<%= ProxyEndpoint.static_path("/proxylive") %>",
              window.Phoenix.Socket,
              { hooks, uploaders, transport: window.Phoenix.LongPoll }
            )
          liveSocket.connect()
        </script>
        <div class="container mx-auto">
          <%= @inner_content %>
        </div>
      </body>
    </html>
    """
  end
end

defmodule KinoPhoenixLiveview.ErrorView do
  def render(template, _), do: Phoenix.Controller.status_message_from_template(template)
end

defmodule KinoPhoenixLiveview.RootLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(value: true)}
  end

  def render(assigns) do
    ~H"""
    {@value}
    <button class="border rounded bg-teal-100 p-2" phx-click="toggle">toggle</button>
    """
  end

  def handle_event("toggle", _, socket) do
    {:noreply,
      socket
      |> assign(value: !socket.assigns.value)}
  end
end

defmodule KinoPhoenixLiveview.DynamicLive do
  use Phoenix.LiveView

  @impl true
  def mount(params, session, socket) do
    delegate_live_view().mount(params, session, socket)
  end

  @impl true
  def render(assigns) do
    delegate_live_view().render(assigns)
  end

  @impl true
  def handle_event(event, params, socket) do
    delegate_live_view().handle_event(event, params, socket)
  end

  @impl true
  def handle_info(msg, socket) do
    delegate_live_view().handle_info(msg, socket)
  end

  defp delegate_live_view do
    Application.get_env(:kino_phoenix_live_view, :live_view)
  end
end

defmodule KinoPhoenixLiveview.DynamicRootLayout do
  def init(opts), do: opts

  def call(conn, _opts) do
    layout =
      Application.get_env(
        :kino_phoenix_live_view,
        :root_layout,
        KinoPhoenixLiveview.Layout
      )

    Phoenix.Controller.put_root_layout(conn, html: {layout, :root})
  end
end

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

defmodule KinoPhoenixLiveview.DynamicRouterPlug do
  @behaviour Plug


  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    router = Application.get_env(:kino_phoenix_live_view, :router)
    router.call(conn, router.init([]))
  end
end

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

defmodule KinoPhoenixLiveview.Application do
  use Application

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start, [nil, opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  @impl Application
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, [name: KinoPhoenixLiveview.PubSub]},
      {Registry, [name: nil, keys: :unique]},
      Application.get_env(:kino_phoenix_live_view, :endpoint)
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end

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

    #

    Application.put_env(:kino_phoenix_live_view, :live_view, opts[:live_view])
    Application.put_env(:kino_phoenix_live_view, :root_layout, opts[:root_layout])
    Application.put_env(:kino_phoenix_live_view, :router, opts[:router])
    Application.put_env(:kino_phoenix_live_view, :endpoint, opts[:endpoint])

    Kino.start_child!(KinoPhoenixLiveview.Application)
    Kino.Proxy.listen(opts[:endpoint])
    Iframe.start(endpoint: opts[:endpoint])
  end
end