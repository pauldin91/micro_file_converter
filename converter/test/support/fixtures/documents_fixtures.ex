defmodule Converter.DocumentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Converter.Documents` context.
  """

  @doc """
  Generate a upload.
  """
  def upload_fixture(attrs \\ %{}) do
    {:ok, upload} =
      attrs
      |> Enum.into(%{
        filename: "some filename",
        pages: 42
      })
      |> Converter.Documents.create_upload()

    upload
  end
end
