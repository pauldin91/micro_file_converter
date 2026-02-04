defmodule Core.Repo.Migrations.SeedTransforms do
  use Ecto.Migration
  alias Core.Repo
  alias Core.Transformations.Transform
  alias Core.Transformations.TransformProperties

  def up do
    transforms_data = [
      %{
        name: "rotate",
        label: "Rotate",
        props: [
          %{key: "degrees", type: "number", metadata: %{default: 90, step: 1, min: 0, max: 360}}
        ]
      },
      %{
        name: "blur",
        label: "Blur",
        props: [
          %{key: "sigma", type: "number", metadata: %{default: 1.0, step: 0.1, min: 0}}
        ]
      },
      %{
        name: "invert",
        label: "Invert",
        props: []
      },
      %{
        name: "convert",
        label: "Convert",
        props: []
      },
      %{
        name: "brighten",
        label: "Brighten",
        props: [
          %{key: "brightness", type: "number", metadata: %{default: 20.0, step: 1.0, min: 0,max: 100.0}},
          %{key: "contrast", type: "number", metadata: %{default: 0.5, step: 0.1, min: 0, max: 3.0}}
        ]
      },
      %{
        name: "mirror",
        label: "Mirror",
        props: [
          %{
            key: "axis",
            type: "text",
            metadata: %{
              default: "horizontal",
              selection: ["horizontal", "vertical", "diagonal"]
            }
          }
        ]
      },
      %{
        name: "crop",
        label: "Crop",
        props: [
          %{key: "x", type: "number", metadata: %{default: 0}},
          %{key: "y", type: "number", metadata: %{default: 0}},
          %{key: "w", type: "number", metadata: %{default: 100}},
          %{key: "h", type: "number", metadata: %{default: 100}}
        ]
      }
    ]

    Enum.each(transforms_data, fn %{name: name, label: label, props: props} ->
      {:ok, transform} =
        %Transform{}
        |> Transform.changeset(%{name: name, label: label})
        |> Repo.insert()

      Enum.each(props, fn prop_data ->
        %TransformProperties{}
        |> TransformProperties.changeset(Map.put(prop_data, :transform_name, transform.name))
        |> Repo.insert!()
      end)
    end)
  end

  def down do
    Repo.delete_all(TransformProperties)
    Repo.delete_all(Transform)
  end
end
