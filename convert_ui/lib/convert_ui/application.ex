defmodule ConvertUi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ConvertUiWeb.Telemetry,
      ConvertUi.Repo,
      {DNSCluster, query: Application.get_env(:convert_ui, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ConvertUi.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ConvertUi.Finch},
      # Start a worker by calling: ConvertUi.Worker.start_link(arg)
      # {ConvertUi.Worker, arg},
      # Start to serve requests, typically the last entry
      ConvertUiWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ConvertUi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ConvertUiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
