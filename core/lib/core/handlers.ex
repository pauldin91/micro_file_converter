defmodule Core.Handlers do
  alias Core.Uploads
  alias Core.Storage
  alias Core.Items

  def handle_uploads(%{files: files, transform: transform, id: batch_id, user_id: user_id}) do
    {:ok, batch} =
      Uploads.create_batch(%{
        id: batch_id,
        status: "pending",
        transform: transform,
        user_id: user_id
      })

    Enum.each(files, &handle_upload(&1, batch_id))

    metadata =
      Storage.save_files(files, batch.id)

    queue =
      cond do
        transform == :none -> Application.fetch_env!(:core, :processing_queues) |> Enum.at(0)
        true -> Application.fetch_env!(:core, :processing_queues) |> Enum.at(1)
      end

    Core.Messages.RabbitPublisher.publish_message(queue, Jason.encode!(metadata))
    {:ok, batch.id}
  end

  def handle_upload(%{path: path, name: name}, id) do
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
end
