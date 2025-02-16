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
