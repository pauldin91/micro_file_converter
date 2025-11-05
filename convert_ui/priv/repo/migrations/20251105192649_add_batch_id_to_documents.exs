defmodule ConvertUi.Repo.Migrations.AddBatchIdToDocuments do
  use Ecto.Migration

  def change do
    alter table(:documents) do
      add :batch_id, references(:batches, on_delete: :delete_all)
    end

    create index(:documents, [:batch_id])
  end
end
