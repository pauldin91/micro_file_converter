defmodule Core.TransformersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Core.Transformers` context.
  """

  @doc """
  Generate a transform.
  """
  def transform_fixture(attrs \\ %{}) do
    {:ok, transform} =
      attrs
      |> Enum.into(%{
        exec: true,
        guid: "some guid",
        type: "some type"
      })
      |> Core.Transformers.create_transform()

    transform
  end
end
