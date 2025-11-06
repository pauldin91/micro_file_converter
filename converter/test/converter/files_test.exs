defmodule Converter.FilesTest do
  use Converter.DataCase

  alias Converter.Files

  describe "uploads" do
    alias Converter.Files.Upload

    import Converter.FilesFixtures

    @invalid_attrs %{}

    test "list_uploads/0 returns all uploads" do
      upload = upload_fixture()
      assert Files.list_uploads() == [upload]
    end

    test "get_upload!/1 returns the upload with given id" do
      upload = upload_fixture()
      assert Files.get_upload!(upload.id) == upload
    end

    test "create_upload/1 with valid data creates a upload" do
      valid_attrs = %{}

      assert {:ok, %Upload{} = upload} = Files.create_upload(valid_attrs)
    end

    test "create_upload/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Files.create_upload(@invalid_attrs)
    end

    test "update_upload/2 with valid data updates the upload" do
      upload = upload_fixture()
      update_attrs = %{}

      assert {:ok, %Upload{} = upload} = Files.update_upload(upload, update_attrs)
    end

    test "update_upload/2 with invalid data returns error changeset" do
      upload = upload_fixture()
      assert {:error, %Ecto.Changeset{}} = Files.update_upload(upload, @invalid_attrs)
      assert upload == Files.get_upload!(upload.id)
    end

    test "delete_upload/1 deletes the upload" do
      upload = upload_fixture()
      assert {:ok, %Upload{}} = Files.delete_upload(upload)
      assert_raise Ecto.NoResultsError, fn -> Files.get_upload!(upload.id) end
    end

    test "change_upload/1 returns a upload changeset" do
      upload = upload_fixture()
      assert %Ecto.Changeset{} = Files.change_upload(upload)
    end
  end
end
