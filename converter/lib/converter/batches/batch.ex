defmodule Converter.Batches.Batch do
  use Ecto.Schema
  import Ecto.Changeset

  schema "batches" do
    has_many :uploads, Converter.Documents.Upload

    field :status, :string
    field :timestamp, :utc_datetime
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(batch, attrs) do
    batch
    |> cast(attrs, [:timestamp, :status])
    |> validate_required([:timestamp, :status])
  end
end
