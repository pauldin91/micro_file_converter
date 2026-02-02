defmodule Core.Transforms do
  import Ecto.Query, warn: false
  alias Core.Repo
  alias Core.Transformations.Transform


  def list_transforms() do
    Repo.all(Transform)
    |> Repo.preload(:transform_properties)
  end

  def build_props_for_transform(transform, transformations) do
    transform
    |> String.to_existing_atom()
    |> then(&transformations[&1])
    |> Map.get(:props, [])
    |> Enum.map(fn prop ->
      %{
        id: prop.key,
        key: prop.key,
        value: prop.default,
        meta: prop
      }
    end)
  end

  def transform_options(transformations) do
    Enum.map(transformations, fn {key, %{label: label}} ->
      {label, Atom.to_string(key)}
    end)
  end
end
