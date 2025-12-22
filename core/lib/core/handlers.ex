defmodule Core.Handlers do
  alias Core.Metadata
  alias Core.Uploads
  alias Core.Storage
  alias Core.Items

  def create_batch_with_pictures(%{
        files: files,
        transform: transform,
        id: batch_id,
        user_id: user_id
      }) do
    {:ok, batch} =
      Uploads.create_batch(%{
        id: batch_id,
        status: "pending",
        transform: transform,
        user_id: user_id
      })

    Enum.each(files, &link_pictures(%{&1 | batch_id: batch_id}))

    metadata =
      Metadata.save_metadata(%Core.Mappings.Batch{
        batch_id: batch.id,
        transform: transform,
        files: files
      })

    queue = get_event_queue(transform)

    Core.Messages.RabbitPublisher.publish_message(queue, Jason.encode!(metadata))
    {:ok, batch.id}
  end

  def get_event_queue(:none), do: Application.fetch_env!(:core, :processing_queues) |> Enum.at(0)
  def get_event_queue(_name), do: Application.fetch_env!(:core, :processing_queues) |> Enum.at(1)

  def link_pictures(%{name: name, size: size, batch_id: id}) do
    with {:ok, _picture} <-
           Items.create_picture(%{
             batch_id: id,
             name: name,
             size: size
           }) do
      :ok
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  def purge_user_batches(user_id) do
    Uploads.list_batch_ids_of_user(user_id)
    |> Storage.purge_uploads_with_ids()

    Uploads.delete_batches_of_user(user_id)
  end
end
