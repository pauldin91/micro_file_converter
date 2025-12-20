defmodule Core.Storage do
  def get_storage_path(%{batch_id: id, name: filename}) do
    upload_dir = Application.fetch_env!(:core, :uploads_dir)
    Path.join([upload_dir, id, filename])
  end

  def purge_uploads() do
    dir = Application.fetch_env!(:core, :uploads_dir)
    files = File.ls!(dir) |> Enum.map(&String.to_charlist/1)

    Enum.each(
      files,
      &File.rm_rf!(Path.join([dir, &1]))
    )
  end

  def purge_uploads_with_ids(batch_ids) do
    dir = Application.fetch_env!(:core, :uploads_dir)
    batches = MapSet.new(batch_ids)

    files =
      File.ls!(dir)
      |> Enum.filter(&MapSet.member?(batches, &1))
      |> Enum.map(&String.to_charlist/1)

    Enum.each(
      files,
      &File.rm_rf!(Path.join([dir, &1]))
    )
  end

  def download_batch(id) do
    dir = Path.join([Application.fetch_env!(:core, :uploads_dir), id])

    if File.dir?(dir) do
      files =
        File.ls!(dir)
        |> Enum.filter(&(!String.ends_with?(&1, ".zip")))
        |> Enum.map(&String.to_charlist/1)

      zip_filename = String.to_charlist(Path.join([dir, "#{id}.zip"]))

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
end
