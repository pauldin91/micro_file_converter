defmodule Converter.BatchesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Converter.Batches` context.
  """

  @doc """
  Generate a batch.
  """
  def batch_fixture(attrs \\ %{}) do
    {:ok, batch} =
      attrs
      |> Enum.into(%{
        status: "some status",
        timestamp: ~U[2025-11-10 19:34:00Z]
      })
      |> Converter.Batches.create_batch()

    batch
  end
end
