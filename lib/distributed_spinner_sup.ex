defmodule DistributedSpinner.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do

    if_eth0 = Application.get_env(:distributed_spinner, :if_eth0) || []

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(Phoenix.PubSub.PG2, [:dist_spinner, [pool_size: 1]]),
      worker(Nerves.Networking, [:eth0, if_eth0], function: :setup),
      worker(DistributedSpinner.Tracker, [[name: DistributedSpinner.Tracker, pubsub_server: :dist_spinner]]),
      worker(DistributedSpinner.Member, []),
      worker(DistributedSpinner.Led, []),
      worker(DistributedSpinner.NodeConnector, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one]
    supervise(children, opts)
  end

end
