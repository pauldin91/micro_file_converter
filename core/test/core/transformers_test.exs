defmodule Core.TransformersTest do
  use Core.DataCase

  alias Core.Transformers

  describe "transforms" do
    alias Core.Transformers.Transform

    import Core.TransformersFixtures

    @invalid_attrs %{type: nil, exec: nil, guid: nil}

    test "list_transforms/0 returns all transforms" do
      transform = transform_fixture()
      assert Transformers.list_transforms() == [transform]
    end

    test "get_transform!/1 returns the transform with given id" do
      transform = transform_fixture()
      assert Transformers.get_transform!(transform.id) == transform
    end

    test "create_transform/1 with valid data creates a transform" do
      valid_attrs = %{type: "some type", exec: true, guid: "some guid"}

      assert {:ok, %Transform{} = transform} = Transformers.create_transform(valid_attrs)
      assert transform.type == "some type"
      assert transform.exec == true
      assert transform.guid == "some guid"
    end

    test "create_transform/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transformers.create_transform(@invalid_attrs)
    end

    test "update_transform/2 with valid data updates the transform" do
      transform = transform_fixture()
      update_attrs = %{type: "some updated type", exec: false, guid: "some updated guid"}

      assert {:ok, %Transform{} = transform} = Transformers.update_transform(transform, update_attrs)
      assert transform.type == "some updated type"
      assert transform.exec == false
      assert transform.guid == "some updated guid"
    end

    test "update_transform/2 with invalid data returns error changeset" do
      transform = transform_fixture()
      assert {:error, %Ecto.Changeset{}} = Transformers.update_transform(transform, @invalid_attrs)
      assert transform == Transformers.get_transform!(transform.id)
    end

    test "delete_transform/1 deletes the transform" do
      transform = transform_fixture()
      assert {:ok, %Transform{}} = Transformers.delete_transform(transform)
      assert_raise Ecto.NoResultsError, fn -> Transformers.get_transform!(transform.id) end
    end

    test "change_transform/1 returns a transform changeset" do
      transform = transform_fixture()
      assert %Ecto.Changeset{} = Transformers.change_transform(transform)
    end
  end
end
