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
    filedata = get_metadata(batch_id)
    {:ok, map} = Jason.decode(filedata)
    map
  end

  def save_metadata(%Batch{id: batch_id} = batch) do
    dbg(batch)
    dbg(Jason.encode!(batch))

    get_metadata_location(batch_id)
    |> File.write!(Jason.encode!(batch, pretty: true))
  end
end
