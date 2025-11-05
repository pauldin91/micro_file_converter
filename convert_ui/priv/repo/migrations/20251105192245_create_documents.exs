defmodule ConvertUi.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add :name, :string
      add :path, :string
      add :mime_type, :string
      add :uploaded_at, :naive_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
