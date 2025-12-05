defmodule Core.PicturesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Core.Pictures` context.
  """

  @doc """
  Generate a picture.
  """
  def picture_fixture(attrs \\ %{}) do
    {:ok, picture} =
      attrs
      |> Enum.into(%{
        guid: "some guid",
        name: "some name",
        status: "some status",
        timestamp: ~U[2025-12-04 05:07:00Z]
      })
      |> Core.Pictures.create_picture()

    picture
  end
end
