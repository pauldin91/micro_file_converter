defmodule CoreWeb.BatchLive.Index do
  use CoreWeb, :live_view

  alias Core.Uploads
  alias Core.Uploads.Batch
  alias Core.Items
  alias Core.Items.Picture

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Uploads.subscribe()

    {:ok,
     stream(socket, :batches, Uploads.list_batches())
     |> assign(:form, to_form(Items.change_picture(%Picture{})))
     |> assign(:processing, false)
     |> assign(:metadata, nil)
     |> assign(:transform, nil)
     |> assign(:batch_id, nil)
     |> assign(:batch, %Batch{})}
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

  # @impl true
  # def handle_info({CoreWeb.BatchLive.FormComponent, {:saved, batch}}, socket) do
  #   {:noreply, stream_insert(socket, :batches, batch)}
  # end

  @impl true

  def handle_info({:processing_complete, guid}, socket) do
    {:noreply,
     socket
     |> assign(:processing, false)
     |> put_flash(:info, "Processing complete for #{guid}")}
  end

  # Some code paths send the message wrapped by the component module name:
  @impl true
  def handle_info({CoreWeb.BatchLive.FormComponent, {:processing_complete, guid}}, socket) do
    handle_info({:processing_complete, guid}, socket)
  end

  @impl true
  def handle_info({CoreWeb.BatchLive.FormComponent, {:close}}, socket) do
    {:noreply,
     socket
     |> assign(:processing, false)
     |> put_flash(:info, "Processing complete for #{socket.assigns.batch_id}")}
  end

  def handle_info({:batch_created, batch}, socket) do
    {:noreply, stream_insert(socket, :batches, batch)}
  end

  def handle_info({:batch_updated, batch}, socket) do
    {:noreply, stream_insert(socket, :batches, batch)}
  end

  def handle_info({:batch_deleted, item}, socket) do
    {:noreply, stream_delete(socket, :batches, item)}
  end

  @impl true
  @spec handle_event(<<_::48>>, map(), Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_event("delete", %{"id" => id}, socket) do
    batch = Uploads.get_batch!(id)
    {:ok, _} = Uploads.delete_batch(batch)

    {:noreply, stream_delete(socket, :batches, batch)}
  end
end
