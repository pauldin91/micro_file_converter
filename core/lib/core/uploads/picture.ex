defmodule Core.Uploads.Picture do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "pictures" do
    field :name, :string
    field :size, :integer
    field :status, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(picture, attrs) do
    picture
    |> cast(attrs, [:name, :status, :size])
    |> validate_required([:name, :status, :size])
  end
end
