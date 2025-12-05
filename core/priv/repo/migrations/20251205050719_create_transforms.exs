defmodule Core.Repo.Migrations.CreateTransforms do
  use Ecto.Migration

  def change do
    create table(:transforms) do
      add :guid, :string
      add :type, :string
      add :exec, :boolean, default: false, null: false
      add :picture_id, references(:pictures, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:transforms, [:picture_id])
  end
end
