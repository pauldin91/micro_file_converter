defmodule Core.Repo.Migrations.CreatePictures do
  use Ecto.Migration

  def change do
    create table(:pictures) do
      add :name, :string
      add :status, :string

      timestamps(type: :utc_datetime)
    end
  end
end
