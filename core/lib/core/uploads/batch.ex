defmodule Core.Uploads.Batch do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  schema "batches" do
    field :status, :string
    field :transform, :string
    field :user_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(batch, attrs) do
    batch
    |> cast(attrs, [:id, :user_id, :status, :transform])
    |> validate_required([:id, :user_id, :status, :transform])
    |> assoc_constraint(:user)
  end
end
