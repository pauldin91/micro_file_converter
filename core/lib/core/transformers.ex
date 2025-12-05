defmodule Core.Transformers do
  @moduledoc """
  The Transformers context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Transformers.Transform

  @doc """
  Returns the list of transforms.

  ## Examples

      iex> list_transforms()
      [%Transform{}, ...]

  """
  def list_transforms do
    Repo.all(Transform)
  end

  @doc """
  Gets a single transform.

  Raises `Ecto.NoResultsError` if the Transform does not exist.

  ## Examples

      iex> get_transform!(123)
      %Transform{}

      iex> get_transform!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transform!(id), do: Repo.get!(Transform, id)

  @doc """
  Creates a transform.

  ## Examples

      iex> create_transform(%{field: value})
      {:ok, %Transform{}}

      iex> create_transform(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transform(attrs \\ %{}) do
    %Transform{}
    |> Transform.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transform.

  ## Examples

      iex> update_transform(transform, %{field: new_value})
      {:ok, %Transform{}}

      iex> update_transform(transform, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transform(%Transform{} = transform, attrs) do
    transform
    |> Transform.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transform.

  ## Examples

      iex> delete_transform(transform)
      {:ok, %Transform{}}

      iex> delete_transform(transform)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transform(%Transform{} = transform) do
    Repo.delete(transform)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transform changes.

  ## Examples

      iex> change_transform(transform)
      %Ecto.Changeset{data: %Transform{}}

  """
  def change_transform(%Transform{} = transform, attrs \\ %{}) do
    Transform.changeset(transform, attrs)
  end
end
