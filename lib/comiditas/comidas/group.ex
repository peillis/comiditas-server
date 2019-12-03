defmodule Comiditas.Comidas.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :name, :string
    has_many :users, Comiditas.Comidas.Users

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
