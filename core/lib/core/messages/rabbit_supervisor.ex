defmodule Core.Messages.RabbitSupervisor do
  use Supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    children = [
      %{
        id: Core.Messages.RabbitPublisher,
        start:
          {Core.Messages.RabbitPublisher, :start_link,
           [
             [
               name: Core.Messages.RabbitPublisher
             ]
           ]},
        restart: :permanent,
        shutdown: 10_000
      },
      %{
        id: Core.Messages.RabbitConsumer,
        start:
          {Core.Messages.RabbitConsumer, :start_link,
           [
             [
               queue: Application.fetch_env!(:core, :processed_queue),
               name: Core.Messages.RabbitConsumer
             ]
           ]},
        restart: :permanent,
        shutdown: 10_000
      }
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
