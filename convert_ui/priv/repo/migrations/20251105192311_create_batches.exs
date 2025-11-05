defmodule ConvertUi.Repo.Migrations.CreateBatches do
  use Ecto.Migration

  def change do
    create table(:batches) do
      add :name, :string
      add :description, :text

      timestamps(type: :utc_datetime)
    end
  end
end
