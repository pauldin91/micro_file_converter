defmodule Core.Handlers do
  alias Core.Metadata
  alias Core.Uploads
  alias Core.Storage
  alias Core.Items

  alias Core.Mappings.Stored

  def handle_upload(
        user,
        %{files: files, transform: transform, batch_id: batch_id, props: props}
      ) do
    ts = DateTime.utc_now()

    create_batch_with_pictures(
      %Core.Mappings.Batch{
        id: batch_id,
        files: files,
        timestamp: ts,
        transform: %{
          name: transform,
          props: props
        }
      },
      %{user_id: user.id}
    )
  end

  defp create_batch_with_pictures(%Core.Mappings.Batch{} = batch_dto, %{user_id: user_id}) do
    with {:ok, batch} <-
           Uploads.create_batch(%{
             id: batch_dto.id,
             status: "pending",
             transform: batch_dto.transform.name,
             user_id: user_id,
             inserted_at: batch_dto.timestamp
           }),
         :ok <- link_all_pictures(batch_dto),
         :ok <- Metadata.save_metadata(batch_dto),
         :ok <- publish_batch(batch_dto) do
      {:ok, batch.id}
    end
  end

  defp publish_batch(%Core.Mappings.Batch{} = batch_dto) do
    queue =
      cond do
        batch_dto.transform.name == "convert" -> get_event_queue(:none)
        true -> get_event_queue(batch_dto.transform.name)
      end

    Core.RabbitMq.Publisher.publish_message(queue, Jason.encode!(batch_dto))
  end

  def get_event_queue(:none), do: Application.fetch_env!(:core, :processing_queues) |> Enum.at(0)
  def get_event_queue(_name), do: Application.fetch_env!(:core, :processing_queues) |> Enum.at(1)

  def link_all_pictures(batch_dto) do
    Enum.reduce_while(batch_dto.files, :ok, fn file, :ok ->
      case link_picture(file, batch_dto.id) do
        :ok -> {:cont, :ok}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp link_picture(%Stored{} = stored, batch_id) do
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
