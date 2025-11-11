defmodule ConverterWeb.BatchLive.Index do
  use ConverterWeb, :live_view

  alias Converter.Batches
  alias Converter.Batches.Batch

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :batches, Batches.list_batches())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Batch")
    |> assign(:batch, Batches.get_batch!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Batch")
    |> assign(:batch, %Batch{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Batches")
    |> assign(:batch, nil)
  end

  @impl true
  def handle_info({ConverterWeb.BatchLive.FormComponent, {:saved, batch}}, socket) do
    {:noreply, stream_insert(socket, :batches, batch)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    batch = Batches.get_batch!(id)
    {:ok, _} = Batches.delete_batch(batch)

    {:noreply, stream_delete(socket, :batches, batch)}
  end
end
