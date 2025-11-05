defmodule ConvertUi.DocsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ConvertUi.Docs` context.
  """

  @doc """
  Generate a document.
  """
  def document_fixture(attrs \\ %{}) do
    {:ok, document} =
      attrs
      |> Enum.into(%{
        mime_type: "some mime_type",
        name: "some name",
        path: "some path",
        uploaded_at: ~N[2025-11-04 19:22:00]
      })
      |> ConvertUi.Docs.create_document()

    document
  end

  @doc """
  Generate a batch.
  """
  def batch_fixture(attrs \\ %{}) do
    {:ok, batch} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> ConvertUi.Docs.create_batch()

    batch
  end
end
