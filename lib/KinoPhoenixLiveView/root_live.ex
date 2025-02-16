defmodule KinoPhoenixLiveview.RootLive do
  @moduledoc """
  The default LiveView for KinoPhoenixLiveview, used both to verify LiveView interactions
  and to guide developers on how to customize the integration.

  This LiveView displays a simple toggle button along with instructions on how to:
    - Replace the default LiveView with a custom one.
    - Override the layout by providing a custom module.
    - Override the router or endpoint.

  Developers can use these instructions as a starting point to build their own LiveView experience.
  """

  use Phoenix.LiveView

  @doc """
  Mounts the LiveView and initializes the socket with a default boolean state.

  ## Parameters

    - `_params`: Request parameters (unused).
    - `_session`: Session data (unused).
    - `socket`: The LiveView socket.

  ## Returns

    - `{:ok, socket}` with the assign `:value` set to `true`.
  """
  def mount(_params, _session, socket) do
    {:ok, assign(socket, value: true)}
  end

  @doc """
  Renders the default LiveView template.

  The template includes:
    - A welcome header.
    - Instructions on how to replace or customize the default LiveView, layout, router, or endpoint.
    - A display of the current boolean state.
    - A button to toggle the state for testing interactivity.

  ## Parameters

    - `assigns`: A map containing the LiveView assigns, including `:value`.

  ## Example

      <h1>Welcome to KinoPhoenixLiveview!</h1>
      <p>Current value: true</p>
      <button phx-click="toggle">Toggle Value</button>
  """
  def render(assigns) do
    ~H"""
    <div class="p-6 space-y-4">
      <h1 class="text-2xl font-bold">Welcome to KinoPhoenixLiveview!</h1>
      <p>
        This default LiveView is provided to help you test your Kino integration and get started.
      </p>
      <div class="border p-4 rounded bg-gray-100">
        <h2 class="text-xl font-semibold">Customization Instructions</h2>
        <ul class="list-disc ml-6">
          <li>
            Replace this default LiveView with your own by passing a custom module via the <code>:live_view</code> option.
          </li>
          <li>
            Customize the layout by providing your own module using the <code>:root_layout</code> option.
          </li>
          <li>
            Override the router or endpoint by supplying custom modules with the <code>:router</code> or <code>:endpoint</code> options.
          </li>
        </ul>
      </div>
      <div class="space-y-2">
        <p>
          Current value: <strong>{@value}</strong>
        </p>
        <button class="border rounded bg-teal-100 p-2" phx-click="toggle">
          Toggle Value
        </button>
      </div>
    </div>
    """
  end

  @doc """
  Handles the "toggle" event by flipping the boolean state.

  When the button is clicked, the LiveView toggles the value of `:value`.

  ## Parameters

    - `"toggle"`: The event name.
    - `_params`: The event parameters (unused).
    - `socket`: The LiveView socket.

  ## Returns

    - `{:noreply, socket}` with the updated `:value` assign.
  """
  def handle_event("toggle", _params, socket) do
    {:noreply, assign(socket, value: !socket.assigns.value)}
  end
end