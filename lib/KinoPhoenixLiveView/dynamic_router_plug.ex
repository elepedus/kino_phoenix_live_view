defmodule KinoPhoenixLiveview.DynamicRouterPlug do
  @moduledoc """
  A plug that dynamically dispatches requests to a router defined in the application
  configuration.

  This plug retrieves the router from the application environment and invokes its
  `call/2` function to handle the request.
  """

  @behaviour Plug

  @doc """
  Initializes the plug with the given options.

  ## Parameters

    - `opts`: The plug options.

  ## Returns

    - The unchanged options.
  """
  @impl true
  def init(opts), do: opts

  @doc """
  Delegates the connection to the dynamically configured router.

  It fetches the router module from the application environment and invokes its
  `call/2` callback.

  ## Parameters

    - `conn`: The connection struct.
    - `_opts`: Unused options.

  ## Returns

    - The updated connection after the router has processed it.
  """
  @impl true
  def call(conn, _opts) do
    router = Application.get_env(:kino_phoenix_live_view, :router)
    router.call(conn, router.init([]))
  end
end