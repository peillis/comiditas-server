defmodule Comiditas.Template do
  use Ecto.Schema
  import Ecto.Changeset

  schema "templates" do
    field :day, :integer
    field :breakfast, :string
    field :lunch, :string
    field :dinner, :string
    belongs_to :user, Comiditas.Comidas.User

    timestamps()
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:day, :breakfast, :lunch, :dinner])
    |> validate_required([:day, :breakfast, :lunch, :dinner])
  end

end
