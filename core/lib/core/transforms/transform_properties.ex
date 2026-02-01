defmodule Core.Uploads.TransformProperties do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transform_properties" do
    field :key, :string
    field :type, :string
    belongs_to :transform, Core.Items.Transform
  end

  @doc false
  def changeset(transform_properties, attrs) do
    transform_properties
    |> cast(attrs, [:key, :type])
    |> validate_required([:key, :type])
  end
end
