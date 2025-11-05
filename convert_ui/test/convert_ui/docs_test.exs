defmodule ConvertUi.DocsTest do
  use ConvertUi.DataCase

  alias ConvertUi.Docs

  describe "documents" do
    alias ConvertUi.Docs.Document

    import ConvertUi.DocsFixtures

    @invalid_attrs %{name: nil, path: nil, mime_type: nil, uploaded_at: nil}

    test "list_documents/0 returns all documents" do
      document = document_fixture()
      assert Docs.list_documents() == [document]
    end

    test "get_document!/1 returns the document with given id" do
      document = document_fixture()
      assert Docs.get_document!(document.id) == document
    end

    test "create_document/1 with valid data creates a document" do
      valid_attrs = %{name: "some name", path: "some path", mime_type: "some mime_type", uploaded_at: ~N[2025-11-04 19:22:00]}

      assert {:ok, %Document{} = document} = Docs.create_document(valid_attrs)
      assert document.name == "some name"
      assert document.path == "some path"
      assert document.mime_type == "some mime_type"
      assert document.uploaded_at == ~N[2025-11-04 19:22:00]
    end

    test "create_document/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Docs.create_document(@invalid_attrs)
    end

    test "update_document/2 with valid data updates the document" do
      document = document_fixture()
      update_attrs = %{name: "some updated name", path: "some updated path", mime_type: "some updated mime_type", uploaded_at: ~N[2025-11-05 19:22:00]}

      assert {:ok, %Document{} = document} = Docs.update_document(document, update_attrs)
      assert document.name == "some updated name"
      assert document.path == "some updated path"
      assert document.mime_type == "some updated mime_type"
      assert document.uploaded_at == ~N[2025-11-05 19:22:00]
    end

    test "update_document/2 with invalid data returns error changeset" do
      document = document_fixture()
      assert {:error, %Ecto.Changeset{}} = Docs.update_document(document, @invalid_attrs)
      assert document == Docs.get_document!(document.id)
    end

    test "delete_document/1 deletes the document" do
      document = document_fixture()
      assert {:ok, %Document{}} = Docs.delete_document(document)
      assert_raise Ecto.NoResultsError, fn -> Docs.get_document!(document.id) end
    end

    test "change_document/1 returns a document changeset" do
      document = document_fixture()
      assert %Ecto.Changeset{} = Docs.change_document(document)
    end
  end

  describe "batches" do
    alias ConvertUi.Docs.Batch

    import ConvertUi.DocsFixtures

    @invalid_attrs %{name: nil, description: nil}

    test "list_batches/0 returns all batches" do
      batch = batch_fixture()
      assert Docs.list_batches() == [batch]
    end

    test "get_batch!/1 returns the batch with given id" do
      batch = batch_fixture()
      assert Docs.get_batch!(batch.id) == batch
    end

    test "create_batch/1 with valid data creates a batch" do
      valid_attrs = %{name: "some name", description: "some description"}

      assert {:ok, %Batch{} = batch} = Docs.create_batch(valid_attrs)
      assert batch.name == "some name"
      assert batch.description == "some description"
    end

    test "create_batch/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Docs.create_batch(@invalid_attrs)
    end

    test "update_batch/2 with valid data updates the batch" do
      batch = batch_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description"}

      assert {:ok, %Batch{} = batch} = Docs.update_batch(batch, update_attrs)
      assert batch.name == "some updated name"
      assert batch.description == "some updated description"
    end

    test "update_batch/2 with invalid data returns error changeset" do
      batch = batch_fixture()
      assert {:error, %Ecto.Changeset{}} = Docs.update_batch(batch, @invalid_attrs)
      assert batch == Docs.get_batch!(batch.id)
    end

    test "delete_batch/1 deletes the batch" do
      batch = batch_fixture()
      assert {:ok, %Batch{}} = Docs.delete_batch(batch)
      assert_raise Ecto.NoResultsError, fn -> Docs.get_batch!(batch.id) end
    end

    test "change_batch/1 returns a batch changeset" do
      batch = batch_fixture()
      assert %Ecto.Changeset{} = Docs.change_batch(batch)
    end
  end
end
