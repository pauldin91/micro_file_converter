defmodule Core.Transformers.Transform do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transforms" do
    field :type, :string
    field :exec, :boolean, default: false
    field :guid, :string
    field :picture_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transform, attrs) do
    transform
    |> cast(attrs, [:guid, :type, :exec])
    |> validate_required([:guid, :type, :exec])
  end
end
