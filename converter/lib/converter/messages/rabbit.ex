defmodule Converter.Messages.Rabbit do
  @queue "convert_files"
  require Logger

  def publish_conversion_request(batch_id, file_paths) do
    {:ok, conn} = AMQP.Connection.open()
    {:ok, chan} = AMQP.Channel.open(conn)
    AMQP.Queue.declare(chan, @queue, durable: true)

    payload = Jason.encode!(%{batch_id: batch_id, files: file_paths})
    AMQP.Basic.publish(chan, "", @queue, payload)

    Logger.info("Published conversion job for #{batch_id}")

    AMQP.Connection.close(conn)
  end
end
