# KinoPhoenixLiveView

[KinoPhoenixLiveView](https://hexdocs.pm/kino) allows you to embed Phoenix LiveView applications
within [Livebook](https://livebook.dev) as interactive Kino widgets. It abstracts away the complexity of setting up a
full Phoenix endpoint by providing a simple interface with pre-configured option sets.

## Installation in Livebook

Install using `mix.install/1`.

```elixir
mix.install([
  {:kino_phoenix_liveview, "~> 0.1.0"}
])
```

## Usage

The primary interface is the KinoPhoenixLiveView.new/1 function. This function starts a proxy endpoint that serves your
LiveView inside an iframe, then returns a Kino widget that you can render in Livebook. Every call must include a :path
option. You can also override the default LiveView, layout, router, or endpoint if needed.

### Option Set 1: Only Path (Use All Defaults)

Uses default modules for LiveView, layout, router, and endpoint.

```elixir
KinoPhoenixLiveView.new(path: "/proxy/apps/my_app")
```

### Option Set 2: Custom LiveView

Override the default LiveView module.

```elixir
KinoPhoenixLiveView.new(path: "/proxy/apps/my_app", live_view: MyApp.LiveView)
```

### Option Set 3: Custom LiveView and Layout

Customize both the LiveView module and the layout.

```elixir
KinoPhoenixLiveView.new(
  path: "/proxy/apps/my_app",
  live_view: MyApp.LiveView,
  root_layout: MyApp.Layout
)
```

### Option Set 4: Custom Router

Provide your own router for request dispatching.

```elixir
KinoPhoenixLiveView.new(path: "/proxy/apps/my_app", router: MyApp.Router)
```

### Option Set 5: Custom Endpoint

Use a custom Phoenix endpoint.

```elixir
KinoPhoenixLiveView.new(path: "/proxy/apps/my_app", endpoint: MyApp.Endpoint)
``` 

## Default Modules

If not overridden, the following defaults are used:
• LiveView: KinoPhoenixLiveView.RootLive
• Layout: KinoPhoenixLiveView.Layout
• Router: KinoPhoenixLiveView.ProxyRouter
• Endpoint: KinoPhoenixLiveView.ProxyEndpoint

## How It Works

KinoPhoenixLiveView simplifies embedding LiveView in Livebook by:

1. Configuration: Validating and merging your options with sensible defaults.
2. Environment Setup: Configuring the necessary application environment for your LiveView.
3. Process Supervision: Starting a minimal supervision tree to support the LiveView proxy.
4. Proxy Endpoint: Launching a proxy endpoint that serves your LiveView via an iframe.
5. Iframe Widget: Returning a Kino widget that displays your LiveView inside Livebook.

## Example Notebook

Below is a minimal example of how to use KinoPhoenixLiveView in a Livebook notebook:

```elixir
# Install the dependency (run this cell first)
mix.install([
  {:kino_phoenix_liveview, "~> 0.1.2"}
])

# Launch the LiveView in an iframe using the default settings.
KinoPhoenixLiveView.new(path: "/proxy/apps/my_app")
````

## Contributing

Contributions are welcome! Please open an issue or submit a pull request if you have ideas, bug fixes, or improvements.

## License

This project is licensed under the MIT License. 