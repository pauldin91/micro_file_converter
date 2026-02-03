defmodule Core.Transforms do
  import Ecto.Query, warn: false
  alias Core.Repo
  alias Core.Transformations.Transform

  def list_transforms() do
    Repo.all(Transform)
    |> Repo.preload(:transform_properties)
  end

  def get_by_name(transform_name) do
    Transform
    |> Repo.get_by(name: transform_name)
    |> Repo.preload(:transform_properties)
  end

  def build_props_for_transform(transform) do
    transformation = get_by_name(transform)

    transformation.transform_properties
    |> Enum.map(fn prop ->
      %{
        id: prop.key,
        key: prop.key,
        type: prop.type,
        value: prop.metadata[:default] || "",
        meta: prop.metadata || %{}
      }
    end)
  end

  def transform_options(transformations) do
    Enum.map(transformations, fn %Core.Transformations.Transform{} = transform ->
      {transform.label, transform.name}
    end)
  end
end
