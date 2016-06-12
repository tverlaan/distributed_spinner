defmodule DistributedSpinner.Member do
  use GenServer
  require Logger

  @timeout 5000

  defstruct [:identifier, :initialized]

  def start_link do
    GenServer.start_link __MODULE__, []
  end

  def init(_opts) do
    [id|_] = Node.self |> Atom.to_string |> String.split("@")

    send self, :join
    {:ok, %__MODULE__{identifier: id, initialized: false} }
  end

  def handle_info(:join, state) do
    Phoenix.Tracker.track DistributedSpinner.Tracker, self, "spinner", state.identifier, %{}
    Phoenix.PubSub.subscribe :dist_spinner, "spinner"

    {:noreply, state, @timeout}
  end

  def handle_info(:timeout, state) do
    # everything turned silent
    Phoenix.Tracker.list(DistributedSpinner.Tracker, "spinner")
    |> Enum.sort
    |> case do
        [{id, _} | _] = l when length(l) > 1 ->
          Phoenix.PubSub.broadcast :dist_spinner, "spinner", "init #{id}"
        _ ->
          :ok
      end
    {:noreply, %__MODULE__{ state | initialized: false}, @timeout}
  end

  def handle_info("init " <> id, %{identifier: id, initialized: false} = state) do
    Logger.debug "init #{id}"
    DistributedSpinner.Led.blink
    :timer.sleep 1000

    Phoenix.Tracker.list(DistributedSpinner.Tracker, "spinner")
    |> Enum.sort
    |> case do
        [_, {next, _} | _] ->
          Phoenix.PubSub.broadcast :dist_spinner, "spinner", "next #{next}"
        _ ->
          :ok
      end

    {:noreply, %__MODULE__{ state | initialized: true}, @timeout}
  end
  def handle_info("init " <> _, state), do: {:noreply, state, @timeout}

  def handle_info("next " <> next, %{identifier: next} = state) do
    Logger.debug "next #{next}"
    DistributedSpinner.Led.blink
    :timer.sleep 1000

    [{h,_}|t] = Phoenix.Tracker.list(DistributedSpinner.Tracker, "spinner") |> Enum.sort

    t
    |> Enum.sort
    |> Enum.find(fn({id, _}) ->
      if id > next do
        Phoenix.PubSub.broadcast :dist_spinner, "spinner", "next #{id}"
      else
        Phoenix.PubSub.broadcast :dist_spinner, "spinner", "next #{h}"
      end
    end)

    {:noreply, state, @timeout}
  end

  def handle_info("next " <> _, state), do: {:noreply, state, @timeout}
  def handle_info(msg, state) do


    {:noreply, state, @timeout}
  end



end
