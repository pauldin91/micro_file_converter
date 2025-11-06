defmodule Converter.FilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Converter.Files` context.
  """

  @doc """
  Generate a upload.
  """
  def upload_fixture(attrs \\ %{}) do
    {:ok, upload} =
      attrs
      |> Enum.into(%{

      })
      |> Converter.Files.create_upload()

    upload
  end
end
