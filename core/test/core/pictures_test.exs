defmodule Core.PicturesTest do
  use Core.DataCase

  alias Core.Pictures

  describe "pictures" do
    alias Core.Pictures.Picture

    import Core.PicturesFixtures

    @invalid_attrs %{name: nil, status: nil, timestamp: nil, guid: nil}

    test "list_pictures/0 returns all pictures" do
      picture = picture_fixture()
      assert Pictures.list_pictures() == [picture]
    end

    test "get_picture!/1 returns the picture with given id" do
      picture = picture_fixture()
      assert Pictures.get_picture!(picture.id) == picture
    end

    test "create_picture/1 with valid data creates a picture" do
      valid_attrs = %{name: "some name", status: "some status", timestamp: ~U[2025-12-04 05:07:00Z], guid: "some guid"}

      assert {:ok, %Picture{} = picture} = Pictures.create_picture(valid_attrs)
      assert picture.name == "some name"
      assert picture.status == "some status"
      assert picture.timestamp == ~U[2025-12-04 05:07:00Z]
      assert picture.guid == "some guid"
    end

    test "create_picture/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Pictures.create_picture(@invalid_attrs)
    end

    test "update_picture/2 with valid data updates the picture" do
      picture = picture_fixture()
      update_attrs = %{name: "some updated name", status: "some updated status", timestamp: ~U[2025-12-05 05:07:00Z], guid: "some updated guid"}

      assert {:ok, %Picture{} = picture} = Pictures.update_picture(picture, update_attrs)
      assert picture.name == "some updated name"
      assert picture.status == "some updated status"
      assert picture.timestamp == ~U[2025-12-05 05:07:00Z]
      assert picture.guid == "some updated guid"
    end

    test "update_picture/2 with invalid data returns error changeset" do
      picture = picture_fixture()
      assert {:error, %Ecto.Changeset{}} = Pictures.update_picture(picture, @invalid_attrs)
      assert picture == Pictures.get_picture!(picture.id)
    end

    test "delete_picture/1 deletes the picture" do
      picture = picture_fixture()
      assert {:ok, %Picture{}} = Pictures.delete_picture(picture)
      assert_raise Ecto.NoResultsError, fn -> Pictures.get_picture!(picture.id) end
    end

    test "change_picture/1 returns a picture changeset" do
      picture = picture_fixture()
      assert %Ecto.Changeset{} = Pictures.change_picture(picture)
    end
  end
end
