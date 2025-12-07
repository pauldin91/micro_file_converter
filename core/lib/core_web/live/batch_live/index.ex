defmodule CoreWeb.BatchLive.Index do
  use CoreWeb, :live_view

  alias Core.Uploads
  alias Core.Uploads.Batch

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :batches, Uploads.list_batches())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Batch")
    |> assign(:batch, Uploads.get_batch!(id))
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
  def handle_info({CoreWeb.BatchLive.FormComponent, {:saved, batch}}, socket) do
    {:noreply, stream_insert(socket, :batches, batch)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    batch = Uploads.get_batch!(id)
    {:ok, _} = Uploads.delete_batch(batch)

    {:noreply, stream_delete(socket, :batches, batch)}
  end
end
