defmodule ImagerWeb.Views.Error do
  use Phoenix.View, root: "lib/imager_web/templates"

  @moduledoc false

  def render("500.json", _), do: %{error: "Internal server error"}
  def render("404.json", _), do: %{error: "Non existent page"}
  def render("422.json", _), do: %{error: "Cannot parse arguments"}
end
