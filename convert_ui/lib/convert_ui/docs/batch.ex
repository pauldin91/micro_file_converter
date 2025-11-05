defmodule ConvertUi.Docs.Batch do
  use Ecto.Schema
  import Ecto.Changeset

  schema "batches" do
    field :name, :string
    field :description, :string
    has_many :documents, ConvertUi.Docs.Document

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(batch, attrs) do
    batch
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
