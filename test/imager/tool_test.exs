defmodule Imager.ToolTest do
  use ExUnit.Case, async: true

  alias Imager.Tool

  doctest Tool

  describe "result path" do
    test "returns proper MIME" do
      assert {"image/png", _} = Tool.result("/file.png", [])
      # Defaults to PNG
      assert {"image/png", _} = Tool.result("/file.jpg", [])

      assert {"image/jpeg", _} = Tool.result("/file.jpg", [format: "jpg"])
    end

    test "creates joined path with commands" do
      assert {_, "/file_strip_thumbnail-190x190.png"} = Tool.result("/file.png", [
        strip: true,
        thumbnail: "190x190"
      ])
    end

    test "creates proper path for each command" do
      for cmd <- ~w(strip flatten)a do
        {_, filename} = Tool.result("/file.png", [{cmd, true}])

        assert String.contains?(filename, "_#{cmd}.")
      end

      for cmd <- ~w(background extent gravity thumbnail)a do
        {_, filename} = Tool.result("/file.png", [{cmd, "foo"}])

        assert String.contains?(filename, "_#{cmd}-foo.")
      end
    end
  end
end
