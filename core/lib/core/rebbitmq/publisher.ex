defmodule Core.RabbitMq.Publisher do
  use GenServer

  ## --- Client API ---

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def publish_message(queue, message), do: GenServer.cast(__MODULE__, {:publish, queue, message})

  ## --- Server Callbacks ---
  @impl true
  def init(_opts) do
    queues = Application.fetch_env!(:core, :processing_queues)
    host = Application.fetch_env!(:core, :rabbitmq_host)
    {:ok, connection} = AMQP.Connection.open(host)
    {:ok, channel} = AMQP.Channel.open(connection)

    Enum.each(queues, fn queue ->
      AMQP.Queue.declare(channel, queue, durable: true)
    end)

    {
      :ok,
      %{chan: channel}
    }
  end

  @impl true
  def handle_cast({:publish, queue, message}, %{chan: chan}) do
    AMQP.Basic.publish(chan, "", queue, message)
    {:noreply, %{chan: chan}}
  end
end
