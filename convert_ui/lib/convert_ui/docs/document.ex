defmodule ConvertUi.Docs.Document do
  use Ecto.Schema
  import Ecto.Changeset

  schema "documents" do
    field :name, :string
    field :path, :string
    field :mime_type, :string
    field :uploaded_at, :naive_datetime

    belongs_to :batch, ConvertUi.Docs.Batch

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [:name, :path, :mime_type, :uploaded_at])
    |> validate_required([:name, :path, :mime_type, :uploaded_at])
  end
end
