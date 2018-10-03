defmodule Imager.StatsTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  property "tags contain all provided entries" do
    check all tags <- list_of(string(:alphanumeric)) do
      generated = Imager.Stats.tags(tags)

      for tag <- tags do
        assert tag in generated
      end
    end
  end

  property "tags contains default tags" do
    check all tags <- list_of(string(:alphanumeric)) do
      generated = Imager.Stats.tags(tags)

      assert "app:imager" in generated
      assert Enum.find(generated, fn
        "version:" <> _ -> true
        _ -> false
      end)
    end
  end
end
