defmodule Converter.Repo.Migrations.CreateBatches do
  use Ecto.Migration

  def change do
    create table(:batches) do
      add :timestamp, :utc_datetime
      add :status, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:batches, [:user_id])
  end
end
