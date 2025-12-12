defmodule Core.Messages.Rabbitmq do
  use GenServer

  ## --- Client API ---
  def start_link(%{queue: queue}) do
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Queue.declare(channel, queue, durable: true)
    GenServer.start_link(__MODULE__, %{chan: channel, queue: queue}, name: __MODULE__)
  end

  def publish_message(message), do: GenServer.cast(__MODULE__, {:publish, message})

  ## --- Server Callbacks ---
  @impl true
  def init(initial), do: {:ok, initial}

  @impl true
  def handle_cast({:publish, message}, %{chan: chan, queue: queue}) do
    AMQP.Basic.publish(chan, "", queue, message)
    {:noreply, %{chan: chan, queue: queue}}
  end
end
