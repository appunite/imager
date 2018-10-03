defmodule Imager.Store.BlackholeTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Imager.Store.Blackhole, as: Subject

  property "retreive always return error" do
    check all path <- binary() do
      assert :error = Subject.retrieve(path, [])
    end
  end

  test "returns provided stream as is" do
    stream = Stream.interval(10)

    assert ^stream = Subject.store("", "", stream, [])
  end
end
