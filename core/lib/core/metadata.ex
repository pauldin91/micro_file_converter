defmodule Core.Metadata do
  alias Core.Mappings.Batch

  defp get_metadata_location(batch_id) do
    upload_dir = Application.fetch_env!(:core, :uploads_dir)
    batch_dir = Path.join([upload_dir, batch_id])

    metadata_path = Path.join([batch_dir, "metadata.json"])
    File.mkdir_p!(Path.dirname(metadata_path))
    metadata_path
  end

  defp get_metadata(batch_id) do
    get_metadata_location(batch_id)
    |> File.read!()
  end

  def load_metadata(batch_id) do
    file_metadata = get_metadata(batch_id)
    Jason.decode!(file_metadata)
  end

  def save_metadata(%Batch{batch_id: batch_id} = batch) do
    get_metadata_location(batch_id)
    |> File.write!(Jason.encode!(batch, pretty: true))
  end
end
