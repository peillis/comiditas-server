defmodule Comiditas.Mealdate do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mealdates" do
    field :date, :date
    field :breakfast, :string
    field :lunch, :string
    field :dinner, :string
    field :notes, :binary
    belongs_to :user, Comiditas.Admin.User

    timestamps()
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:date, :breakfast, :lunch, :dinner, :notes])
    |> validate_required([:date, :breakfast, :lunch, :dinner, :user_id])
  end
end
