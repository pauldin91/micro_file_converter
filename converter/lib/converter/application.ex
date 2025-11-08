defmodule Converter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ConverterWeb.Telemetry,
      Converter.Repo,
      {DNSCluster, query: Application.get_env(:converter, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Converter.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Converter.Finch},
      # Start a worker by calling: Converter.Worker.start_link(arg)
      # {Converter.Worker, arg},
      # Start to serve requests, typically the last entry
      ConverterWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Converter.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ConverterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
