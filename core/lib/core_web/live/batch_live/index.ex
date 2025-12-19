defmodule CoreWeb.BatchLive.Index do
  use CoreWeb, :live_view

  alias Core.Uploads
  alias Core.Storage
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

    {:ok,
     stream(socket, :batches, Uploads.list_batches())
     |> assign(:form, to_form(Items.change_picture(%Picture{})))
     |> assign(:metadata, nil)
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
    |> assign(:page_title, "Listing Batches")
    |> assign(:batch, nil)
  end

  @impl true
  def handle_info({:batch_processed, payload}, socket) do
    metadata = Jason.decode!(payload)
    guid = metadata["batch_id"]

    {:noreply,
     socket
     |> put_flash(:info, "Processing complete for #{guid}")}
  end

  @impl true
  def handle_info({:save_batch, params, batch_id, uploads}, socket) do
    upload_dir = Application.fetch_env!(:core, :uploads_dir)
    user = socket.assigns.current_user

    dbg(user)
    dbg(user.id)

    transform =
      get_in(params, ["batch", "transform"]) || :none

    {:ok, batch} =
      Uploads.create_batch(%{
        status: "pending",
        transform: transform,
        id: batch_id,
        user_id: user.id
      })

    Enum.each(uploads, fn entry ->
      dest = Path.join([upload_dir, batch.id, entry.client_name])

      {:ok, _picture} =
        Items.create_picture(%{
          batch_id: batch_id,
          name: entry.client_name,
          size: File.stat!(dest).size
        })
    end)

    if uploads != [] do
      metadata = Storage.save_files(batch.id, uploads)

      metadata =
        metadata
        |> Map.put(:transform, params["batch"]["transform"])

      queue =
        cond do
          transform == :none -> Application.fetch_env!(:core, :processing_queues) |> Enum.at(0)
          true -> Application.fetch_env!(:core, :processing_queues) |> Enum.at(1)
        end

      Core.Messages.RabbitPublisher.publish_message(queue, Jason.encode!(metadata))

      {:noreply,
       socket
       |> assign(:batch_id, batch.id)
       |> assign(:metadata, metadata)
       |> assign(:uploaded_files, uploads)
       |> put_flash(:info, "Files uploaded with batch id #{batch.id}")}
    else
      {:noreply, socket}
    end
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
    {:ok, _} = Uploads.delete_batch(batch)

    {:noreply, stream_delete(socket, :batches, batch)}
  end

  @impl true
  def handle_event("purge", _params, socket) do
    {:ok, _} = Uploads.delete_batches()
    Storage.purge_uploads()

    {:noreply,
     socket
     |> stream(:batches, [])}
  end
end
