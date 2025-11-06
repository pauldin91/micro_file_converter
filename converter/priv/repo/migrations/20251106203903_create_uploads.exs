defmodule Converter.Repo.Migrations.CreateUploads do
  use Ecto.Migration

  def change do
    create table(:uploads) do

      timestamps(type: :utc_datetime)
    end
  end
end
