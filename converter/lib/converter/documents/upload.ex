defmodule Converter.Documents.Upload do
  use Ecto.Schema
  import Ecto.Changeset

  schema "uploads" do
    field :filename, :string
    field :pages, :integer
    field :batch_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(upload, attrs) do
    upload
    |> cast(attrs, [:pages, :filename])
    |> validate_required([:pages, :filename])
  end
end
