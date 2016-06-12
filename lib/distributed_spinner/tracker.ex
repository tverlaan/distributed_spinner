defmodule DistributedSpinner.Tracker do
  @behaviour Phoenix.Tracker

  def start_link(opts) do
    opts = Keyword.merge([name: __MODULE__], opts)
    GenServer.start_link(Phoenix.Tracker, [__MODULE__, opts, opts], name: __MODULE__)
  end

  def init(opts) do
    server = Keyword.fetch!(opts, :pubsub_server)
    {:ok, %{pubsub_server: server, node_name: Phoenix.PubSub.node_name(server)}}
  end

  def handle_diff(_diff, state) do
    # for {topic, {joins, leaves}} <- diff do
    #   for {key, meta} <- joins do
    #     IO.puts "presence join: key \"#{key}\" with meta #{inspect meta}"
    #     Phoenix.PubSub.direct_broadcast(Node.self(), state.pubsub_server, topic, {:join, key, meta})
    #   end
    #   for {key, meta} <- leaves do
    #     IO.puts "presence leave: key \"#{key}\" with meta #{inspect meta}"
    #     Phoenix.PubSub.direct_broadcast(Node.self(), state.pubsub_server, topic, {:leave, key, meta})
    #   end
    # end
    {:ok, state}
  end
end
