defmodule ConverterWeb.BatchLive.Show do
  use ConverterWeb, :live_view

  alias Converter.Batches

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:batch, Batches.get_batch!(id))}
  end

  defp page_title(:show), do: "Show Batch"
  defp page_title(:edit), do: "Edit Batch"
end
