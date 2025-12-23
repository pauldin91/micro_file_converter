defmodule Core.Metadata do
  alias Core.Mappings.Batch

  defp get_metadata_location(batch_id) do
    upload_dir = Application.fetch_env!(:core, :uploads_dir)
    batch_dir = Path.join([upload_dir, batch_id])

    metadata_path = Path.join([batch_dir, "#{batch_id}.json"])
    File.mkdir_p!(Path.dirname(metadata_path))
    metadata_path
  end

  defp read_metadata(batch_id) do
    get_metadata_location(batch_id)
    |> File.read!()
  end

  def load_metadata(batch_id) do
    with {:ok, map} <-
           read_metadata(batch_id)
           |> Jason.decode() do
      map
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  def save_metadata(%Batch{} = batch) do
    with {:ok, serialized} <- Jason.encode(batch, pretty: true) do
      batch_dir = get_metadata_location(batch.id)
      File.write(batch_dir, serialized)
    else
      {:error, reason} -> {:error, reason}
    end
  end
end
