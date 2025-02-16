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
