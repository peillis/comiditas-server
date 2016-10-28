defmodule Comiditas.User do
  use Comiditas.Web, :model

  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    belongs_to :group, Comiditas.Group

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :password, :password_hash])
    |> validate_required([:name, :email, :password, :password_hash])
  end
end
