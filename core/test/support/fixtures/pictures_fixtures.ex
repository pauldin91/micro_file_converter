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
        name: "some name",
        status: "some status"
      })
      |> Core.Pictures.create_picture()

    picture
  end
end
