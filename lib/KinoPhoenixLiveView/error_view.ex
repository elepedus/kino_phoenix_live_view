defmodule KinoPhoenixLiveview.ErrorView do
  @moduledoc """
  A minimal error view module for rendering error messages.

  This view simply converts a given error template to a human-readable
  status message using Phoenix's built-in functions.
  """

  @doc """
  Renders an error message based on the template.

  ## Parameters

    - `template`: The error template identifier (e.g., "404.html").
    - `_`: Unused assigns.

  ## Returns

    - A string message corresponding to the HTTP status.
  """
  def render(template, _), do: Phoenix.Controller.status_message_from_template(template)
end