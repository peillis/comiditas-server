defmodule Comiditas.Group do
  use Comiditas.Web, :model

  schema "groups" do
    field :name, :string
    has_many :users, Comiditas.User
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
