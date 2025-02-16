defmodule KinoPhoenixLiveview.Application do
  use Application

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
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, [name: KinoPhoenixLiveview.PubSub]},
      {Registry, [name: nil, keys: :unique]},
      Application.get_env(:kino_phoenix_live_view, :endpoint)
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
