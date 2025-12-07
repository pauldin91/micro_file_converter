defmodule Core.Repo.Migrations.CreateBatches do
  use Ecto.Migration

  def change do
    create table(:batches, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string

      timestamps(type: :utc_datetime)
    end
  end
end
