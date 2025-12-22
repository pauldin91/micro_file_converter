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
        timestamp: ~U[2025-12-05 17:21:00Z]
      })
      |> Core.Items.create_picture()

    picture
  end

  @doc """
  Generate a batch.
  """
  def batch_fixture(attrs \\ %{}) do
    {:ok, batch} =
      attrs
      |> Enum.into(%{
        status: "some status"
      })
      |> Core.Uploads.create_batch()

    batch
  end
end
