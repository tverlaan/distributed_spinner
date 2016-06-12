defmodule DistributedSpinner.Led do
  require Logger
  use GenServer
  alias Nerves.IO.Led

  @led :green

  def blink do
    GenServer.cast __MODULE__, :blink
  end

  def start_link do
    GenServer.start_link __MODULE__, [], name: __MODULE__
  end

  def handle_cast(:blink, s) do
    Led.set [{@led, true}]
    :timer.sleep 1000
    Led.set [{@led, false}]

    {:noreply, s}
  end

end
