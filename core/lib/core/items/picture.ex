defmodule Core.Items.Picture do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "pictures" do
    field :name, :string
    field :size, :integer
    belongs_to :batch, Core.Uploads.Batch

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(picture, attrs) do
    picture
    |> cast(attrs, [:name, :batch_id, :size])
    |> validate_required([:name, :batch_id, :size])
    |> assoc_constraint(:batch)
  end
end
