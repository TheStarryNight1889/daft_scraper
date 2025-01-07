defmodule DaftScraper.FileWriter do
  require Logger
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def write(data) do
    GenServer.cast(__MODULE__, {:write, data})
  end

  def init(_) do
    {:ok, %{queue: :queue.new(), current_epoch: :os.system_time(:millisecond)}}
  end

  def handle_cast({:write, data}, %{queue: queue} = state) do
    queue = :queue.in(data, queue)
    Process.send_after(self(), :process_queue, 0)
    {:noreply, %{state | queue: queue}}
  end

  def handle_info(:process_queue, %{queue: queue, current_epoch: current_epoch} = state) do
    case :queue.out(queue) do
      {{:value, data}, new_queue} ->
        Task.start(fn ->
          Enum.each(data, fn listing ->
            encoded_data = Poison.encode!(listing)
            File.write!("./results/#{current_epoch}.jsonl", encoded_data <> "\n", [:append])
          end)

          Logger.info("Wrote data to file")
        end)

        Process.send_after(self(), :process_queue, 0)
        {:noreply, %{state | queue: new_queue}}

      {:empty, _} ->
        {:noreply, state}
    end
  end
end
