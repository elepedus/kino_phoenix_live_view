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
