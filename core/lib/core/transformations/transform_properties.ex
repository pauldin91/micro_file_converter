defmodule Core.Transformations.TransformProperties do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transform_properties" do
    field :key, :string
    field :type, :string
    field :transform_id, :string

    belongs_to :transform, Core.Transformations.Transform,
      define_field: false,
      references: :name,
      type: :string
  end

  @doc false
  def changeset(transform_properties, attrs) do
    transform_properties
    |> cast(attrs, [:key, :type, :transform_name])
    |> validate_required([:key, :type, :transform_name])
    |> foreign_key_constraint(:transform_name)
  end
end
