defmodule Converter.Repo.Migrations.CreateUploads do
  use Ecto.Migration

  def change do
    create table(:uploads) do
      add :pages, :integer
      add :filename, :string
      add :batch_id, references(:batches, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:uploads, [:batch_id])
  end
end
