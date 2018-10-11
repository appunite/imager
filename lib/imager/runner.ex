defmodule Imager.Runner do
  use GenServer, restart: :temporary

  require Logger

  defstruct [:output, :pid, :ospid]

  def stream(cmd, args \\ []) do
    {:ok, pid} =
      DynamicSupervisor.start_child(
        Imager.Workers,
        {__MODULE__, pid: self(), cmd: cmd, args: args}
      )

    ref = Process.monitor(pid)

    stream =
      Stream.resource(
        fn -> pid end,
        fn pid ->
          receive do
            {:out, ^pid, data} -> {[data], pid}
            {:DOWN, ^ref, :process, ^pid, status} -> {:halt, status}
          end
        end,
        fn _ -> nil end
      )

    {pid, stream}
  end

  def start_link(args), do: GenServer.start_link(__MODULE__, args)

  def wait(pid) do
    ref = Process.monitor(pid)

    receive do
      {:DOWN, ^ref, :process, ^pid, :normal} -> :ok
      {:DOWN, ^ref, :process, ^pid, _} -> :error
    end
  end

  def feed_stream(pid, stream) do
    Enum.each(stream, &feed(pid, &1))

    feed(pid, :eof)
  end

  def feed(pid, data) when is_binary(data) or data == :eof,
    do: GenServer.call(pid, {:in, data})

  def init(opts) do
    output = Keyword.fetch!(opts, :pid)
    cmd = Keyword.fetch!(opts, :cmd)
    cmd = System.find_executable(cmd) || cmd
    args = Keyword.get(opts, :args, [])
    exec = Enum.map([cmd | args], &String.to_charlist/1)

    {:ok, pid, ospid} = :exec.run(exec, [:stdin, :stdout, :stderr, :monitor])

    Process.sleep(100)

    {:ok, %__MODULE__{output: output, pid: pid, ospid: ospid}}
  end

  def handle_call({:in, data}, _ref, %__MODULE__{ospid: pid} = state) do
    {:reply, :exec.send(pid, data), state}
  end

  def handle_info(
        {:stdout, ospid, data},
        %__MODULE__{output: output, ospid: ospid} = state
      ) do
    send(output, {:out, self(), data})

    {:noreply, state}
  end

  def handle_info(
        {:stderr, ospid, data},
        %__MODULE__{ospid: ospid} = state
      ) do
    Logger.warn(inspect(data))

    {:noreply, state}
  end

  def handle_info(
        {:DOWN, ospid, :process, pid, result},
        %__MODULE__{pid: pid, ospid: ospid} = state
      ) do
    {:stop, result, state}
  end
end
