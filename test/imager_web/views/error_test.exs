defmodule ImagerWeb.Views.ErrorTest do
  use ExUnit.Case, async: true

  alias ImagerWeb.Views.Error, as: Subject

  import Phoenix.View, only: [render: 3]

  for code <- [404, 422, 500] do
    test "HTTP #{code} returns map with error field" do
      assert %{error: _} = render(Subject, unquote("#{code}.json"), %{})
    end
  end
end
