defmodule Core.Uploads do
  @moduledoc """
  The Uploads context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo
  alias Core.Uploads.Batch
  alias Core.Accounts.User

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
  def create_batch(%User{} = user, attrs \\ %{}) do
    %Batch{}
    |> Batch.changeset(attrs)
    |> Ecto.build_assoc(:user, user)
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
end
