defmodule Core.Messages.RabbitConsumer do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    queue = Keyword.fetch!(opts, :queue)

    send(self(), :connect)

    {:ok, %{queue: queue, conn: nil, chan: nil}}
  end

  @impl true
  def handle_info(:connect, state) do
    case AMQP.Connection.open() do
      {:ok, conn} ->
        Process.monitor(conn.pid)

        {:ok, chan} = AMQP.Channel.open(conn)
        AMQP.Queue.declare(chan, state.queue, durable: true)
        AMQP.Basic.consume(chan, state.queue)

        Logger.info("RabbitConsumer connected to #{state.queue}")

        {:noreply, %{state | conn: conn, chan: chan}}

      {:error, reason} ->
        Logger.error("RabbitMQ connect failed: #{inspect(reason)}")
        Process.send_after(self(), :connect, 5_000)
        {:noreply, state}
    end
  end

  @impl true
  def handle_info({:basic_consume_ok, %{consumer_tag: tag}}, state) do
    Logger.info("Consumer registered with tag #{tag}")
    {:noreply, state}
  end

  @impl true
  def handle_info({:basic_cancel, _meta}, state) do
    Logger.warning("Consumer cancelled by RabbitMQ")
    {:noreply, state}
  end

  @impl true
  def handle_info({:basic_cancel_ok, _meta}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _, :process, _pid, reason}, state) do
    Logger.warning("Rabbit connection lost: #{inspect(reason)}")
    send(self(), :connect)
    {:noreply, %{state | conn: nil, chan: nil}}
  end
end
