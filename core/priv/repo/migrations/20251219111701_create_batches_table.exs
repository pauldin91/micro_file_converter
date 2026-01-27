defmodule Core.Repo.Migrations.CreateBatchesTable do
  use Ecto.Migration

  def change do
    create table(:batches, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string
      add :transform, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime_usec)
    end

    create index(:batches, [:user_id])
  end
end
