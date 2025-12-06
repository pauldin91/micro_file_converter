defmodule Core.UploadsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Core.Uploads` context.
  """

  @doc """
  Generate a picture.
  """
  def picture_fixture(attrs \\ %{}) do
    {:ok, picture} =
      attrs
      |> Enum.into(%{
        name: "some name",
        size: 42,
        status: "some status",
        timestamp: ~U[2025-12-05 17:21:00Z]
      })
      |> Core.Uploads.create_picture()

    picture
  end

  @doc """
  Generate a picture.
  """
  def picture_fixture(attrs \\ %{}) do
    {:ok, picture} =
      attrs
      |> Enum.into(%{
        name: "some name",
        size: 42,
        status: "some status"
      })
      |> Core.Uploads.create_picture()

    picture
  end
end
