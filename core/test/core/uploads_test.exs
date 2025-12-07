defmodule Core.UploadsTest do
  use Core.DataCase

  alias Core.Uploads

  describe "pictures" do
    alias Core.Uploads.Picture

    import Core.UploadsFixtures

    @invalid_attrs %{name: nil, size: nil, status: nil, timestamp: nil}

    test "list_pictures/0 returns all pictures" do
      picture = picture_fixture()
      assert Uploads.list_pictures() == [picture]
    end

    test "get_picture!/1 returns the picture with given id" do
      picture = picture_fixture()
      assert Uploads.get_picture!(picture.id) == picture
    end

    test "create_picture/1 with valid data creates a picture" do
      valid_attrs = %{name: "some name", size: 42, status: "some status", timestamp: ~U[2025-12-05 17:21:00Z]}

      assert {:ok, %Picture{} = picture} = Uploads.create_picture(valid_attrs)
      assert picture.name == "some name"
      assert picture.size == 42
      assert picture.status == "some status"
      assert picture.timestamp == ~U[2025-12-05 17:21:00Z]
    end

    test "create_picture/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Uploads.create_picture(@invalid_attrs)
    end

    test "update_picture/2 with valid data updates the picture" do
      picture = picture_fixture()
      update_attrs = %{name: "some updated name", size: 43, status: "some updated status", timestamp: ~U[2025-12-06 17:21:00Z]}

      assert {:ok, %Picture{} = picture} = Uploads.update_picture(picture, update_attrs)
      assert picture.name == "some updated name"
      assert picture.size == 43
      assert picture.status == "some updated status"
      assert picture.timestamp == ~U[2025-12-06 17:21:00Z]
    end

    test "update_picture/2 with invalid data returns error changeset" do
      picture = picture_fixture()
      assert {:error, %Ecto.Changeset{}} = Uploads.update_picture(picture, @invalid_attrs)
      assert picture == Uploads.get_picture!(picture.id)
    end

    test "delete_picture/1 deletes the picture" do
      picture = picture_fixture()
      assert {:ok, %Picture{}} = Uploads.delete_picture(picture)
      assert_raise Ecto.NoResultsError, fn -> Uploads.get_picture!(picture.id) end
    end

    test "change_picture/1 returns a picture changeset" do
      picture = picture_fixture()
      assert %Ecto.Changeset{} = Uploads.change_picture(picture)
    end
  end

  describe "pictures" do
    alias Core.Uploads.Picture

    import Core.UploadsFixtures

    @invalid_attrs %{name: nil, size: nil, status: nil}

    test "list_pictures/0 returns all pictures" do
      picture = picture_fixture()
      assert Uploads.list_pictures() == [picture]
    end

    test "get_picture!/1 returns the picture with given id" do
      picture = picture_fixture()
      assert Uploads.get_picture!(picture.id) == picture
    end

    test "create_picture/1 with valid data creates a picture" do
      valid_attrs = %{name: "some name", size: 42, status: "some status"}

      assert {:ok, %Picture{} = picture} = Uploads.create_picture(valid_attrs)
      assert picture.name == "some name"
      assert picture.size == 42
      assert picture.status == "some status"
    end

    test "create_picture/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Uploads.create_picture(@invalid_attrs)
    end

    test "update_picture/2 with valid data updates the picture" do
      picture = picture_fixture()
      update_attrs = %{name: "some updated name", size: 43, status: "some updated status"}

      assert {:ok, %Picture{} = picture} = Uploads.update_picture(picture, update_attrs)
      assert picture.name == "some updated name"
      assert picture.size == 43
      assert picture.status == "some updated status"
    end

    test "update_picture/2 with invalid data returns error changeset" do
      picture = picture_fixture()
      assert {:error, %Ecto.Changeset{}} = Uploads.update_picture(picture, @invalid_attrs)
      assert picture == Uploads.get_picture!(picture.id)
    end

    test "delete_picture/1 deletes the picture" do
      picture = picture_fixture()
      assert {:ok, %Picture{}} = Uploads.delete_picture(picture)
      assert_raise Ecto.NoResultsError, fn -> Uploads.get_picture!(picture.id) end
    end

    test "change_picture/1 returns a picture changeset" do
      picture = picture_fixture()
      assert %Ecto.Changeset{} = Uploads.change_picture(picture)
    end
  end

  describe "batches" do
    alias Core.Uploads.Batch

    import Core.UploadsFixtures

    @invalid_attrs %{}

    test "list_batches/0 returns all batches" do
      batch = batch_fixture()
      assert Uploads.list_batches() == [batch]
    end

    test "get_batch!/1 returns the batch with given id" do
      batch = batch_fixture()
      assert Uploads.get_batch!(batch.id) == batch
    end

    test "create_batch/1 with valid data creates a batch" do
      valid_attrs = %{}

      assert {:ok, %Batch{} = batch} = Uploads.create_batch(valid_attrs)
    end

    test "create_batch/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Uploads.create_batch(@invalid_attrs)
    end

    test "update_batch/2 with valid data updates the batch" do
      batch = batch_fixture()
      update_attrs = %{}

      assert {:ok, %Batch{} = batch} = Uploads.update_batch(batch, update_attrs)
    end

    test "update_batch/2 with invalid data returns error changeset" do
      batch = batch_fixture()
      assert {:error, %Ecto.Changeset{}} = Uploads.update_batch(batch, @invalid_attrs)
      assert batch == Uploads.get_batch!(batch.id)
    end

    test "delete_batch/1 deletes the batch" do
      batch = batch_fixture()
      assert {:ok, %Batch{}} = Uploads.delete_batch(batch)
      assert_raise Ecto.NoResultsError, fn -> Uploads.get_batch!(batch.id) end
    end

    test "change_batch/1 returns a batch changeset" do
      batch = batch_fixture()
      assert %Ecto.Changeset{} = Uploads.change_batch(batch)
    end
  end

  describe "batches" do
    alias Core.Uploads.Batch

    import Core.UploadsFixtures

    @invalid_attrs %{status: nil}

    test "list_batches/0 returns all batches" do
      batch = batch_fixture()
      assert Uploads.list_batches() == [batch]
    end

    test "get_batch!/1 returns the batch with given id" do
      batch = batch_fixture()
      assert Uploads.get_batch!(batch.id) == batch
    end

    test "create_batch/1 with valid data creates a batch" do
      valid_attrs = %{status: "some status"}

      assert {:ok, %Batch{} = batch} = Uploads.create_batch(valid_attrs)
      assert batch.status == "some status"
    end

    test "create_batch/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Uploads.create_batch(@invalid_attrs)
    end

    test "update_batch/2 with valid data updates the batch" do
      batch = batch_fixture()
      update_attrs = %{status: "some updated status"}

      assert {:ok, %Batch{} = batch} = Uploads.update_batch(batch, update_attrs)
      assert batch.status == "some updated status"
    end

    test "update_batch/2 with invalid data returns error changeset" do
      batch = batch_fixture()
      assert {:error, %Ecto.Changeset{}} = Uploads.update_batch(batch, @invalid_attrs)
      assert batch == Uploads.get_batch!(batch.id)
    end

    test "delete_batch/1 deletes the batch" do
      batch = batch_fixture()
      assert {:ok, %Batch{}} = Uploads.delete_batch(batch)
      assert_raise Ecto.NoResultsError, fn -> Uploads.get_batch!(batch.id) end
    end

    test "change_batch/1 returns a batch changeset" do
      batch = batch_fixture()
      assert %Ecto.Changeset{} = Uploads.change_batch(batch)
    end
  end
end
