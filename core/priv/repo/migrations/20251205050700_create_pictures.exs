defmodule Core.Repo.Migrations.CreatePictures do
  use Ecto.Migration

  def change do
    create table(:pictures) do
      add :guid, :string
      add :name, :string
      add :timestamp, :utc_datetime
      add :status, :string

      timestamps(type: :utc_datetime)
    end
  end
end
