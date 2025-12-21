defmodule Core.Handlers do
  alias Core.Metadata
  alias Core.Uploads
  alias Core.Storage
  alias Core.Items

  def handle_uploaded_entries(%{path: path, filename: filename, batch_id: uuid, type: type}) do
    dest = Storage.get_storage_path(%{batch_id: uuid, name: filename})
    File.mkdir_p!(Path.dirname(dest))
    File.cp!(path, dest)

    {:ok,
     %{
       path: dest,
       name: filename,
       type: type
     }}
  end

  def handle_uploads(%{files: files, transform: transform, id: batch_id, user_id: user_id}) do
    {:ok, batch} =
      Uploads.create_batch(%{
        id: batch_id,
        status: "pending",
        transform: transform,
        user_id: user_id
      })

    Enum.each(files, &link_pictures(&1, batch_id))

    metadata =
      Metadata.save_metadata(files, batch.id)

    queue = get_event_queue(transform)

    Core.Messages.RabbitPublisher.publish_message(queue, Jason.encode!(metadata))
    {:ok, batch.id}
  end

  def get_event_queue(:none), do: Application.fetch_env!(:core, :processing_queues) |> Enum.at(0)
  def get_event_queue(_name), do: Application.fetch_env!(:core, :processing_queues) |> Enum.at(1)

  def link_pictures(%{path: path, name: name}, id) do
    with {:ok, %File.Stat{size: size}} <- File.stat(path),
         {:ok, _picture} <-
           Items.create_picture(%{
             batch_id: id,
             name: name,
             size: size
           }) do
      :ok
    else
      {:error, reason} ->
        {:error, reason}

      other ->
        {:error, other}
    end
  end

  def purge_user_batches(user_id) do
    Uploads.list_batch_ids_of_user(user_id)
    |> Storage.purge_uploads_with_ids()

    Uploads.delete_batches_of_user(user_id)
  end
end
