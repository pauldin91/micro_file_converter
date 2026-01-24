defmodule Core.Transforms do
  @transformations %{
    rotate: %{
      label: "Rotate",
      props: [
        %{key: "degrees", type: :number, default: 90, step: 90, min: 0, max: 270}
      ]
    },
    blur: %{
      label: "Blur",
      props: [
        %{key: "sigma", type: :number, default: 1.0, step: 0.1, min: 0}
      ]
    },
    invert: %{
      label: "Invert",
      props: []
    },
    convert: %{
      label: "Convert",
      props: []
    },
    brighten: %{
      label: "Brighten",
      props: [
        %{key: "value", type: :number, default: 20, step: 1, min: 0}
      ]
    },
    mirror: %{
      label: "Mirror",
      props: [
        %{
          key: "axis",
          type: :text,
          default: "horizontal",
          selection: ["horizontal", "vertical", "diagonal"]
        }
      ]
    },
    crop: %{
      label: "Crop",
      props: [
        %{key: "x", type: :number, default: 0},
        %{key: "y", type: :number, default: 0},
        %{key: "width", type: :number, default: 100},
        %{key: "height", type: :number, default: 100}
      ]
    }
  }
  def transformations, do: @transformations

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
