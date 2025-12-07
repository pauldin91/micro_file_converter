defmodule Core.Items.Picture do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "pictures" do
    field :name, :string
    field :size, :integer
    field :transform, :string
    field :batch_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(picture, attrs) do
    picture
    |> cast(attrs, [:name, :transform, :size])
    |> validate_required([:name, :transform, :size])
  end
end
