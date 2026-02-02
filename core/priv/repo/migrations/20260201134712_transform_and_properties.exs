defmodule Core.Repo.Migrations.CreateTransformProperties do
  use Ecto.Migration

  def change do
    create table(:transforms, primary_key: false) do
      add :name, :string, primary_key: true
      add :label, :string, null: false

    end

    create table(:transform_properties) do
      add :key, :string, null: false
      add :type, :string, null: false
      add :metadata, :map, default: %{}
      add :transform_name,
        references(:transforms, column: :name, on_delete: :delete_all, type: :string),
        null: false

    end

    create index(:transform_properties, [:transform_name])
  end
end
