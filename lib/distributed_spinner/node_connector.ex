defmodule DistributedSpinner.NodeConnector do
  require Logger
  use GenServer

  def start_link do
    opts = get_nodes()
    GenServer.start_link __MODULE__, opts, name: __MODULE__
  end

  def init(list) do
    send self, {:connect, list}
    {:ok, []}
  end

  def handle_info({:connect, list}, []) do
    for l <- list do
      Node.connect(l)
    end
    {:noreply, Node.list(), 5000}
  end

  def handle_info(_,[]) do
    for l <- get_nodes() do
      Node.connect(l)
    end
    {:noreply, Node.list(), 5000}
  end

  def handle_info(_,_) do
    {:noreply, Node.list(), 5000}
  end

  defp get_nodes do
    Application.get_env(:distributed_spinner, :initial_nodes, [])
  end

end
