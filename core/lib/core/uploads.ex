defmodule Core.Uploads do
  @moduledoc """
  The Uploads context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo
  alias Core.Uploads.Batch

  @doc """
  Returns the list of batches.

  ## Examples

      iex> list_batches()
      [%Batch{}, ...]

  """
  def list_batches() do
    Repo.all(Batch)
    |> Repo.preload(:user)
  end

  def list_batch_ids_of_user(user_id) do
    Batch
    |> where(user_id: ^user_id)
    |> select([b], b.id)
    |> Repo.all()
  end

  def list_batches_of_user(user_id) do
    Repo.all_by(Batch, user_id: user_id)
    |> Repo.preload(:user)
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
  def get_batch(id), do: Repo.get(Batch, id)

  @doc """
  Creates a batch.

  ## Examples

      iex> create_batch(%{field: value})
      {:ok, %Batch{}}

      iex> create_batch(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_batch(attrs \\ %{}) do
    changeset =
      %Batch{}
      |> Batch.changeset(attrs)

    with {:ok, batch} <- Repo.insert(changeset) do
      broadcast({:ok, batch}, :batch_created)
      {:ok, batch}
    else
      {:error, reason} ->
        error =
          {:error, reason}

        broadcast(error, :batch_created)
        error
    end
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
    changeset =
      batch
      |> Batch.changeset(attrs)

    with {:ok, updated} <- Repo.update(changeset) do
      broadcast({:ok, updated}, :batch_updated)
      {:ok, updated}
    else
      {:error, reason} ->
        error =
          {:error, reason}

        broadcast(error, :batch_updated)
        error
    end
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
    with {:ok, del} <- Repo.delete(batch) do
      {:ok, del} |> broadcast(:batch_deleted)
      {:ok, del}
    else
      {:error, reason} ->
        error =
          {:error, reason}

        broadcast(error, :batch_deleted)
        error
    end
  end

  def delete_batch_for_user(%Batch{user_id: uid} = batch, %Core.Accounts.User{id: uid}) do
    delete_batch(batch)
  end

  def delete_batch_for_user(_, _), do: {:error, :unauthorized}

  def delete_batches_of_user(user_id) do
    from(b in Batch, where: b.user_id == ^user_id)
    |> Repo.delete_all()
    |> broadcast(:batches_purged)
  end

  def delete_batches() do
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
    batch
    |> Batch.changeset(attrs)
  end

  def broadcast({:error, _reason} = error, _event), do: error

  def broadcast({:ok, post}, event) do
    case Phoenix.PubSub.broadcast(Core.PubSub, "batches", {event, post}) do
      :ok -> {:ok, post}
      {:error, reason} -> {:error, reason}
    end
  end

  def broadcast({count, nil}, event) do
    case Phoenix.PubSub.broadcast(Core.PubSub, "batches", {event, count}) do
      :ok -> {:ok, count}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec subscribe() :: :ok | {:error, {:already_registered, pid()}}
  def subscribe do
    Phoenix.PubSub.subscribe(Core.PubSub, "batches")
  end
end
