defmodule Core.Repo.Migrations.CreatePictures do
  use Ecto.Migration

  def change do
    create table(:pictures, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :status, :string
      add :size, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
