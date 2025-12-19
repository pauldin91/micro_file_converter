defmodule Core.Storage do
  def purge_uploads() do
    dir = Application.fetch_env!(:core, :uploads_dir)
    files = File.ls!(dir) |> Enum.map(&String.to_charlist/1)

    Enum.each(
      files,
      &File.rm_rf!(Path.join([dir, &1]))
    )
  end

  def load_metadata(batch_id) do
    upload_dir = Application.fetch_env!(:core, :uploads_dir)
    batch_dir = Path.join([upload_dir, batch_id])

    metadata_path = Path.join([batch_dir, "metadata.json"])
    file_metadata = File.read!(metadata_path)
    Jason.decode!(file_metadata)
  end

  def download_batch(id) do
    dir = Path.join([Application.fetch_env!(:core, :uploads_dir), id])

    if File.dir?(dir) do
      files = File.ls!(dir) |> Enum.map(&String.to_charlist/1)
      zip_filename = String.to_charlist("#{id}.zip")

      case :zip.create(zip_filename, files, cwd: String.to_charlist(dir)) do
        {:ok, zip_path} -> {:ok, zip_path}
        {:error, reason} -> {:error, reason}
      end
    else
      {:error, :not_found}
    end
  end

  def purge_batch(id) do
    dir = Path.join([Application.fetch_env!(:core, :uploads_dir), id])

    if File.dir?(dir) do
      case File.rm_rf(dir) do
        {:ok, files_and_dirs} -> {:ok, files_and_dirs}
        {:error, reason, file} -> {:error, reason, file}
      end
    else
      {:error, :not_found}
    end
  end

  def save_files(batch_id, uploaded_entries) do
    upload_dir = Application.fetch_env!(:core, :uploads_dir)
    batch_dir = Path.join([upload_dir, batch_id])

    metadata = %{
      batch_id: batch_id,
      timestamp: DateTime.utc_now(),
      files:
        uploaded_entries
        |> Enum.map(fn entry ->
          %{
            filename: entry.client_name,
            size: File.stat!(entry.path).size,
            content_type: entry.client_type
          }
        end),
      file_count: length(uploaded_entries)
    }

    metadata_path = Path.join([batch_dir, "metadata.json"])
    File.mkdir_p!(Path.dirname(metadata_path))
    File.write!(metadata_path, Jason.encode!(metadata, pretty: true))
    metadata
  end
end
