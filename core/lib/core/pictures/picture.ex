defmodule Core.Pictures.Picture do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pictures" do
    field :name, :string
    field :status, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(picture, attrs) do
    picture
    |> cast(attrs, [:name, :status])
    |> validate_required([:name, :status])
  end
end
