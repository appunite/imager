defmodule Imager.RunnerTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Imager.Runner, as: Subject

  @moduletag :exec

  test "streaming" do
    {pid, stream} = Subject.stream("cat")

    assert :ok = Subject.feed_stream(pid, ["foo"])
    assert ["foo"] == Enum.to_list(stream)
  end

  test "fails on non-existent command" do
    assert {:ok, pid} =
             start_supervised({Subject, pid: self(), cmd: "non-existent"})
  end

  test "what goes in goes out" do
    assert {:ok, pid} = run("cat")
    assert :ok = Subject.feed(pid, "foo")
    assert_receive {:out, ^pid, "foo"}
  end

  defp run(command, args \\ []),
    do: start_supervised({Subject, pid: self(), cmd: command, args: args})
end
