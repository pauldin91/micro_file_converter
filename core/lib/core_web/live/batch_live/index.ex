defmodule CoreWeb.BatchLive.Index do
  use CoreWeb, :live_view

  alias Core.Uploads
  alias Core.Handlers
  alias Core.Uploads.Batch
  alias Core.Items
  alias Core.Items.Picture

  @transformations [
    {"None", :none},
    {"90°", :rot_90},
    {"180°", :rot_180},
    {"270°", :rot_270},
    {"Mirror", :mirror}
  ]

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Uploads.subscribe()
      Phoenix.PubSub.subscribe(Core.PubSub, "batch:processed")
    end

    user = socket.assigns.current_user

    {:ok,
     stream(socket, :batches, Uploads.list_batches_of_user(user.id))
     |> assign(:form, to_form(Items.change_picture(%Picture{})))
     |> assign(:transform, nil)
     |> assign(:transformations, @transformations)
     |> assign(:batch_id, nil)
     |> assign(:batch, %Batch{})}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, "Batch")
    |> assign(:batch, Uploads.get_batch!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Batch")
    |> assign(:batch, %Batch{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Uploads")
    |> assign(:batch, nil)
  end

  @impl true
  def handle_info({:batch_processed, batch_id}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Processing complete for #{batch_id}")}
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
  def handle_info({:batches_purged, count}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "#{count} total batches purged")
     |> stream(:batches, [], reset: true)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    batch = Uploads.get_batch!(id)

    case batch.user_id == socket.assign.current_user.id do
      true ->
        with {:ok, _} <- Uploads.delete_batch(batch) do
          {:noreply, stream_delete(socket, :batches, batch)}
        end

      false ->
        {:noreply, socket |> put_flash(:error, "Invalid operation")}
    end
  end

  @impl true
  def handle_event("purge", _params, socket) do
    Handlers.purge_user_batches(socket.assigns.current_user.id)

    {
      :noreply,
      socket
      |> stream(:batches, [])
    }
  end
end
