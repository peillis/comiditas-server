defmodule Comiditas.Frozen do
  use Ecto.Schema
  import Ecto.Changeset

  schema "frozen" do
    field :date, :date
    belongs_to :group, Comiditas.Groups.Group

    timestamps()
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:date, :group_id])
    |> validate_required([:date, :group_id])
  end
end
