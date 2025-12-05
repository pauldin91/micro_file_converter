defmodule Core.Pictures.Picture do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "pictures" do
    field :name, :string
    field :status, :string
    field :guid, Ecto.UUID

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(picture, attrs) do
    picture
    |> cast(attrs, [:name, :status, :guid])
    |> validate_required([:name, :status, :guid])
  end
end
