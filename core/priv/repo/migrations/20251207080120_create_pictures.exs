defmodule Core.Repo.Migrations.CreatePictures do
  use Ecto.Migration

  def change do
    create table(:pictures, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :transform, :string
      add :size, :integer
      add :batch_id, references(:batches, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:pictures, [:batch_id])
  end
end
