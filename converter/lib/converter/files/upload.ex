defmodule Converter.Files.Upload do
  use Ecto.Schema
  import Ecto.Changeset

  schema "uploads" do


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(upload, attrs) do
    upload
    |> cast(attrs, [])
    |> validate_required([])
  end
end
