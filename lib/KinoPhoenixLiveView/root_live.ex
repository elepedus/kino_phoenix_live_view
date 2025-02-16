defmodule KinoPhoenixLiveview.RootLive do
  @moduledoc """
  A simple Phoenix LiveView that demonstrates interactive state changes.

  This LiveView initializes with a boolean value and toggles it on button click.
  The current state is rendered, and clicking the "toggle" button switches the value.
  """

  use Phoenix.LiveView

  @doc """
  Mounts the LiveView and initializes the socket with a default value.

  ## Parameters

    - `_params`: The request parameters (unused).
    - `_session`: The session data (unused).
    - `socket`: The LiveView socket.

  ## Returns

    - `{:ok, socket}` with an initial assign `:value` set to `true`.
  """
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(value: true)}
  end

  @doc """
  Renders the LiveView template.

  Displays the current boolean value and a button to toggle the state.

  ## Parameters

    - `assigns`: A map of assigns including the current `:value`.

  ## Examples

      {@value}
      <button phx-click="toggle">toggle</button>
  """
  def render(assigns) do
    ~H"""
    {@value}
    <button class="border rounded bg-teal-100 p-2" phx-click="toggle">toggle</button>
    """
  end

  @doc """
  Handles the "toggle" event by flipping the boolean value.

  ## Parameters

    - `"toggle"`: The event name.
    - `_`: The event parameters (unused).
    - `socket`: The current LiveView socket.

  ## Returns

    - `{:noreply, socket}` with the updated `:value` assign.
  """
  def handle_event("toggle", _, socket) do
    {:noreply,
      socket
      |> assign(value: !socket.assigns.value)}
  end
end