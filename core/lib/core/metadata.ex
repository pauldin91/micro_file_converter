defmodule Core.Metadata do
  def load_metadata(batch_id) do
    upload_dir = Application.fetch_env!(:core, :uploads_dir)
    batch_dir = Path.join([upload_dir, batch_id])

    metadata_path = Path.join([batch_dir, "metadata.json"])
    file_metadata = File.read!(metadata_path)
    Jason.decode!(file_metadata)
  end

  def create_metadata_map(batch_id, uploaded_entries) do
    %{
      batch_id: batch_id,
      timestamp: DateTime.utc_now(),
      files:
        uploaded_entries
        |> Enum.map(fn entry ->
          %{
            filename: entry.name,
            size: File.stat!(entry.path).size,
            content_type: entry.type
          }
        end),
      file_count: length(uploaded_entries)
    }
  end

  def save_metadata(uploaded_entries, batch_id) do
    upload_dir = Application.fetch_env!(:core, :uploads_dir)
    batch_dir = Path.join([upload_dir, batch_id])

    metadata = create_metadata_map(batch_id, uploaded_entries)

    metadata_path = Path.join([batch_dir, "metadata.json"])
    File.mkdir_p!(Path.dirname(metadata_path))
    File.write!(metadata_path, Jason.encode!(metadata, pretty: true))
    metadata
  end
end
