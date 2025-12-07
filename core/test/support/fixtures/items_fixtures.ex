defmodule Core.ItemsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Core.Items` context.
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
        transform: "some transform"
      })
      |> Core.Items.create_picture()

    picture
  end
end
