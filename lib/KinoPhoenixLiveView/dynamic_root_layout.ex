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
