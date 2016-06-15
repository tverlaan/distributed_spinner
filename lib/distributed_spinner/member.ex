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
    DistributedSpinner.Tracker.list("spinner")
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

    DistributedSpinner.Tracker.list("spinner")
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

  def handle_info("next " <> id, %{identifier: id} = state) do
    Logger.debug "next #{id}"
    DistributedSpinner.Led.blink
    :timer.sleep 1000

    [{h,_}|t] = DistributedSpinner.Tracker.list("spinner") |> Enum.sort

    next = Enum.find(t, fn({n, _}) -> (n > id) == true end)

    if is_nil(next) do
      Phoenix.PubSub.broadcast :dist_spinner, "spinner", "next #{h}"
    else
      {n_id, _} = next
      Phoenix.PubSub.broadcast :dist_spinner, "spinner", "next #{n_id}"
    end

    {:noreply, state, @timeout}
  end

  def handle_info("next " <> _, state), do: {:noreply, state, @timeout}
  def handle_info(msg, state) do


    {:noreply, state, @timeout}
  end



end
