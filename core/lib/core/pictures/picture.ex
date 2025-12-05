defmodule Core.Pictures.Picture do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pictures" do
    field :name, :string
    field :status, :string
    field :timestamp, :utc_datetime
    field :guid, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(picture, attrs) do
    picture
    |> cast(attrs, [:guid, :name, :timestamp, :status])
    |> validate_required([:guid, :name, :timestamp, :status])
  end
end
