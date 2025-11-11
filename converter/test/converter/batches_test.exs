defmodule Converter.BatchesTest do
  use Converter.DataCase

  alias Converter.Batches

  describe "batches" do
    alias Converter.Batches.Batch

    import Converter.BatchesFixtures

    @invalid_attrs %{status: nil, timestamp: nil}

    test "list_batches/0 returns all batches" do
      batch = batch_fixture()
      assert Batches.list_batches() == [batch]
    end

    test "get_batch!/1 returns the batch with given id" do
      batch = batch_fixture()
      assert Batches.get_batch!(batch.id) == batch
    end

    test "create_batch/1 with valid data creates a batch" do
      valid_attrs = %{status: "some status", timestamp: ~U[2025-11-10 19:34:00Z]}

      assert {:ok, %Batch{} = batch} = Batches.create_batch(valid_attrs)
      assert batch.status == "some status"
      assert batch.timestamp == ~U[2025-11-10 19:34:00Z]
    end

    test "create_batch/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Batches.create_batch(@invalid_attrs)
    end

    test "update_batch/2 with valid data updates the batch" do
      batch = batch_fixture()
      update_attrs = %{status: "some updated status", timestamp: ~U[2025-11-11 19:34:00Z]}

      assert {:ok, %Batch{} = batch} = Batches.update_batch(batch, update_attrs)
      assert batch.status == "some updated status"
      assert batch.timestamp == ~U[2025-11-11 19:34:00Z]
    end

    test "update_batch/2 with invalid data returns error changeset" do
      batch = batch_fixture()
      assert {:error, %Ecto.Changeset{}} = Batches.update_batch(batch, @invalid_attrs)
      assert batch == Batches.get_batch!(batch.id)
    end

    test "delete_batch/1 deletes the batch" do
      batch = batch_fixture()
      assert {:ok, %Batch{}} = Batches.delete_batch(batch)
      assert_raise Ecto.NoResultsError, fn -> Batches.get_batch!(batch.id) end
    end

    test "change_batch/1 returns a batch changeset" do
      batch = batch_fixture()
      assert %Ecto.Changeset{} = Batches.change_batch(batch)
    end
  end
end
