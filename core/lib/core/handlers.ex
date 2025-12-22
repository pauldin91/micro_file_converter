defmodule Core.Handlers do
  alias Core.Metadata
  alias Core.Uploads
  alias Core.Storage
  alias Core.Items

  alias Core.Mappings.Stored

  def create_batch_with_pictures(%Core.Mappings.Batch{} = batch_dto, %{user_id: user_id}) do
    {:ok, batch} =
      Uploads.create_batch(%{
        id: batch_dto.id,
        status: "pending",
        transform: batch_dto.transform,
        user_id: user_id
      })

    Enum.each(batch_dto.files, &link_pictures(&1, batch.id))

    Metadata.save_metadata(batch_dto)

    queue = get_event_queue(batch.transform)

    Core.Messages.RabbitPublisher.publish_message(queue, Jason.encode!(batch_dto))
    {:ok, batch.id}
  end

  def get_event_queue(:none), do: Application.fetch_env!(:core, :processing_queues) |> Enum.at(0)
  def get_event_queue(_name), do: Application.fetch_env!(:core, :processing_queues) |> Enum.at(1)

  def link_pictures(%Stored{} = stored, batch_id) do
    with {:ok, _picture} <-
           Items.create_picture(%{
             batch_id: batch_id,
             name: stored.filename,
             size: stored.size
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
