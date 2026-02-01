defmodule Core.Uploads.Transform do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:name, :string, autogenerate: false}
  @foreign_key_type :integer
  schema "transforms" do
    field :label, :string
    has_many :transform_properties, Core.Items.TransformProperties, on_delete: :delete_all
  end

  @doc false
  def changeset(transform, attrs) do
    transform
    |> cast(attrs, [:name, :label])
    |> validate_required([:name, :label])
  end
end
