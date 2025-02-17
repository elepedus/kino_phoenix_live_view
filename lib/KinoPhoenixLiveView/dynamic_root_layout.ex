defmodule KinoPhoenixLiveView.DynamicRootLayout do
  @moduledoc """
  A plug that dynamically sets the root layout for Phoenix controllers.

  It retrieves the root layout module from the application environment
  (defaulting to `KinoPhoenixLiveView.Layout`) and assigns it to the connection.
  """

  @doc """
  Initializes the plug options.

  This plug does not require any special options.

  ## Parameters

    - `opts`: The plug options.

  ## Returns

    - The unchanged options.
  """
  def init(opts), do: opts

  @doc """
  Sets the root layout for the connection dynamically.

  It fetches the layout from the application configuration and updates the
  connection using `Phoenix.Controller.put_root_layout/2`.

  ## Parameters

    - `conn`: The connection struct.
    - `_opts`: Unused options.

  ## Returns

    - The updated connection.
  """
  def call(conn, _opts) do
    layout =
      Application.get_env(
        :kino_phoenix_live_view,
        :root_layout,
        KinoPhoenixLiveView.Layout
      )

    Phoenix.Controller.put_root_layout(conn, html: {layout, :root})
  end
end