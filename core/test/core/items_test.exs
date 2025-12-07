defmodule Core.ItemsTest do
  use Core.DataCase

  alias Core.Items

  describe "pictures" do
    alias Core.Items.Picture

    import Core.ItemsFixtures

    @invalid_attrs %{name: nil, size: nil, transform: nil}

    test "list_pictures/0 returns all pictures" do
      picture = picture_fixture()
      assert Items.list_pictures() == [picture]
    end

    test "get_picture!/1 returns the picture with given id" do
      picture = picture_fixture()
      assert Items.get_picture!(picture.id) == picture
    end

    test "create_picture/1 with valid data creates a picture" do
      valid_attrs = %{name: "some name", size: 42, transform: "some transform"}

      assert {:ok, %Picture{} = picture} = Items.create_picture(valid_attrs)
      assert picture.name == "some name"
      assert picture.size == 42
      assert picture.transform == "some transform"
    end

    test "create_picture/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Items.create_picture(@invalid_attrs)
    end

    test "update_picture/2 with valid data updates the picture" do
      picture = picture_fixture()
      update_attrs = %{name: "some updated name", size: 43, transform: "some updated transform"}

      assert {:ok, %Picture{} = picture} = Items.update_picture(picture, update_attrs)
      assert picture.name == "some updated name"
      assert picture.size == 43
      assert picture.transform == "some updated transform"
    end

    test "update_picture/2 with invalid data returns error changeset" do
      picture = picture_fixture()
      assert {:error, %Ecto.Changeset{}} = Items.update_picture(picture, @invalid_attrs)
      assert picture == Items.get_picture!(picture.id)
    end

    test "delete_picture/1 deletes the picture" do
      picture = picture_fixture()
      assert {:ok, %Picture{}} = Items.delete_picture(picture)
      assert_raise Ecto.NoResultsError, fn -> Items.get_picture!(picture.id) end
    end

    test "change_picture/1 returns a picture changeset" do
      picture = picture_fixture()
      assert %Ecto.Changeset{} = Items.change_picture(picture)
    end
  end
end
