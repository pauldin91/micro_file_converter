defmodule Core.Repo.Migrations.TransformProperties do
  use Ecto.Migration

  def change do
    create table(:transforms, primary_key: false) do
      add :name, :string, primary_key: true
      add :label, :string
    end

    create table(:transform_properties) do
      add :key, :string
      add :type, :string
      add :default, :string
      add :metadata, :map, default: %{}
      add :transform_id,
          references(:transforms, column: :name, on_delete: :delete_all, type: :string)
    end

    create index(:transform_properties, [:transform_name])
  end
end
