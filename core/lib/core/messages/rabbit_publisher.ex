defmodule Core.Messages.RabbitPublisher do
  use GenServer

  ## --- Client API ---

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def publish_message(message), do: GenServer.cast(__MODULE__, {:publish, message})

  ## --- Server Callbacks ---
  @impl true
  def init(opts) do
    queue = Keyword.get(opts, :queue)
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Queue.declare(channel, queue, durable: true)

    {
      :ok,
      %{chan: channel, queue: queue}
    }
  end

  @impl true
  def handle_cast({:publish, message}, %{chan: chan, queue: queue}) do
    AMQP.Basic.publish(chan, "", queue, message)
    {:noreply, %{chan: chan, queue: queue}}
  end
end
