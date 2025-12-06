defmodule Core.Pictures do
  @moduledoc """
  The Pictures context.
  """

  import Ecto.Query, warn: false
  alias Core.Pictures.Picture
  alias Core.Repo

  alias Core.Pictures.Picture

  def save_files(pricture_id, uploaded_entries) do
    upload_dir = Application.fetch_env!(:core, :uploads_dir)
    pricture_dir = Path.join([upload_dir, pricture_id])

    metadata = %{
      pricture_id: pricture_id,
      timestamp: DateTime.utc_now(),
      files: [],
      file_count: length(uploaded_entries)
    }

    files_metadata =
      Enum.map(uploaded_entries, fn entry ->
        %{
          filename: entry.client_name,
          size: File.stat!(entry.path).size,
          content_type: entry.client_type
        }
      end)

    final_metadata = %{metadata | files: files_metadata}
    # Save metadata as JSON
    metadata_path = Path.join([pricture_dir, "metadata.json"])
    File.mkdir_p!(Path.dirname(metadata_path))
    File.write!(metadata_path, Jason.encode!(final_metadata, pretty: true))

    final_metadata
  end

  alias Core.Pictures.Picture

  @doc """
  Returns the list of pictures.

  ## Examples

      iex> list_pictures()
      [%Picture{}, ...]

  """
  def list_pictures do
    Repo.all(Picture)
  end

  @doc """
  Gets a single picture.

  Raises `Ecto.NoResultsError` if the Picture does not exist.

  ## Examples

      iex> get_picture!(123)
      %Picture{}

      iex> get_picture!(456)
      ** (Ecto.NoResultsError)

  """
  def get_picture!(id), do: Repo.get!(Picture, id)

  @doc """
  Creates a picture.

  ## Examples

      iex> create_picture(%{field: value})
      {:ok, %Picture{}}

      iex> create_picture(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_picture(attrs \\ %{}) do
    %Picture{}
    |> Picture.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a picture.

  ## Examples

      iex> update_picture(picture, %{field: new_value})
      {:ok, %Picture{}}

      iex> update_picture(picture, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_picture(%Picture{} = picture, attrs) do
    picture
    |> Picture.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a picture.

  ## Examples

      iex> delete_picture(picture)
      {:ok, %Picture{}}

      iex> delete_picture(picture)
      {:error, %Ecto.Changeset{}}

  """
  def delete_picture(%Picture{} = picture) do
    Repo.delete(picture)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking picture changes.

  ## Examples

      iex> change_picture(picture)
      %Ecto.Changeset{data: %Picture{}}

  """
  def change_picture(%Picture{} = picture, attrs \\ %{}) do
    Picture.changeset(picture, attrs)
  end
end
