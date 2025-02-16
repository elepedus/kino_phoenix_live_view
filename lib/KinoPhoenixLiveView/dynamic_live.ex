defmodule KinoPhoenixLiveview.DynamicLive do
  @moduledoc """
  A dynamic LiveView module that delegates all callbacks to another LiveView.

  The delegated LiveView is determined at runtime via application configuration
  (`:kino_phoenix_live_view, :live_view`). This allows for swapping or extending
  LiveView behavior without modifying this module.
  """

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

  @doc false
  # Retrieves the LiveView module to delegate to from the application environment.
  defp delegate_live_view do
    Application.get_env(:kino_phoenix_live_view, :live_view)
  end
end