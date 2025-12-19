defmodule Core.Uploads.Batch do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :integer
  schema "batches" do
    field :status, :string
    field :transform, :string
    has_many :pictures, Core.Items.Picture, on_delete: :delete_all

    belongs_to :user, Core.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(batch, attrs) do
    batch
    |> cast(attrs, [:id, :status, :transform, :user_id])
    |> validate_required([:status, :transform, :user_id])
  end
end
