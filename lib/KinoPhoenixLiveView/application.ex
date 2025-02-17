defmodule KinoPhoenixLiveView.Application do
  @moduledoc """
  The main application module for the Kino Phoenix LiveView integration.

  This module defines the application supervision tree, which includes
  a PubSub server, a Registry, and the configured endpoint. It is responsible
  for starting all necessary processes for the LiveView proxy.
  """

  use Application

  @doc """
  Defines the child specification for the application.

  This specification is used by the supervisor to start the application.
  """
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
  @doc """
  Starts the application supervision tree.

  It starts a PubSub server, a Registry, and the configured Phoenix endpoint.

  ## Parameters

    - `_type`: The type of start (ignored).
    - `_args`: The start arguments (ignored).

  ## Returns

    - `{:ok, pid}` on successful startup.
  """
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, [name: KinoPhoenixLiveView.PubSub]},
      {Registry, [name: nil, keys: :unique]},
      Application.get_env(:kino_phoenix_live_view, :endpoint)
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end