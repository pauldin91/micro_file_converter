defmodule Core.Uploads do
  @moduledoc """
  The Uploads context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Uploads.Batch

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

  def load_metadata(batch_id) do
    upload_dir = Application.fetch_env!(:core, :uploads_dir)
    batch_dir = Path.join([upload_dir, batch_id])

    metadata_path = Path.join([batch_dir, "metadata.json"])
    file_metadata = File.read!(metadata_path)
    Jason.decode!(file_metadata)
  end

  @doc """
  Returns the list of batches.

  ## Examples

      iex> list_batches()
      [%Batch{}, ...]

  """
  def list_batches do
    Repo.all(Batch)
  end

  @doc """
  Gets a single batch.

  Raises `Ecto.NoResultsError` if the Batch does not exist.

  ## Examples

      iex> get_batch!(123)
      %Batch{}

      iex> get_batch!(456)
      ** (Ecto.NoResultsError)

  """
  def get_batch!(id), do: Repo.get!(Batch, id)

  @doc """
  Creates a batch.

  ## Examples

      iex> create_batch(%{field: value})
      {:ok, %Batch{}}

      iex> create_batch(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_batch(attrs \\ %{}) do
    %Batch{}
    |> Batch.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:batch_created)
  end

  @doc """
  Updates a batch.

  ## Examples

      iex> update_batch(batch, %{field: new_value})
      {:ok, %Batch{}}

      iex> update_batch(batch, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_batch(%Batch{} = batch, attrs) do
    batch
    |> Batch.changeset(attrs)
    |> Repo.update()
    |> broadcast(:batch_updated)
  end

  @doc """
  Deletes a batch.

  ## Examples

      iex> delete_batch(batch)
      {:ok, %Batch{}}

      iex> delete_batch(batch)
      {:error, %Ecto.Changeset{}}

  """
  def delete_batch(%Batch{} = batch) do
    Repo.delete(batch)
    |> broadcast(:batch_deleted)
  end

  def purge_batches() do
    dir = Application.fetch_env!(:core, :uploads_dir)
    files = File.ls!(dir) |> Enum.map(&String.to_charlist/1)

    Enum.each(
      files,
      &File.rm_rf!(Path.join([dir, &1]))
    )

    Repo.delete_all(Batch)
    |> broadcast(:batches_purged)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking batch changes.

  ## Examples

      iex> change_batch(batch)
      %Ecto.Changeset{data: %Batch{}}

  """
  def change_batch(%Batch{} = batch, attrs \\ %{}) do
    Batch.changeset(batch, attrs)
  end

  def broadcast({:error, _reason} = error, _event), do: error

  def broadcast({:ok, post}, event) do
    Phoenix.PubSub.broadcast(Core.PubSub, "batches", {event, post})
    {:ok, post}
  end

  def broadcast({count, nil}, event) do
    dbg(event)
    Phoenix.PubSub.broadcast(Core.PubSub, "batches", {event, count})
    {:ok, count}
  end

  @spec subscribe() :: :ok | {:error, {:already_registered, pid()}}
  def subscribe do
    Phoenix.PubSub.subscribe(Core.PubSub, "batches")
  end

  def format_bytes(bytes) when is_integer(bytes) do
    cond do
      bytes >= 1_073_741_824 -> "#{Float.round(bytes / 1_073_741_824, 2)} GB"
      bytes >= 1_048_576 -> "#{Float.round(bytes / 1_048_576, 2)} MB"
      bytes >= 1024 -> "#{Float.round(bytes / 1024, 2)} KB"
      true -> "#{bytes} B"
    end
  end

  def format_bytes(_), do: "Unknown"

  def error_to_string(:too_large), do: "File is too large (max 50MB)"
  def error_to_string(:too_many_files), do: "Too many files (max 10)"
  def error_to_string(:not_accepted), do: "File type not accepted"
  def error_to_string(_), do: "Upload error"
end
