defmodule Core.Transformations.Transform do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:name, :string, autogenerate: false}

  schema "transforms" do
    field :label, :string
    has_many :transform_properties, Core.Transformations.TransformProperties,
      foreign_key: :transform_name,
      on_delete: :delete_all

  end

  @doc false
  def changeset(transform, attrs) do
    transform
    |> cast(attrs, [:name, :label])
    |> validate_required([:name, :label])
    |> unique_constraint(:name)
  end
end
